import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/services/log_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auction_models.dart';

abstract class AuctionWebSocketService {
  Future<void> connect(String auctionId);
  void disconnect();
  void placeBid(double amount);
  Stream<BidModel> get bidStream;
  Stream<BidPlacedEvent> get bidPlacedStream;
  Stream<AuctionEndedEvent> get auctionEndedStream;
  Stream<String> get errorStream;
}

@LazySingleton(as: AuctionWebSocketService)
class AuctionWebSocketServiceImpl implements AuctionWebSocketService {
  final TokenStorage _tokenStorage;
  final Talker _log = LogService().talker;

  WebSocketChannel? _channel;
  final _bidController = StreamController<BidModel>.broadcast();
  final _bidPlacedController = StreamController<BidPlacedEvent>.broadcast();
  final _auctionEndedController =
      StreamController<AuctionEndedEvent>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  String? _currentAuctionId;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  AuctionWebSocketServiceImpl(this._tokenStorage);

  @override
  Stream<BidModel> get bidStream => _bidController.stream;

  @override
  Stream<BidPlacedEvent> get bidPlacedStream => _bidPlacedController.stream;

  @override
  Stream<AuctionEndedEvent> get auctionEndedStream =>
      _auctionEndedController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  /// Parses a money value that the API sends as a numeric string (e.g. "90000").
  static int _parseMoney(Object? v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  @override
  Future<void> connect(String auctionId) async {
    _currentAuctionId = auctionId;
    _reconnectAttempts = 0;
    await _doConnect(auctionId);
  }

  Future<void> _doConnect(String auctionId) async {
    final token = await _tokenStorage.getToken();
    final wsUrl = Uri.parse(
      '${ApiConstants.wsBaseUrl}/$auctionId?token=$token',
    );

    _log.info('Connecting to Auction WS: $wsUrl');

    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (message) {
        _log.debug('WS Message: $message');
        try {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          final type = data['type'] as String?;

          switch (type) {
            case 'bid_placed':
              final bid = BidModel.fromJson(
                data['bid'] as Map<String, dynamic>,
              );
              final currentPrice = _parseMoney(data['current_price']);
              _bidController.add(bid);
              _bidPlacedController.add(
                BidPlacedEvent(bid: bid, currentPrice: currentPrice),
              );

            case 'auction_ended':
              final event = AuctionEndedEvent(
                auctionId: data['auction_id'] as String? ?? '',
                winnerId: data['winner_id'] as String?,
                finalPrice: _parseMoney(data['final_price']),
              );
              _auctionEndedController.add(event);
              _currentAuctionId = null; // Stop reconnect after auction ends

            case 'error':
              final msg = data['message'] as String? ?? 'Unknown WS Error';
              _errorController.add(msg);

            default:
              _log.debug('Unhandled WS type: $type');
          }
        } catch (e, st) {
          _log.error('Failed to parse WS message', e, st);
        }
      },
      onDone: () {
        _log.info('WS Connection Closed');
        _scheduleReconnect();
      },
      onError: (error) {
        _log.error('WS Connection Error', error);
        _errorController.add('WebSocket Error: $error');
        _scheduleReconnect();
      },
    );
  }

  void _scheduleReconnect() {
    if (_currentAuctionId == null) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _errorController.add('تعذر إعادة الاتصال بالمزاد');
      return;
    }
    final delay = Duration(seconds: (1 << _reconnectAttempts).clamp(1, 32));
    _reconnectAttempts++;
    _log.info(
      'Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)',
    );
    Future.delayed(delay, () {
      if (_currentAuctionId != null) _doConnect(_currentAuctionId!);
    });
  }

  @override
  void placeBid(double amount) {
    if (_channel != null) {
      final message = jsonEncode({
        'event': 'place_bid',
        'payload': {'amount': amount},
      });
      _channel!.sink.add(message);
      _log.info('Sent Bid: $amount');
    } else {
      _log.warning('Attempted to place bid but WS channel is null');
      _errorController.add('Not connected to auction');
    }
  }

  @override
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}

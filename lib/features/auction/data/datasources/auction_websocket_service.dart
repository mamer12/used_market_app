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
  Stream<String> get errorStream;
}

@LazySingleton(as: AuctionWebSocketService)
class AuctionWebSocketServiceImpl implements AuctionWebSocketService {
  final TokenStorage _tokenStorage;
  final Talker _log = LogService().talker;

  WebSocketChannel? _channel;
  final _bidController = StreamController<BidModel>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  AuctionWebSocketServiceImpl(this._tokenStorage);

  @override
  Stream<BidModel> get bidStream => _bidController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Future<void> connect(String auctionId) async {
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
          final event = data['event'];
          final payload = data['payload'] as Map<String, dynamic>;

          if (event == 'new_bid') {
            final bid = BidModel.fromJson(payload);
            _bidController.add(bid);
          } else if (event == 'error') {
            final errorMsg =
                payload['message'] as String? ?? 'Unknown WS Error';
            _errorController.add(errorMsg);
          }
        } catch (e, st) {
          _log.error('Failed to parse WS message', e, st);
        }
      },
      onDone: () {
        _log.info('WS Connection Closed');
      },
      onError: (error) {
        _log.error('WS Connection Error', error);
        _errorController.add('WebSocket Error: $error');
      },
    );
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

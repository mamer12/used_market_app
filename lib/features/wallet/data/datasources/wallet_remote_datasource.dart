import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class WalletRemoteDataSource {
  Future<int> fetchBalance();
  Future<void> deductBalance(int amount);
}

@LazySingleton(as: WalletRemoteDataSource)
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Dio _dio;

  WalletRemoteDataSourceImpl(this._dio);

  @override
  Future<int> fetchBalance() async {
    final response = await _dio.get<Map<String, dynamic>>('wallet/balance');
    final data = response.data;
    if (data == null) throw StateError('Empty wallet/balance response');

    final raw = data['balance'] ?? (data['data'] as Map?)?['balance'];
    if (raw == null) throw StateError('balance field missing in response');

    if (raw is int) return raw;
    if (raw is double) return raw.toInt();
    if (raw is String) return int.parse(raw);
    throw StateError('Unexpected balance type: ${raw.runtimeType}');
  }

  @override
  Future<void> deductBalance(int amount) async {
    await _dio.post<Map<String, dynamic>>(
      'wallet/deduct',
      data: {'amount': amount},
    );
  }
}

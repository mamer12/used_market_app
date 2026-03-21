import 'package:injectable/injectable.dart';

import '../datasources/wallet_remote_datasource.dart';

abstract class WalletRepository {
  Future<int> getBalance();
  Future<void> deductBalance(int amount);
  Future<List<Map<String, dynamic>>> getTransactions({int page = 1, int limit = 20});
}

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _dataSource;

  WalletRepositoryImpl(this._dataSource);

  @override
  Future<int> getBalance() => _dataSource.fetchBalance();

  @override
  Future<void> deductBalance(int amount) => _dataSource.deductBalance(amount);

  @override
  Future<List<Map<String, dynamic>>> getTransactions({
    int page = 1,
    int limit = 20,
  }) => _dataSource.fetchTransactions(page: page, limit: limit);
}

import 'package:injectable/injectable.dart';

import '../datasources/wallet_remote_datasource.dart';

abstract class WalletRepository {
  Future<int> getBalance();
  Future<void> deductBalance(int amount);
}

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _dataSource;

  WalletRepositoryImpl(this._dataSource);

  @override
  Future<int> getBalance() => _dataSource.fetchBalance();

  @override
  Future<void> deductBalance(int amount) => _dataSource.deductBalance(amount);
}

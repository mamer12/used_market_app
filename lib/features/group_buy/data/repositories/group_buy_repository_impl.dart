import 'package:injectable/injectable.dart';

import '../../domain/repositories/group_buy_repository.dart';
import '../datasources/group_buy_remote_data_source.dart';
import '../models/group_buy_model.dart';

@LazySingleton(as: GroupBuyRepository)
class GroupBuyRepositoryImpl implements GroupBuyRepository {
  final GroupBuyRemoteDataSource _remoteDataSource;

  GroupBuyRepositoryImpl(this._remoteDataSource);

  @override
  Future<GroupBuyModel> getGroupBuy(String id) =>
      _remoteDataSource.getGroupBuy(id);

  @override
  Future<GroupBuyModel> joinGroupBuy(String id) =>
      _remoteDataSource.joinGroupBuy(id);

  @override
  Future<GroupBuyModel> createGroupBuy(String productId) =>
      _remoteDataSource.createGroupBuy(productId);
}

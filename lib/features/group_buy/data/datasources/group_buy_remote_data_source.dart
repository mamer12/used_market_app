import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/group_buy_model.dart';

abstract class GroupBuyRemoteDataSource {
  Future<GroupBuyModel> getGroupBuy(String id);
  Future<GroupBuyModel> joinGroupBuy(String id);
  Future<GroupBuyModel> createGroupBuy(String productId);
}

@LazySingleton(as: GroupBuyRemoteDataSource)
class GroupBuyRemoteDataSourceImpl implements GroupBuyRemoteDataSource {
  final Dio _dio;

  GroupBuyRemoteDataSourceImpl(this._dio);

  @override
  Future<GroupBuyModel> getGroupBuy(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('group-buys/$id');
    final data = res.data!['data'] as Map<String, dynamic>? ?? res.data!;
    return GroupBuyModel.fromJson(data);
  }

  @override
  Future<GroupBuyModel> joinGroupBuy(String id) async {
    final res = await _dio.post<Map<String, dynamic>>('group-buys/$id/join');
    final data = res.data!['data'] as Map<String, dynamic>? ?? res.data!;
    return GroupBuyModel.fromJson(data);
  }

  @override
  Future<GroupBuyModel> createGroupBuy(String productId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'group-buys',
      data: {'product_id': productId},
    );
    final data = res.data!['data'] as Map<String, dynamic>? ?? res.data!;
    return GroupBuyModel.fromJson(data);
  }
}

import '../../data/models/group_buy_model.dart';

abstract class GroupBuyRepository {
  Future<GroupBuyModel> getGroupBuy(String id);
  Future<GroupBuyModel> joinGroupBuy(String id);
  Future<GroupBuyModel> createGroupBuy(String productId);
}

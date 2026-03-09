import 'package:injectable/injectable.dart';

import '../../../auction/data/models/auction_models.dart';
import '../../../home/data/models/portal_models.dart';
import '../../../shop/data/models/shop_models.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';

@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;

  SearchRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<dynamic>> search(String query) async {
    final rawList = await _remoteDataSource.search(query);
    return rawList.map((json) {
      final map = json as Map<String, dynamic>;
      final type = map['type'] as String?;

      switch (type) {
        case 'auction':
          return AuctionModel.fromJson(map);
        case 'product':
          return ProductModel.fromJson(map);
        case 'shop':
          return ShopModel.fromJson(map);
        case 'mustamal':
          return ItemModel.fromJson(map);
        default:
          // Fallback guessing based on common fields
          if (map.containsKey('current_bid')) {
            return AuctionModel.fromJson(map);
          }
          if (map.containsKey('shop_id')) {
            return ProductModel.fromJson(map);
          }
          if (map.containsKey('slug')) {
            return ShopModel.fromJson(map);
          }
          return ItemModel.fromJson(map);
      }
    }).toList();
  }
}

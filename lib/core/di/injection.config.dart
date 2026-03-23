// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auction/data/datasources/auction_remote_data_source.dart'
    as _i17;
import '../../features/auction/data/datasources/auction_websocket_service.dart'
    as _i464;
import '../../features/auction/data/repositories/auction_repository_impl.dart'
    as _i350;
import '../../features/auction/domain/repositories/auction_repository.dart'
    as _i256;
import '../../features/auction/presentation/bloc/auction_cubit.dart' as _i94;
import '../../features/auction/presentation/bloc/auctions_cubit.dart' as _i936;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/cart/data/datasources/cart_remote_data_source.dart'
    as _i607;
import '../../features/cart/presentation/cubit/balla_cart_cubit.dart' as _i891;
import '../../features/cart/presentation/cubit/matajir_cart_cubit.dart' as _i52;
import '../../features/category/data/datasources/category_remote_datasource.dart'
    as _i88;
import '../../features/category/data/repositories/category_repository_impl.dart'
    as _i528;
import '../../features/category/domain/repositories/category_repository.dart'
    as _i869;
import '../../features/category/presentation/cubit/category_cubit.dart'
    as _i859;
import '../../features/chat/data/datasources/chat_remote_data_source.dart'
    as _i980;
import '../../features/chat/data/repositories/chat_repository_impl.dart'
    as _i504;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i420;
import '../../features/chat/presentation/bloc/chat_cubit.dart' as _i708;
import '../../features/flash_drops/data/datasources/flash_drop_remote_data_source.dart'
    as _i644;
import '../../features/flash_drops/data/repositories/flash_drop_repository_impl.dart'
    as _i1063;
import '../../features/flash_drops/domain/repositories/flash_drop_repository.dart'
    as _i465;
import '../../features/flash_drops/presentation/bloc/flash_drop_cubit.dart'
    as _i523;
import '../../features/flash_drops/presentation/cubit/flash_drop_create_cubit.dart'
    as _i24;
import '../../features/group_buy/data/datasources/group_buy_remote_data_source.dart'
    as _i471;
import '../../features/group_buy/data/repositories/group_buy_repository_impl.dart'
    as _i618;
import '../../features/group_buy/domain/repositories/group_buy_repository.dart'
    as _i773;
import '../../features/group_buy/presentation/cubit/group_buy_cubit.dart'
    as _i419;
import '../../features/home/presentation/bloc/create_balla_cubit.dart' as _i740;
import '../../features/home/presentation/bloc/create_mustamal_cubit.dart'
    as _i231;
import '../../features/home/presentation/bloc/home_cubit.dart' as _i816;
import '../../features/map/data/datasources/map_remote_data_source.dart'
    as _i341;
import '../../features/map/data/repositories/map_repository_impl.dart' as _i457;
import '../../features/map/domain/repositories/map_repository.dart' as _i973;
import '../../features/map/presentation/cubit/map_cubit.dart' as _i523;
import '../../features/media/data/datasources/media_remote_data_source.dart'
    as _i1028;
import '../../features/negotiation/data/datasources/negotiation_remote_data_source.dart'
    as _i26;
import '../../features/negotiation/data/repositories/negotiation_repository_impl.dart'
    as _i267;
import '../../features/negotiation/domain/repositories/negotiation_repository.dart'
    as _i181;
import '../../features/negotiation/presentation/cubit/negotiation_cubit.dart'
    as _i926;
import '../../features/notifications/presentation/bloc/notification_cubit.dart'
    as _i1060;
import '../../features/notifications/presentation/pages/notifications_page.dart'
    as _i499;
import '../../features/orders/presentation/cubit/order_tracking_cubit.dart'
    as _i934;
import '../../features/search/data/datasources/search_remote_data_source.dart'
    as _i280;
import '../../features/search/data/repositories/search_repository_impl.dart'
    as _i1017;
import '../../features/search/domain/repositories/search_repository.dart'
    as _i357;
import '../../features/search/presentation/bloc/search_cubit.dart' as _i77;
import '../../features/shop/data/datasources/order_remote_data_source.dart'
    as _i239;
import '../../features/shop/data/datasources/shop_remote_data_source.dart'
    as _i462;
import '../../features/shop/data/repositories/follow_repository.dart' as _i654;
import '../../features/shop/data/repositories/order_repository_impl.dart'
    as _i1001;
import '../../features/shop/data/repositories/shop_repository_impl.dart'
    as _i704;
import '../../features/shop/domain/repositories/order_repository.dart' as _i958;
import '../../features/shop/domain/repositories/shop_repository.dart' as _i106;
import '../../features/shop/presentation/bloc/checkout_cubit.dart' as _i596;
import '../../features/shop/presentation/bloc/create_shop_cubit.dart' as _i910;
import '../../features/shop/presentation/bloc/order_cubit.dart' as _i771;
import '../../features/shop/presentation/bloc/shops_cubit.dart' as _i162;
import '../../features/shop/presentation/pages/dispute_page.dart' as _i943;
import '../../features/stories/data/datasources/story_remote_data_source.dart'
    as _i51;
import '../../features/stories/data/repositories/story_repository_impl.dart'
    as _i262;
import '../../features/stories/domain/repositories/story_repository.dart'
    as _i909;
import '../../features/stories/presentation/bloc/story_cubit.dart' as _i480;
import '../../features/wallet/data/datasources/wallet_remote_datasource.dart'
    as _i684;
import '../../features/wallet/data/repositories/wallet_repository_impl.dart'
    as _i690;
import '../../features/wallet/presentation/cubit/wallet_cubit.dart' as _i101;
import '../network/auth_interceptor.dart' as _i908;
import '../storage/token_storage.dart' as _i973;
import 'register_module.dart' as _i291;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.lazySingleton<_i973.TokenStorage>(() => _i973.TokenStorageImpl());
  gh.factory<_i908.AuthInterceptor>(
    () => _i908.AuthInterceptor(gh<_i973.TokenStorage>()),
  );
  gh.lazySingleton<_i464.AuctionWebSocketService>(
    () => _i464.AuctionWebSocketServiceImpl(gh<_i973.TokenStorage>()),
  );
  gh.lazySingleton<_i361.Dio>(
    () => registerModule.dio(gh<_i908.AuthInterceptor>()),
  );
  gh.lazySingleton<_i17.AuctionRemoteDataSource>(
    () => _i17.AuctionRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i471.GroupBuyRemoteDataSource>(
    () => _i471.GroupBuyRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i239.OrderRemoteDataSource>(
    () => _i239.OrderRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i980.ChatRemoteDataSource>(
    () => _i980.ChatRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i341.MapRemoteDataSource>(
    () => _i341.MapRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i88.CategoryRemoteDataSource>(
    () => _i88.CategoryRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i773.GroupBuyRepository>(
    () => _i618.GroupBuyRepositoryImpl(gh<_i471.GroupBuyRemoteDataSource>()),
  );
  gh.lazySingleton<_i644.FlashDropRemoteDataSource>(
    () => _i644.FlashDropRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i1028.MediaRemoteDataSource>(
    () => _i1028.MediaRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i420.ChatRepository>(
    () => _i504.ChatRepositoryImpl(gh<_i980.ChatRemoteDataSource>()),
  );
  gh.lazySingleton<_i684.WalletRemoteDataSource>(
    () => _i684.WalletRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i256.AuctionRepository>(
    () => _i350.AuctionRepositoryImpl(
      gh<_i17.AuctionRemoteDataSource>(),
      gh<_i464.AuctionWebSocketService>(),
    ),
  );
  gh.lazySingleton<_i26.NegotiationRemoteDataSource>(
    () => _i26.NegotiationRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i1060.NotificationCubit>(
    () => _i1060.NotificationCubit(gh<_i361.Dio>()),
  );
  gh.factory<_i654.FollowRepository>(
    () => _i654.FollowRepository(gh<_i361.Dio>()),
  );
  gh.factory<_i943.DisputeDataSource>(
    () => _i943.DisputeDataSource(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i465.FlashDropRepository>(
    () => _i1063.FlashDropRepositoryImpl(gh<_i644.FlashDropRemoteDataSource>()),
  );
  gh.factory<_i94.AuctionCubit>(
    () => _i94.AuctionCubit(gh<_i256.AuctionRepository>()),
  );
  gh.factory<_i936.AuctionsCubit>(
    () => _i936.AuctionsCubit(gh<_i256.AuctionRepository>()),
  );
  gh.factory<_i708.ChatCubit>(
    () => _i708.ChatCubit(gh<_i420.ChatRepository>()),
  );
  gh.lazySingleton<_i181.NegotiationRepository>(
    () =>
        _i267.NegotiationRepositoryImpl(gh<_i26.NegotiationRemoteDataSource>()),
  );
  gh.factory<_i523.FlashDropCubit>(
    () => _i523.FlashDropCubit(gh<_i465.FlashDropRepository>()),
  );
  gh.factory<_i24.FlashDropCreateCubit>(
    () => _i24.FlashDropCreateCubit(gh<_i465.FlashDropRepository>()),
  );
  gh.lazySingleton<_i973.MapRepository>(
    () => _i457.MapRepositoryImpl(gh<_i341.MapRemoteDataSource>()),
  );
  gh.lazySingleton<_i107.AuthRemoteDataSource>(
    () => _i107.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i499.OrdersCubit>(
    () => _i499.OrdersCubit(gh<_i239.OrderRemoteDataSource>()),
  );
  gh.lazySingleton<_i462.ShopRemoteDataSource>(
    () => _i462.ShopRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i280.SearchRemoteDataSource>(
    () => _i280.SearchRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i607.CartRemoteDataSource>(
    () => _i607.CartRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i869.CategoryRepository>(
    () => _i528.CategoryRepositoryImpl(
      remoteDataSource: gh<_i88.CategoryRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i51.StoryRemoteDataSource>(
    () => _i51.StoryRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i958.OrderRepository>(
    () => _i1001.OrderRepositoryImpl(gh<_i239.OrderRemoteDataSource>()),
  );
  gh.factory<_i419.GroupBuyCubit>(
    () => _i419.GroupBuyCubit(gh<_i773.GroupBuyRepository>()),
  );
  gh.lazySingleton<_i690.WalletRepository>(
    () => _i690.WalletRepositoryImpl(gh<_i684.WalletRemoteDataSource>()),
  );
  gh.factory<_i523.MapCubit>(() => _i523.MapCubit(gh<_i973.MapRepository>()));
  gh.lazySingleton<_i909.StoryRepository>(
    () => _i262.StoryRepositoryImpl(gh<_i51.StoryRemoteDataSource>()),
  );
  gh.factory<_i926.NegotiationCubit>(
    () => _i926.NegotiationCubit(gh<_i181.NegotiationRepository>()),
  );
  gh.factory<_i480.StoryCubit>(
    () => _i480.StoryCubit(gh<_i909.StoryRepository>()),
  );
  gh.lazySingleton<_i787.AuthRepository>(
    () => _i153.AuthRepositoryImpl(
      gh<_i107.AuthRemoteDataSource>(),
      gh<_i973.TokenStorage>(),
    ),
  );
  gh.factoryParam<_i859.CategoryCubit, String, dynamic>(
    (appContext, _) => _i859.CategoryCubit(
      repository: gh<_i869.CategoryRepository>(),
      appContext: appContext,
    ),
  );
  gh.lazySingleton<_i357.SearchRepository>(
    () => _i1017.SearchRepositoryImpl(gh<_i280.SearchRemoteDataSource>()),
  );
  gh.factory<_i891.BallaCartCubit>(
    () => _i891.BallaCartCubit(gh<_i607.CartRemoteDataSource>()),
  );
  gh.factory<_i52.MatajirCartCubit>(
    () => _i52.MatajirCartCubit(gh<_i607.CartRemoteDataSource>()),
  );
  gh.lazySingleton<_i106.ShopRepository>(
    () => _i704.ShopRepositoryImpl(gh<_i462.ShopRemoteDataSource>()),
  );
  gh.factory<_i101.WalletCubit>(
    () => _i101.WalletCubit(gh<_i690.WalletRepository>()),
  );
  gh.factory<_i934.OrderTrackingCubit>(
    () => _i934.OrderTrackingCubit(gh<_i958.OrderRepository>()),
  );
  gh.factory<_i596.CheckoutCubit>(
    () => _i596.CheckoutCubit(gh<_i958.OrderRepository>()),
  );
  gh.factory<_i771.OrderCubit>(
    () => _i771.OrderCubit(gh<_i958.OrderRepository>()),
  );
  gh.factoryParam<_i797.AuthBloc, _i558.FlutterSecureStorage?, dynamic>(
    (storage, _) =>
        _i797.AuthBloc(gh<_i787.AuthRepository>(), storage: storage),
  );
  gh.factory<_i740.CreateBallaCubit>(
    () => _i740.CreateBallaCubit(
      gh<_i106.ShopRepository>(),
      gh<_i1028.MediaRemoteDataSource>(),
    ),
  );
  gh.factory<_i231.CreateMustamalCubit>(
    () => _i231.CreateMustamalCubit(
      gh<_i106.ShopRepository>(),
      gh<_i1028.MediaRemoteDataSource>(),
    ),
  );
  gh.factory<_i77.SearchCubit>(
    () => _i77.SearchCubit(gh<_i357.SearchRepository>()),
  );
  gh.factory<_i816.HomeCubit>(
    () => _i816.HomeCubit(
      gh<_i256.AuctionRepository>(),
      gh<_i106.ShopRepository>(),
      gh<_i361.Dio>(),
    ),
  );
  gh.factory<_i910.CreateShopCubit>(
    () => _i910.CreateShopCubit(gh<_i106.ShopRepository>()),
  );
  gh.factory<_i162.ShopsCubit>(
    () => _i162.ShopsCubit(gh<_i106.ShopRepository>()),
  );
  gh.factory<_i162.ShopProductsCubit>(
    () => _i162.ShopProductsCubit(gh<_i106.ShopRepository>()),
  );
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}

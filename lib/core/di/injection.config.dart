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
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/cart/data/datasources/cart_remote_data_source.dart'
    as _i607;
import '../../features/home/presentation/bloc/home_cubit.dart' as _i816;
import '../../features/media/data/datasources/media_remote_data_source.dart'
    as _i1028;
import '../../features/notifications/presentation/pages/notifications_page.dart'
    as _i499;
import '../../features/search/data/datasources/search_remote_data_source.dart'
    as _i280;
import '../../features/shop/data/datasources/order_remote_data_source.dart'
    as _i239;
import '../../features/shop/data/datasources/shop_remote_data_source.dart'
    as _i462;
import '../../features/shop/data/repositories/order_repository_impl.dart'
    as _i1001;
import '../../features/shop/data/repositories/shop_repository_impl.dart'
    as _i704;
import '../../features/shop/domain/repositories/order_repository.dart' as _i958;
import '../../features/shop/domain/repositories/shop_repository.dart' as _i106;
import '../../features/shop/presentation/bloc/create_shop_cubit.dart' as _i910;
import '../../features/shop/presentation/bloc/order_cubit.dart' as _i771;
import '../../features/shop/presentation/bloc/shops_cubit.dart' as _i162;
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
  gh.lazySingleton<_i239.OrderRemoteDataSource>(
    () => _i239.OrderRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i280.SearchRemoteDataSource>(
    () => _i280.SearchRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i107.AuthRemoteDataSource>(
    () => _i107.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i1028.MediaRemoteDataSource>(
    () => _i1028.MediaRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i499.OrdersCubit>(
    () => _i499.OrdersCubit(gh<_i239.OrderRemoteDataSource>()),
  );
  gh.lazySingleton<_i607.CartRemoteDataSource>(
    () => _i607.CartRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i787.AuthRepository>(
    () => _i153.AuthRepositoryImpl(
      gh<_i107.AuthRemoteDataSource>(),
      gh<_i973.TokenStorage>(),
    ),
  );
  gh.lazySingleton<_i958.OrderRepository>(
    () => _i1001.OrderRepositoryImpl(gh<_i239.OrderRemoteDataSource>()),
  );
  gh.factoryParam<_i797.AuthBloc, _i558.FlutterSecureStorage?, dynamic>(
    (storage, _) =>
        _i797.AuthBloc(gh<_i787.AuthRepository>(), storage: storage),
  );
  gh.lazySingleton<_i462.ShopRemoteDataSource>(
    () => _i462.ShopRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i106.ShopRepository>(
    () => _i704.ShopRepositoryImpl(gh<_i462.ShopRemoteDataSource>()),
  );
  gh.lazySingleton<_i17.AuctionRemoteDataSource>(
    () => _i17.AuctionRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i771.OrderCubit>(
    () => _i771.OrderCubit(gh<_i958.OrderRepository>()),
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
  gh.lazySingleton<_i256.AuctionRepository>(
    () => _i350.AuctionRepositoryImpl(
      gh<_i17.AuctionRemoteDataSource>(),
      gh<_i464.AuctionWebSocketService>(),
    ),
  );
  gh.factory<_i94.AuctionCubit>(
    () => _i94.AuctionCubit(gh<_i256.AuctionRepository>()),
  );
  gh.factory<_i816.HomeCubit>(
    () => _i816.HomeCubit(
      gh<_i256.AuctionRepository>(),
      gh<_i106.ShopRepository>(),
    ),
  );
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}

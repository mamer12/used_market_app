import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/cubit/sooq_config_cubit.dart';
import '../../core/locale/locale_cubit.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/presentation/bloc/cart_cubit.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../../l10n/generated/app_localizations.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;
  late final SooqConfigCubit _sooqConfigCubit;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>()..add(const AuthCheckRequested());
    _sooqConfigCubit = getIt<SooqConfigCubit>()..loadConfig();
    _router = buildAppRouter(_authBloc, _sooqConfigCubit); // Create once; never rebuild
  }

  @override
  void dispose() {
    _authBloc.close();
    _sooqConfigCubit.close();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── ScreenUtilInit as True Root ─────────────────────
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _authBloc),
            BlocProvider(
              create: (_) => CartCubit(
                getIt.isRegistered<CartRemoteDataSource>()
                    ? getIt<CartRemoteDataSource>()
                    : null,
              ),
            ),
            BlocProvider(create: (_) => LocaleCubit()),
            BlocProvider.value(value: _sooqConfigCubit),
            BlocProvider(create: (_) => getIt<WalletCubit>()..loadBalance()),
          ],
          child: BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'Madhmoon',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,

                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: locale,

                // go_router with mandatory auth redirect (stable instance)
                routerConfig: _router,
              );
            },
          ),
        );
      },
    );
  }
}

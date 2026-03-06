import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/di/injection.dart';
import '../../core/locale/locale_cubit.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/presentation/bloc/cart_cubit.dart';
import '../../l10n/generated/app_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

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
            BlocProvider(
              create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
            ),
            BlocProvider(
              create: (_) => CartCubit(
                getIt.isRegistered<CartRemoteDataSource>()
                    ? getIt<CartRemoteDataSource>()
                    : null,
              ),
            ),
            BlocProvider(create: (_) => LocaleCubit()),
          ],
          child: BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'لكطة',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,

                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: locale,

                // go_router integration
                routerConfig: appRouter,
              );
            },
          ),
        );
      },
    );
  }
}

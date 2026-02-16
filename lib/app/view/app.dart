import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/locale/locale_cubit.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/domain/entities/auth_status.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
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
              create: (_) => AuthBloc()..add(const AuthCheckRequested()),
            ),
            BlocProvider(create: (_) => LocaleCubit()),
          ],
          child: BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                title: 'Mustamal',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,

                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: locale,

                // Entry point
                home: const _AppEntry(),
              );
            },
          ),
        );
      },
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.initial) {
          return const _SplashScreen(key: ValueKey('splash'));
        }

        if (state.isAuthenticated) {
          return const HomePage(key: ValueKey('home'));
        }

        if (!state.hasOnboarded) {
          return const OnboardingPage(key: ValueKey('onboarding'));
        }

        return const HomePage(key: ValueKey('home_guest'));
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: CircularProgressIndicator(color: AppTheme.textPrimary),
      ),
    );
  }
}

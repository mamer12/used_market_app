import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      // The builder ensures ScreenUtil is initialized before MaterialApp builds its theme
      builder: (context, child) {
        return BlocProvider(
          create: (_) => AuthBloc()..add(const AuthCheckRequested()),
          child: MaterialApp(
            title: 'Mustamal',
            debugShowCheckedModeBanner: false,
            // Safe to access AppTheme because ScreenUtil is already initialized by the builder
            theme: AppTheme.lightTheme,

            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),

            // Entry point
            home: const _AppEntry(),
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

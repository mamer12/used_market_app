import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the app locale (language).
///
/// Emits a new [Locale] whenever the user toggles the language.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('ar'));

  /// Toggle between English and Arabic.
  void toggleLocale() {
    emit(state.languageCode == 'en' ? const Locale('ar') : const Locale('en'));
  }

  /// Set a specific locale.
  void setLocale(Locale locale) => emit(locale);
}

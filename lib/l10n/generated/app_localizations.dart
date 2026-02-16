import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// App name shown in AppBar and title
  ///
  /// In en, this message translates to:
  /// **'Mustamal'**
  String get appTitle;

  /// Skip button on onboarding
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Next button on onboarding
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Final onboarding CTA — enters guest mode
  ///
  /// In en, this message translates to:
  /// **'Start Browsing'**
  String get onboardingGetStarted;

  /// Onboarding slide 1 title
  ///
  /// In en, this message translates to:
  /// **'Buy with Trust'**
  String get onboardingTitle1;

  /// Onboarding slide 1 description
  ///
  /// In en, this message translates to:
  /// **'Every listing is verified. Shop with confidence.'**
  String get onboardingDesc1;

  /// Onboarding slide 2 title
  ///
  /// In en, this message translates to:
  /// **'Sell in Minutes'**
  String get onboardingTitle2;

  /// Onboarding slide 2 description
  ///
  /// In en, this message translates to:
  /// **'Snap a photo, set a price, done.'**
  String get onboardingDesc2;

  /// Onboarding slide 3 title
  ///
  /// In en, this message translates to:
  /// **'Live Auctions'**
  String get onboardingTitle3;

  /// Onboarding slide 3 description
  ///
  /// In en, this message translates to:
  /// **'Bid in real-time on exclusive items.'**
  String get onboardingDesc3;

  /// Login header line 1
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get loginWelcomeTo;

  /// Phone input label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get loginPhoneNumber;

  /// Phone input placeholder
  ///
  /// In en, this message translates to:
  /// **'7XX XXX XXXX'**
  String get loginPhoneHint;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get loginContinue;

  /// Divider text
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get loginOr;

  /// Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginContinueGoogle;

  /// Terms disclaimer
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service'**
  String get loginTerms;

  /// Validation: empty phone
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get loginPhoneEmpty;

  /// Validation: invalid phone
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get loginPhoneInvalid;

  /// Search bar placeholder
  ///
  /// In en, this message translates to:
  /// **'Search Mustamal...'**
  String get homeSearch;

  /// Categories section title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeCategories;

  /// Live section title
  ///
  /// In en, this message translates to:
  /// **'Live Now'**
  String get homeLiveNow;

  /// See all link
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get homeSeeAll;

  /// Live badge text
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get homeLive;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get categoryMobile;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get categoryCars;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get categoryFurniture;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get categoryJobs;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get categoryRealEstate;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get categoryFashion;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get categoryMore;

  /// Banner 1 title
  ///
  /// In en, this message translates to:
  /// **'Daily Deals 🔥'**
  String get bannerTitle1;

  /// Banner 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Up to 70% off!'**
  String get bannerSub1;

  /// Banner 2 title
  ///
  /// In en, this message translates to:
  /// **'New Arrivals 📦'**
  String get bannerTitle2;

  /// Banner 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Fresh listings today'**
  String get bannerSub2;

  /// Banner 3 title
  ///
  /// In en, this message translates to:
  /// **'Auction Live 🔨'**
  String get bannerTitle3;

  /// Banner 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Bid now!'**
  String get bannerSub3;

  /// Number of bidders
  ///
  /// In en, this message translates to:
  /// **'{count} bidders'**
  String bidders(int count);

  /// Auth bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Login to Continue'**
  String get authSheetTitle;

  /// Auth bottom sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to perform this action.'**
  String get authSheetSubtitle;

  /// Request OTP button
  ///
  /// In en, this message translates to:
  /// **'Get Code'**
  String get authGetCode;

  /// OTP view title
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get authVerifyTitle;

  /// OTP subtitle prefix
  ///
  /// In en, this message translates to:
  /// **'Code sent to'**
  String get authCodeSentTo;

  /// Verify OTP button
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerifyCode;

  /// Go back to phone input
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get authChangeNumber;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

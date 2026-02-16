// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mustamal';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Start Browsing';

  @override
  String get onboardingTitle1 => 'Buy with Trust';

  @override
  String get onboardingDesc1 =>
      'Every listing is verified. Shop with confidence.';

  @override
  String get onboardingTitle2 => 'Sell in Minutes';

  @override
  String get onboardingDesc2 => 'Snap a photo, set a price, done.';

  @override
  String get onboardingTitle3 => 'Live Auctions';

  @override
  String get onboardingDesc3 => 'Bid in real-time on exclusive items.';

  @override
  String get loginWelcomeTo => 'Welcome to';

  @override
  String get loginPhoneNumber => 'Phone Number';

  @override
  String get loginPhoneHint => '7XX XXX XXXX';

  @override
  String get loginContinue => 'Continue';

  @override
  String get loginOr => 'Or';

  @override
  String get loginContinueGoogle => 'Continue with Google';

  @override
  String get loginTerms => 'By continuing, you agree to our Terms of Service';

  @override
  String get loginPhoneEmpty => 'Please enter your phone number';

  @override
  String get loginPhoneInvalid => 'Invalid phone number';

  @override
  String get homeSearch => 'Search Mustamal...';

  @override
  String get homeCategories => 'Categories';

  @override
  String get homeLiveNow => 'Live Now';

  @override
  String get homeSeeAll => 'See All';

  @override
  String get homeLive => 'LIVE';

  @override
  String get categoryMobile => 'Mobile';

  @override
  String get categoryCars => 'Cars';

  @override
  String get categoryFurniture => 'Furniture';

  @override
  String get categoryJobs => 'Jobs';

  @override
  String get categoryRealEstate => 'Real Estate';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryFashion => 'Fashion';

  @override
  String get categoryMore => 'More';

  @override
  String get bannerTitle1 => 'Daily Deals 🔥';

  @override
  String get bannerSub1 => 'Up to 70% off!';

  @override
  String get bannerTitle2 => 'New Arrivals 📦';

  @override
  String get bannerSub2 => 'Fresh listings today';

  @override
  String get bannerTitle3 => 'Auction Live 🔨';

  @override
  String get bannerSub3 => 'Bid now!';

  @override
  String bidders(int count) {
    return '$count bidders';
  }

  @override
  String get authSheetTitle => 'Login to Continue';

  @override
  String get authSheetSubtitle => 'Sign in to perform this action.';

  @override
  String get authGetCode => 'Get Code';

  @override
  String get authVerifyTitle => 'Enter Verification Code';

  @override
  String get authCodeSentTo => 'Code sent to';

  @override
  String get authVerifyCode => 'Verify';

  @override
  String get authChangeNumber => 'Change number';
}

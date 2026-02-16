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

  /// Greeting subtitle
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeGreetingSub;

  /// Greeting with name
  ///
  /// In en, this message translates to:
  /// **'Good morning, Ahmed'**
  String get homeGreeting;

  /// Search bar placeholder
  ///
  /// In en, this message translates to:
  /// **'Search for cars, real estate, or services...'**
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

  /// Live section subtitle
  ///
  /// In en, this message translates to:
  /// **'Unmissable deals ending soon'**
  String get homeLiveSubtitle;

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

  /// Bid label on live cards
  ///
  /// In en, this message translates to:
  /// **'Highest bid'**
  String get homeHighestBid;

  /// Recently added section title
  ///
  /// In en, this message translates to:
  /// **'Freshly Listed'**
  String get homeFreshlyListed;

  /// Banner verified badge
  ///
  /// In en, this message translates to:
  /// **'100% Verified'**
  String get homeVerified;

  /// Hero banner title
  ///
  /// In en, this message translates to:
  /// **'Mustamal Inspected\nUsed Cars'**
  String get homeBannerTitle;

  /// Hero banner subtitle
  ///
  /// In en, this message translates to:
  /// **'Full warranty & detailed inspection reports'**
  String get homeBannerSubtitle;

  /// Banner CTA button
  ///
  /// In en, this message translates to:
  /// **'Browse Now'**
  String get homeBrowseNow;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Auctions'**
  String get categoryAuctions;

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
  /// **'Services'**
  String get categoryServices;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get categoryMore;

  /// Number of bidders
  ///
  /// In en, this message translates to:
  /// **'{count} bidders'**
  String bidders(int count);

  /// Currency label
  ///
  /// In en, this message translates to:
  /// **'IQD'**
  String get currency;

  /// Slide 1 badge
  ///
  /// In en, this message translates to:
  /// **'100% Verified'**
  String get bannerBadge1;

  /// Slide 1 title
  ///
  /// In en, this message translates to:
  /// **'Mustamal Inspected\nUsed Cars'**
  String get bannerTitle1;

  /// Slide 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Full warranty & detailed inspection reports'**
  String get bannerSub1;

  /// Slide 1 CTA
  ///
  /// In en, this message translates to:
  /// **'Browse Now'**
  String get bannerCta1;

  /// Slide 2 badge
  ///
  /// In en, this message translates to:
  /// **'Exclusive Deals'**
  String get bannerBadge2;

  /// Slide 2 title
  ///
  /// In en, this message translates to:
  /// **'Daily Deals 🔥'**
  String get bannerTitle2;

  /// Slide 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Up to 70% off on selected electronics'**
  String get bannerSub2;

  /// Slide 2 CTA
  ///
  /// In en, this message translates to:
  /// **'Discover Deals'**
  String get bannerCta2;

  /// Slide 3 badge
  ///
  /// In en, this message translates to:
  /// **'Live Auction 🔨'**
  String get bannerBadge3;

  /// Slide 3 title
  ///
  /// In en, this message translates to:
  /// **'Bid Now on\nTop Products'**
  String get bannerTitle3;

  /// Slide 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Daily live auctions at unbeatable prices'**
  String get bannerSub3;

  /// Slide 3 CTA
  ///
  /// In en, this message translates to:
  /// **'View Auctions'**
  String get bannerCta3;

  /// Live item 1
  ///
  /// In en, this message translates to:
  /// **'Italian Sofa Set'**
  String get liveItemTitle1;

  /// Live item 2
  ///
  /// In en, this message translates to:
  /// **'Original Rolex Watch'**
  String get liveItemTitle2;

  /// Live item 3
  ///
  /// In en, this message translates to:
  /// **'iPhone 14 Pro Max'**
  String get liveItemTitle3;

  /// Listing 1
  ///
  /// In en, this message translates to:
  /// **'Red Nike Running Shoes'**
  String get listingTitle1;

  /// Location 1
  ///
  /// In en, this message translates to:
  /// **'Baghdad, Mansour'**
  String get listingLocation1;

  /// Listing 2
  ///
  /// In en, this message translates to:
  /// **'Dell XPS 13 Laptop'**
  String get listingTitle2;

  /// Location 2
  ///
  /// In en, this message translates to:
  /// **'Basra'**
  String get listingLocation2;

  /// Listing 3
  ///
  /// In en, this message translates to:
  /// **'Velvet Recliner Chair'**
  String get listingTitle3;

  /// Location 3
  ///
  /// In en, this message translates to:
  /// **'Erbil'**
  String get listingLocation3;

  /// Listing 4
  ///
  /// In en, this message translates to:
  /// **'Sony Bluetooth Headphones'**
  String get listingTitle4;

  /// Location 4
  ///
  /// In en, this message translates to:
  /// **'Najaf'**
  String get listingLocation4;

  /// Time ago
  ///
  /// In en, this message translates to:
  /// **'1h ago'**
  String get timeAgo1;

  /// Time ago
  ///
  /// In en, this message translates to:
  /// **'2h ago'**
  String get timeAgo2;

  /// Time ago
  ///
  /// In en, this message translates to:
  /// **'4h ago'**
  String get timeAgo4;

  /// Time ago
  ///
  /// In en, this message translates to:
  /// **'5h ago'**
  String get timeAgo5;

  /// Auction dock label
  ///
  /// In en, this message translates to:
  /// **'Current Price'**
  String get auctionCurrentPrice;

  /// Small label above bid button
  ///
  /// In en, this message translates to:
  /// **'Bid Now'**
  String get auctionBidNowLabel;

  /// Primary bid button text
  ///
  /// In en, this message translates to:
  /// **'Place Your Bid'**
  String get auctionPlaceYourBid;

  /// Quick bid button label
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get auctionIncrease;

  /// Mock seller name
  ///
  /// In en, this message translates to:
  /// **'Royal Baghdad Auto'**
  String get auctionSellerName;

  /// Bidder 1 name
  ///
  /// In en, this message translates to:
  /// **'Hassan Al-Iraqi'**
  String get auctionBidder1;

  /// Bidder 2 name
  ///
  /// In en, this message translates to:
  /// **'Zaid Mohammed'**
  String get auctionBidder2;

  /// Bidder 3 name
  ///
  /// In en, this message translates to:
  /// **'Ali Al-Basrawi'**
  String get auctionBidder3;

  /// Label for user's own bids
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get auctionYou;

  /// Auth bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Login to Continue'**
  String get authSheetTitle;

  /// Auth bottom sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'You need to be signed in to perform this action. Please enter your phone number to proceed.'**
  String get authSheetSubtitle;

  /// Phone input label above field
  ///
  /// In en, this message translates to:
  /// **'PHONE NUMBER'**
  String get authPhoneLabel;

  /// Helper text below phone input
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a verification code via SMS.'**
  String get authPhoneSmsHint;

  /// Request OTP button
  ///
  /// In en, this message translates to:
  /// **'Get Code  →'**
  String get authGetCode;

  /// Alternative email login link
  ///
  /// In en, this message translates to:
  /// **'Use email instead'**
  String get authUseEmail;

  /// Help link on login sheet
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get authNeedHelp;

  /// OTP view title
  ///
  /// In en, this message translates to:
  /// **'Verify it\'s you'**
  String get authVerifyTitle;

  /// OTP subtitle prefix
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 4-digit code to'**
  String get authCodeSentTo;

  /// Edit phone number link in OTP view
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get authEdit;

  /// Verify OTP button
  ///
  /// In en, this message translates to:
  /// **'VERIFY & CONTINUE  →'**
  String get authVerifyCode;

  /// Resend timer label
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get authResendCode;

  /// Go back to phone input
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get authChangeNumber;

  /// Language toggle label — shows the OTHER language name
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get switchLanguage;
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

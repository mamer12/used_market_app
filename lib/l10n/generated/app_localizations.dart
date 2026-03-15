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

  /// Verify OTP page title
  ///
  /// In en, this message translates to:
  /// **'Verify it\'s you'**
  String get verifyOtpTitle;

  /// Verify OTP page subtitle
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to your number'**
  String get verifyOtpSubtitle;

  /// Resend countdown prefix
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get verifyOtpResendIn;

  /// Resend OTP button
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get verifyOtpResend;

  /// Verify OTP submit button
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyOtpSubmit;

  /// Go back to phone input
  ///
  /// In en, this message translates to:
  /// **'Edit number'**
  String get verifyOtpEditNumber;

  /// Registration page title
  ///
  /// In en, this message translates to:
  /// **'Complete your registration'**
  String get registerTitle;

  /// Step indicator on registration page
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 3'**
  String get registerStepLabel;

  /// Name field hint
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get registerFullNameHint;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get registerFullNameLabel;

  /// Role selection section title
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get registerRoleTitle;

  /// Registration submit button
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get registerSubmit;

  /// Role: consumer user
  ///
  /// In en, this message translates to:
  /// **'Shopper'**
  String get roleUser;

  /// Role: shop seller
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get roleMerchant;

  /// Role: auction participant
  ///
  /// In en, this message translates to:
  /// **'Auctioneer'**
  String get roleAuctioneer;

  /// Role user description
  ///
  /// In en, this message translates to:
  /// **'Browse and buy from shops and auctions'**
  String get roleUserDesc;

  /// Role merchant description
  ///
  /// In en, this message translates to:
  /// **'I have a store and want to sell products'**
  String get roleMerchantDesc;

  /// Role auctioneer description
  ///
  /// In en, this message translates to:
  /// **'I participate in auctions and sell to the highest bidder'**
  String get roleAuctioneerDesc;

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
  /// **'What are you looking for today?'**
  String get homeSearch;

  /// Editorial section header for the 4 sooqs
  ///
  /// In en, this message translates to:
  /// **'Markets'**
  String get homeMarkets;

  /// Sooq card 1 title
  ///
  /// In en, this message translates to:
  /// **'Auctions Market'**
  String get homeSooqAuctions;

  /// Sooq card 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Live deals right now'**
  String get homeSooqAuctionsSub;

  /// Sooq card 1 CTA
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get homeSooqAuctionsBtn;

  /// Sooq card 2 title
  ///
  /// In en, this message translates to:
  /// **'Official Stores'**
  String get homeSooqShops;

  /// Sooq card 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Genuine and guaranteed products'**
  String get homeSooqShopsSub;

  /// Sooq card 2 CTA
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get homeSooqShopsBtn;

  /// Sooq card 3 title
  ///
  /// In en, this message translates to:
  /// **'Used Market'**
  String get homeSooqUsed;

  /// Sooq card 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Buy & sell between people'**
  String get homeSooqUsedSub;

  /// Sooq card 3 CTA
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get homeSooqUsedBtn;

  /// Sooq card 4 title
  ///
  /// In en, this message translates to:
  /// **'Balla Market'**
  String get homeSooqBalla;

  /// Sooq card 4 subtitle
  ///
  /// In en, this message translates to:
  /// **'Bundles & bulk goods'**
  String get homeSooqBallaSub;

  /// Sooq card 4 CTA
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get homeSooqBallaBtn;

  /// Trending section header
  ///
  /// In en, this message translates to:
  /// **'🔥 Trending Today'**
  String get homeTrendingToday;

  /// Wallet chip label
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get homeWalletBalance;

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
  /// **'We\'ve sent a 6-digit code to'**
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

  /// Bottom nav: Home slot
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav: Messages slot
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// Bottom nav: Activity/deals slot
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get navActivity;

  /// Bottom nav: Profile slot
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// FAB post action sheet main title
  ///
  /// In en, this message translates to:
  /// **'What do you want to add?'**
  String get postSheetTitle;

  /// FAB post action sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose the type of listing'**
  String get postSheetSub;

  /// Post option: auction
  ///
  /// In en, this message translates to:
  /// **'Start an Auction'**
  String get postAuction;

  /// Post option: auction subtitle
  ///
  /// In en, this message translates to:
  /// **'Let buyers bid — highest price wins'**
  String get postAuctionSub;

  /// Post option: sell
  ///
  /// In en, this message translates to:
  /// **'Sell an Item'**
  String get postSell;

  /// Post option: sell subtitle
  ///
  /// In en, this message translates to:
  /// **'Fixed price listing in the used market'**
  String get postSellSub;

  /// Post option: service
  ///
  /// In en, this message translates to:
  /// **'Offer a Service'**
  String get postService;

  /// Post option: service subtitle
  ///
  /// In en, this message translates to:
  /// **'Plumbing, electrical, cleaning, any trade'**
  String get postServiceSub;

  /// Post option: job
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get postJob;

  /// Post option: job subtitle
  ///
  /// In en, this message translates to:
  /// **'Find workers and employees'**
  String get postJobSub;

  /// Activity page title
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get activityTitle;

  /// Activity tab: orders
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get activityOrders;

  /// Activity tab: saved items
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get activitySaved;

  /// Activity tab: bids
  ///
  /// In en, this message translates to:
  /// **'My Bids'**
  String get activityBids;

  /// Activity tab: bookings
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get activityBookings;

  /// Activity page header summary line
  ///
  /// In en, this message translates to:
  /// **'{orders} orders · {saved} saved'**
  String activitySummary(int orders, int saved);

  /// Clear cart button
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get cartClear;

  /// Empty orders state title
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// Empty orders state subtitle
  ///
  /// In en, this message translates to:
  /// **'Browse shops and add items you want to buy'**
  String get cartEmptySub;

  /// Empty saved state title
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get savedEmpty;

  /// Empty saved state subtitle
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any product to save it here'**
  String get savedEmptySub;

  /// Checkout button
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutBtn;

  /// Coming soon snackbar message for checkout
  ///
  /// In en, this message translates to:
  /// **'Checkout coming soon!'**
  String get checkoutComingSoon;

  /// Price per single item qualifier
  ///
  /// In en, this message translates to:
  /// **'each'**
  String get perItem;

  /// Order total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// Snackbar after adding to cart
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// Bids tab info banner title
  ///
  /// In en, this message translates to:
  /// **'Track Your Bids'**
  String get bidsTrackTitle;

  /// Bids tab info banner subtitle
  ///
  /// In en, this message translates to:
  /// **'See auctions you participated in and their status'**
  String get bidsTrackSub;

  /// Empty bids state title
  ///
  /// In en, this message translates to:
  /// **'No active bids yet'**
  String get bidsEmpty;

  /// Empty bids state subtitle
  ///
  /// In en, this message translates to:
  /// **'Tap an auction and start bidding — see it here'**
  String get bidsEmptySub;

  /// CTA to go browse auctions from bids tab
  ///
  /// In en, this message translates to:
  /// **'Browse Auctions'**
  String get browseBids;

  /// Empty bookings state title
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get bookingsEmpty;

  /// Empty bookings state subtitle
  ///
  /// In en, this message translates to:
  /// **'Book a service and find it here'**
  String get bookingsEmptySub;

  /// Super-app mode strip label
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get homeWhatLooking;

  /// Mode tile: Auctions
  ///
  /// In en, this message translates to:
  /// **'Auctions'**
  String get modeAuctions;

  /// Mode tile: Auctions tagline
  ///
  /// In en, this message translates to:
  /// **'Bid & win'**
  String get modeAuctionTag;

  /// Mode tile: local shops
  ///
  /// In en, this message translates to:
  /// **'Local Shops'**
  String get modeLocalShops;

  /// Mode tile: local shops tagline
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get modeLocalTag;

  /// Mode tile: official/brand stores
  ///
  /// In en, this message translates to:
  /// **'Official Stores'**
  String get modeOfficialStores;

  /// Mode tile: official stores tagline
  ///
  /// In en, this message translates to:
  /// **'Verified brands'**
  String get modeOfficialTag;

  /// Mode tile: used market
  ///
  /// In en, this message translates to:
  /// **'Used Market'**
  String get modeUsed;

  /// Mode tile: used market tagline
  ///
  /// In en, this message translates to:
  /// **'Pre-loved'**
  String get modeUsedTag;

  /// Shops section heading
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get shopsSection;

  /// Shops section subtitle with trust badge
  ///
  /// In en, this message translates to:
  /// **'Trusted sellers · Secure payment'**
  String get shopsTrustedSub;

  /// Used market section heading
  ///
  /// In en, this message translates to:
  /// **'Used & Renewed'**
  String get usedMarketTitle;

  /// Used market section subtitle
  ///
  /// In en, this message translates to:
  /// **'Buy and sell with trust and ease'**
  String get usedMarketSub;

  /// Visit shop button
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get visitShop;

  /// Fallback city name for listings without location
  ///
  /// In en, this message translates to:
  /// **'Baghdad'**
  String get defaultCity;

  /// Watching count on auction card
  ///
  /// In en, this message translates to:
  /// **'{count} watching'**
  String auctionWatching(int count);

  /// Bid count on auction card
  ///
  /// In en, this message translates to:
  /// **'{count} bids'**
  String auctionBidding(int count);

  /// Auction ended state label
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get auctionEndedLabel;

  /// Item condition: excellent
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get condExcellent;

  /// Item condition: very good
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get condVeryGood;

  /// Item condition: good
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get condGood;

  /// Item condition: fair
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get condFair;

  /// Messages page title
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// Empty messages state title
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get messagesEmpty;

  /// Empty messages state subtitle
  ///
  /// In en, this message translates to:
  /// **'Contact sellers and buyers directly'**
  String get messagesEmptySub;

  /// Search bar placeholder
  ///
  /// In en, this message translates to:
  /// **'Search for anything...'**
  String get searchHint;

  /// Search tab: all results
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchTabAll;

  /// Search tab: new auctions
  ///
  /// In en, this message translates to:
  /// **'Auctions'**
  String get searchTabAuctions;

  /// Search tab: used items
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get searchTabUsed;

  /// Search tab: shop products
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get searchTabShops;

  /// Search idle state title
  ///
  /// In en, this message translates to:
  /// **'Start searching'**
  String get searchEmpty;

  /// Search idle state subtitle
  ///
  /// In en, this message translates to:
  /// **'Try something like iPhone or TV'**
  String get searchEmptySub;

  /// No results title
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get searchNoResults;

  /// No results subtitle
  ///
  /// In en, this message translates to:
  /// **'Nothing found for \"{query}\"'**
  String searchNoResultsSub(String query);

  /// Number of search results
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String searchResultCount(int count);

  /// Minimum characters required for search
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters'**
  String get searchMinChars;

  /// Notifications/Activity page title
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityPageTitle;

  /// Activity tab: purchases (buyer)
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get activityTabPurchases;

  /// Activity tab: sales (seller)
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get activityTabSales;

  /// Empty orders state title on activity page
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmpty;

  /// Empty orders state subtitle on activity page
  ///
  /// In en, this message translates to:
  /// **'Your purchases and sales will appear here'**
  String get ordersEmptySub;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryBtn;

  /// Unauthenticated activity title
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your activity'**
  String get signInToViewActivity;

  /// Unauthenticated activity subtitle
  ///
  /// In en, this message translates to:
  /// **'Track your purchases, sales, and bids all in one place.'**
  String get signInActivitySub;

  /// Sign In button label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInBtn;

  /// Order card number label
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumber(String id);

  /// Order qty and price line
  ///
  /// In en, this message translates to:
  /// **'Qty {qty}  •  {price} IQD'**
  String orderQtyPrice(int qty, String price);

  /// Order status: pending payment
  ///
  /// In en, this message translates to:
  /// **'Pending Payment'**
  String get statusPendingPayment;

  /// Order status: paid to escrow
  ///
  /// In en, this message translates to:
  /// **'Paid — In Escrow'**
  String get statusPaidEscrow;

  /// Order status: shipped
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get statusShipped;

  /// Order status: delivered
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// Order status: funds released / completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Profile page header title
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// Verified badge on profile avatar
  ///
  /// In en, this message translates to:
  /// **'● Verified'**
  String get profileVerified;

  /// Profile section label: Account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// Profile section label: Support
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSectionSupport;

  /// Profile menu item: Edit Profile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// Profile menu item: My Shop
  ///
  /// In en, this message translates to:
  /// **'My Shop'**
  String get profileMyShop;

  /// Profile menu item: Order History
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get profileOrderHistory;

  /// Profile menu item: Active Bids
  ///
  /// In en, this message translates to:
  /// **'Active Bids'**
  String get profileActiveBids;

  /// Profile menu item: Saved Items
  ///
  /// In en, this message translates to:
  /// **'Saved Items'**
  String get profileSavedItems;

  /// Profile menu item: Language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// Profile support item: Help Center
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get profileHelpCenter;

  /// Profile support item: Privacy Policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyPolicy;

  /// Profile support item: App Version
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get profileAppVersion;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogOut;

  /// Guest mode profile title
  ///
  /// In en, this message translates to:
  /// **'Sign in to Mustamal'**
  String get profileGuestTitle;

  /// Guest mode profile subtitle
  ///
  /// In en, this message translates to:
  /// **'Access your profile, track orders, and manage your listings.'**
  String get profileGuestSub;

  /// Out of stock label on product card
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get homeOutOfStock;

  /// Empty products state text
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get homeNoProducts;

  /// Snackbar/mode tile: browse auctions
  ///
  /// In en, this message translates to:
  /// **'Browse Auctions'**
  String get homeBrowseAuctions;

  /// Snackbar/mode tile: browse used market
  ///
  /// In en, this message translates to:
  /// **'Browse Used Market'**
  String get homeBrowseUsed;

  /// Post action sheet: create shop option
  ///
  /// In en, this message translates to:
  /// **'Create a Shop'**
  String get postCreateShop;

  /// Post action sheet: create shop subtitle
  ///
  /// In en, this message translates to:
  /// **'Start your own e-commerce business'**
  String get postCreateShopSub;

  /// Post action sheet: add product option
  ///
  /// In en, this message translates to:
  /// **'Add Shop Product'**
  String get postAddProduct;

  /// Post action sheet: add product subtitle
  ///
  /// In en, this message translates to:
  /// **'List a new item in your existing shop'**
  String get postAddProductSub;

  /// Create auction page AppBar title
  ///
  /// In en, this message translates to:
  /// **'Create Auction'**
  String get auctionCreateTitle;

  /// Create auction page header title
  ///
  /// In en, this message translates to:
  /// **'Host an Auction'**
  String get auctionHostTitle;

  /// Create auction page header subtitle
  ///
  /// In en, this message translates to:
  /// **'Let the bidders decide the value of your item in real-time.'**
  String get auctionHostSub;

  /// Create auction form field: title
  ///
  /// In en, this message translates to:
  /// **'Auction Title'**
  String get auctionFieldTitle;

  /// Create auction form field: description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get auctionFieldDescription;

  /// Create auction form field: start price
  ///
  /// In en, this message translates to:
  /// **'Start Price'**
  String get auctionFieldStartPrice;

  /// Create auction form field: reserve price
  ///
  /// In en, this message translates to:
  /// **'Reserve Price'**
  String get auctionFieldReservePrice;

  /// Validation message for required field
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get auctionFieldRequired;

  /// Create auction duration section label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get auctionDuration;

  /// Create auction start time label
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get auctionStarts;

  /// Create auction end time label
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get auctionEnds;

  /// Create auction placeholder when no time selected
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get auctionSelectTime;

  /// Validation error when times not selected
  ///
  /// In en, this message translates to:
  /// **'Please select start and end times'**
  String get auctionSelectTimesError;

  /// Snackbar after creating an auction
  ///
  /// In en, this message translates to:
  /// **'Auction Created Successfully!'**
  String get auctionCreatedSuccess;

  /// Create auction submit button
  ///
  /// In en, this message translates to:
  /// **'Launch Auction'**
  String get auctionLaunchBtn;

  /// Order status: pending COD fulfillment
  ///
  /// In en, this message translates to:
  /// **'Pending COD Fulfillment'**
  String get statusPendingCODFulfillment;

  /// Order status: delivered and cash collected
  ///
  /// In en, this message translates to:
  /// **'Delivered And Cash Collected ✓'**
  String get statusDeliveredAndCashCollected;

  /// Warning message for banned users
  ///
  /// In en, this message translates to:
  /// **'Your account is banned due to 3 unpaid auction strikes. Contact support.'**
  String get bannedUserWarning;

  /// Warning message for users with strikes
  ///
  /// In en, this message translates to:
  /// **'You have {strikes}/3 unpaid auction strikes. Reaching 3 will result in an account ban.'**
  String strikesWarning(int strikes);

  /// Error message when seller wallet balance is insufficient for COD
  ///
  /// In en, this message translates to:
  /// **'Your balance is insufficient to cover the COD commission. Please top up your wallet first.'**
  String get insufficientWalletError;

  /// FAB sheet: sell used item (Mustamal)
  ///
  /// In en, this message translates to:
  /// **'Sell a Used Item'**
  String get postSellUsed;

  /// FAB sheet: sell used item subtitle
  ///
  /// In en, this message translates to:
  /// **'List for free — buyers contact via chat'**
  String get postSellUsedSub;

  /// FAB sheet: sell balla option
  ///
  /// In en, this message translates to:
  /// **'Sell Bulk / Thrift'**
  String get postSellBalla;

  /// FAB sheet: sell balla subtitle
  ///
  /// In en, this message translates to:
  /// **'Sell by piece, kg, or bundle'**
  String get postSellBallaSub;

  /// Button label to open WhatsApp/chat with seller
  ///
  /// In en, this message translates to:
  /// **'Contact Seller'**
  String get whatsappChat;

  /// Balla unit price row in checkout
  ///
  /// In en, this message translates to:
  /// **'{price} IQD ({qty} {unit})'**
  String checkoutUnitFormat(String price, String qty, String unit);

  /// Home feed section header: trending auctions
  ///
  /// In en, this message translates to:
  /// **'Live Auctions 🔴'**
  String get homeSectionAuctions;

  /// Home feed section header: Matajir retail products
  ///
  /// In en, this message translates to:
  /// **'New in Stores 🏬'**
  String get homeSectionMatajir;

  /// Home feed section header: Mustamal used items
  ///
  /// In en, this message translates to:
  /// **'Mustamal Deals 🤝'**
  String get homeSectionMustamal;

  /// Home feed section header: Balla bulk items
  ///
  /// In en, this message translates to:
  /// **'Balla Treasures 📦'**
  String get homeSectionBalla;

  /// See all link on retail sections
  ///
  /// In en, this message translates to:
  /// **'Shop All'**
  String get shopAll;

  /// Escrow wallet balance label with amount
  ///
  /// In en, this message translates to:
  /// **'Balance: {amount}'**
  String walletBalance(String amount);

  /// Omnibox / global search hint text
  ///
  /// In en, this message translates to:
  /// **'What are you looking for today?'**
  String get omniboxHint;

  /// Tagline for Mazad in home bento grid
  ///
  /// In en, this message translates to:
  /// **'Live Bidding'**
  String get miniAppMazadTagline;

  /// Tagline for Matajir in home bento grid
  ///
  /// In en, this message translates to:
  /// **'Official Shops'**
  String get miniAppMatajirTagline;

  /// Tagline for Mustamal in home bento grid
  ///
  /// In en, this message translates to:
  /// **'Used Market'**
  String get miniAppMustamalTagline;

  /// Tagline for Balla in home bento grid
  ///
  /// In en, this message translates to:
  /// **'Bulk Market'**
  String get miniAppBallaTagline;

  /// Matajir Mini-App AppBar title
  ///
  /// In en, this message translates to:
  /// **'Official Stores 🏬'**
  String get matajirTitle;

  /// Balla Mini-App AppBar title
  ///
  /// In en, this message translates to:
  /// **'Balla Market 📦'**
  String get ballaTitle;

  /// Bento grid card: Mazad auctions
  ///
  /// In en, this message translates to:
  /// **'Mazad'**
  String get miniAppMazad;

  /// Bento grid card: Mustamal used market
  ///
  /// In en, this message translates to:
  /// **'Mustamal'**
  String get miniAppMustamal;

  /// Bento grid card: Matajir official stores
  ///
  /// In en, this message translates to:
  /// **'Matajir'**
  String get miniAppMatajir;

  /// Bento grid card: Balla bulk market
  ///
  /// In en, this message translates to:
  /// **'Balla'**
  String get miniAppBalla;

  /// Cart page title when context is Matajir
  ///
  /// In en, this message translates to:
  /// **'Matajir Cart'**
  String get cartTitleMatajir;

  /// Cart page title when context is Balla
  ///
  /// In en, this message translates to:
  /// **'Balla Cart'**
  String get cartTitleBalla;

  /// Cart conflict bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Different Store!'**
  String get cartConflictTitle;

  /// Cart conflict bottom sheet explanation message
  ///
  /// In en, this message translates to:
  /// **'You already have items from a different store in your cart. You can keep your current cart or clear it and add the new item.'**
  String get cartConflictMessage;

  /// Cart conflict: keep existing cart option
  ///
  /// In en, this message translates to:
  /// **'Keep Current Cart'**
  String get cartConflictKeep;

  /// Cart conflict: clear cart and add new item option
  ///
  /// In en, this message translates to:
  /// **'Clear & Add New Item'**
  String get cartConflictClear;

  /// Search bar placeholder in Mustamal page
  ///
  /// In en, this message translates to:
  /// **'Search for phones, cars, furniture...'**
  String get mustamalSearchHint;

  /// Badge shown on used item cards
  ///
  /// In en, this message translates to:
  /// **'Pre-owned'**
  String get mustamalUsedBadge;

  /// Button on Mustamal cards to view item detail
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get mustamalViewDetails;

  /// Fallback title when a Mustamal listing has no title
  ///
  /// In en, this message translates to:
  /// **'No Title'**
  String get mustamalNoTitle;

  /// FAB / AppBar button to create a new Mustamal listing
  ///
  /// In en, this message translates to:
  /// **'Sell +'**
  String get mustamalSellButton;

  /// Inline tap to change location in Mustamal page
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get mustamalLocationChange;

  /// Location filter chip for listings near user
  ///
  /// In en, this message translates to:
  /// **'Near Me'**
  String get mustamalNearMe;

  /// Section header for nearby listings
  ///
  /// In en, this message translates to:
  /// **'Nearest to You'**
  String get mustamalNearbyTitle;

  /// Section header for the full category list
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get mustamalAllCategories;

  /// AppBar title on the detail screen
  ///
  /// In en, this message translates to:
  /// **'Listing Details'**
  String get mustamalDetailTitle;

  /// Badge shown when price is negotiable
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get mustamalNegotiable;

  /// Safety reminder shown on listing detail
  ///
  /// In en, this message translates to:
  /// **'Don\'t pay before receiving — use Luqta Escrow for protection'**
  String get mustamalSafetyBanner;

  /// Primary CTA on detail page — opens WhatsApp
  ///
  /// In en, this message translates to:
  /// **'Contact Seller via WhatsApp'**
  String get mustamalContactWhatsapp;

  /// Secondary action: open in-app chat with seller
  ///
  /// In en, this message translates to:
  /// **'Message in App'**
  String get mustamalInAppChat;

  /// Secondary action: call seller directly
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get mustamalCallSeller;

  /// Section header for similar items carousel
  ///
  /// In en, this message translates to:
  /// **'Similar Listings'**
  String get mustamalSimilarListings;

  /// Section header on detail page for map/location
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get mustamalLocationTitle;

  /// Section header for item description on detail page
  ///
  /// In en, this message translates to:
  /// **'Listing Description'**
  String get mustamalDescriptionTitle;

  /// Section header for seller card on detail page
  ///
  /// In en, this message translates to:
  /// **'Seller Info'**
  String get mustamalSellerTitle;

  /// Fallback subtitle on announcement carousel banner
  ///
  /// In en, this message translates to:
  /// **'Exclusive offers awaiting you'**
  String get carouselPromoSubtitle;

  /// Delivery fulfillment option label in checkout
  ///
  /// In en, this message translates to:
  /// **'Delivery\n(5,000 IQD)'**
  String get checkoutDeliveryOption;

  /// Store pickup fulfillment option label in checkout
  ///
  /// In en, this message translates to:
  /// **'Pick Up In-Store\n(Free)'**
  String get checkoutPickupOption;

  /// Order status: cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// Label for total price in order history card
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get orderTotalAmount;

  /// Item count in order history card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} item} other{{count} items}}'**
  String orderItemCount(int count);

  /// Empty state message in order history
  ///
  /// In en, this message translates to:
  /// **'No orders yet.'**
  String get orderHistoryEmpty;

  /// Section title for delivery vs pickup choice in checkout
  ///
  /// In en, this message translates to:
  /// **'Fulfillment Method'**
  String get checkoutFulfillmentMethod;

  /// Trust bar text in Matajir
  ///
  /// In en, this message translates to:
  /// **'All stores verified by Luqta ✓'**
  String get matajirTrustBar;

  /// Section header for verified stores
  ///
  /// In en, this message translates to:
  /// **'Verified Stores'**
  String get matajirVerifiedStores;

  /// Section header for featured products
  ///
  /// In en, this message translates to:
  /// **'Featured Products'**
  String get matajirFeaturedProducts;

  /// Search bar placeholder in Matajir
  ///
  /// In en, this message translates to:
  /// **'Search for a product or store...'**
  String get matajirSearchHint;

  /// Promo banner title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Deals'**
  String get matajirPromoToday;

  /// View all link
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get matajirViewAll;

  /// Matajir bottom nav: Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get matajirNavHome;

  /// Matajir bottom nav: Stores/Categories
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get matajirNavStores;

  /// Matajir bottom nav: Cart
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get matajirNavCart;

  /// Matajir bottom nav: Orders
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get matajirNavOrders;

  /// Categories page section header
  ///
  /// In en, this message translates to:
  /// **'Featured Categories'**
  String get matajirCategories;

  /// Popular stores section header
  ///
  /// In en, this message translates to:
  /// **'Popular Stores'**
  String get matajirPopularStores;

  /// All categories section header
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get matajirAllCategories;

  /// Verified store badge text
  ///
  /// In en, this message translates to:
  /// **'Verified by Luqta'**
  String get matajirVerifiedBadge;

  /// Add to cart button
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get matajirAddToCart;

  /// Already in cart button state
  ///
  /// In en, this message translates to:
  /// **'In Cart'**
  String get matajirInCart;

  /// Checkout button text
  ///
  /// In en, this message translates to:
  /// **'Complete Order'**
  String get matajirCompleteOrder;

  /// Sales count suffix
  ///
  /// In en, this message translates to:
  /// **'sales'**
  String get matajirSalesCount;

  /// Store products section header
  ///
  /// In en, this message translates to:
  /// **'Store Products'**
  String get matajirStoreProducts;

  /// Category filter: All
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get matajirFilterAll;

  /// Category: Electronics
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get matajirCatElectronics;

  /// Category: Clothing
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get matajirCatClothing;

  /// Category: Mobiles
  ///
  /// In en, this message translates to:
  /// **'Mobiles'**
  String get matajirCatMobiles;

  /// Category: Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get matajirCatHome;

  /// Category: Sports
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get matajirCatSports;

  /// Category: Furniture
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get matajirCatFurniture;

  /// Category: Auto Parts
  ///
  /// In en, this message translates to:
  /// **'Auto Parts'**
  String get matajirCatCars;

  /// Category: Books
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get matajirCatBooks;

  /// Category: Phones & Tablets
  ///
  /// In en, this message translates to:
  /// **'Phones & Tablets'**
  String get matajirCatPhones;

  /// Category: Laptops
  ///
  /// In en, this message translates to:
  /// **'Laptops'**
  String get matajirCatLaptops;

  /// Category: TVs
  ///
  /// In en, this message translates to:
  /// **'TVs'**
  String get matajirCatTVs;

  /// Category: Home Appliances
  ///
  /// In en, this message translates to:
  /// **'Home Appliances'**
  String get matajirCatAppliances;

  /// Category: Fashion
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get matajirCatFashion;

  /// Empty state for stores
  ///
  /// In en, this message translates to:
  /// **'No stores yet'**
  String get matajirNoStores;

  /// Cart items count suffix
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get matajirCartItems;

  /// No description provided for @matajirStoreCount.
  ///
  /// In en, this message translates to:
  /// **'{count} verified stores in Iraq'**
  String matajirStoreCount(int count);
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

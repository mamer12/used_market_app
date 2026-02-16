// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مستعمل';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'ابدأ التصفّح';

  @override
  String get onboardingTitle1 => 'اشترِ بثقة';

  @override
  String get onboardingDesc1 => 'كل إعلان موثّق. تسوّق بأمان.';

  @override
  String get onboardingTitle2 => 'بيع في دقائق';

  @override
  String get onboardingDesc2 => 'صوّر، حدّد السعر، وخلّص.';

  @override
  String get onboardingTitle3 => 'مزادات حية';

  @override
  String get onboardingDesc3 => 'زايد بشكل مباشر على منتجات حصرية.';

  @override
  String get loginWelcomeTo => 'أهلاً في';

  @override
  String get loginPhoneNumber => 'رقم الهاتف';

  @override
  String get loginPhoneHint => '7XX XXX XXXX';

  @override
  String get loginContinue => 'متابعة';

  @override
  String get loginOr => 'أو';

  @override
  String get loginContinueGoogle => 'المتابعة مع Google';

  @override
  String get loginTerms => 'بالمتابعة، أنت توافق على شروط الاستخدام';

  @override
  String get loginPhoneEmpty => 'الرجاء إدخال رقم الهاتف';

  @override
  String get loginPhoneInvalid => 'رقم هاتف غير صالح';

  @override
  String get homeSearch => 'ابحث في مستعمل...';

  @override
  String get homeCategories => 'الأقسام';

  @override
  String get homeLiveNow => 'مباشر الآن';

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get homeLive => 'مباشر';

  @override
  String get categoryMobile => 'موبايل';

  @override
  String get categoryCars => 'سيارات';

  @override
  String get categoryFurniture => 'أثاث';

  @override
  String get categoryJobs => 'وظائف';

  @override
  String get categoryRealEstate => 'عقارات';

  @override
  String get categoryElectronics => 'إلكترونيات';

  @override
  String get categoryFashion => 'أزياء';

  @override
  String get categoryMore => 'المزيد';

  @override
  String get bannerTitle1 => 'صفقات اليوم 🔥';

  @override
  String get bannerSub1 => 'خصم يصل إلى 70%!';

  @override
  String get bannerTitle2 => 'وصل حديثاً 📦';

  @override
  String get bannerSub2 => 'إعلانات جديدة اليوم';

  @override
  String get bannerTitle3 => 'مزاد مباشر 🔨';

  @override
  String get bannerSub3 => 'زايد الآن!';

  @override
  String bidders(int count) {
    return '$count مزايدين';
  }

  @override
  String get authSheetTitle => 'سجّل دخولك للمتابعة';

  @override
  String get authSheetSubtitle => 'تحتاج تسجيل الدخول لتنفيذ هذا الإجراء.';

  @override
  String get authGetCode => 'أرسل الرمز';

  @override
  String get authVerifyTitle => 'أدخل رمز التحقق';

  @override
  String get authCodeSentTo => 'تم إرسال الرمز إلى';

  @override
  String get authVerifyCode => 'تحقق';

  @override
  String get authChangeNumber => 'تغيير الرقم';
}

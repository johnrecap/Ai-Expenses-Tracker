// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'متتبع المصروفات';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get send => 'إرسال';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get confirm => 'تأكيد';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get syncQueued => 'بانتظار المزامنة';

  @override
  String get syncSyncing => 'تتم المزامنة';

  @override
  String get syncFailed => 'فشلت المزامنة';

  @override
  String get syncPendingOffline => 'ستتم المزامنة عند عودة الإنترنت.';

  @override
  String get syncPendingAuth => 'سجّل الدخول مرة أخرى لإكمال المزامنة.';

  @override
  String get syncPendingServer =>
      'مزامنة الخادم غير متاحة. أعد المحاولة عند عودتها.';

  @override
  String get syncPendingValidation =>
      'بعض التغييرات تحتاج مراجعة قبل المزامنة.';

  @override
  String get syncPendingQueued => 'تمت إضافته إلى قائمة المزامنة.';

  @override
  String get syncPendingUnknown =>
      'المزامنة بانتظار المعالجة. أعد المحاولة بعد قليل.';

  @override
  String syncPendingCount(int count, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصروفات $status',
      one: 'مصروف واحد $status',
    );
    return '$_temp0';
  }

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get settings => 'الإعدادات';

  @override
  String get expenses => 'المصروفات';

  @override
  String get filters => 'الفلاتر';

  @override
  String get searchExpenses => 'ابحث في المصروفات';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا توجد نتائج',
    );
    return '$_temp0';
  }

  @override
  String get expenseResultsLimitedToLoadedHistory =>
      'النتائج محدودة بالسجل الحديث المحمل. حمل المزيد أو اختر نطاق تاريخ لتوسيعها.';

  @override
  String get expenseResultsLimitedToDateRange =>
      'النتائج محدودة بالصفحة المحملة لنطاق التاريخ هذا.';

  @override
  String get loadMoreExpenses => 'تحميل المزيد';

  @override
  String get loadingMoreExpenses => 'جاري تحميل المزيد';

  @override
  String get allLoadedExpensesShown => 'يتم عرض كل المصروفات المحملة';

  @override
  String get noExpensesMatchFilters => 'لا توجد مصروفات تطابق الفلاتر';

  @override
  String get expenseDetailsSeparator => '•';

  @override
  String get expenseActions => 'إجراءات المصروف';

  @override
  String get editExpense => 'تعديل المصروف';

  @override
  String get quickAmountAdjustment => 'تعديل سريع للمبلغ';

  @override
  String get adjustmentAmount => 'مبلغ التعديل';

  @override
  String get addToAmount => 'إضافة';

  @override
  String get subtractFromAmount => 'خصم';

  @override
  String get invalidExpenseAdjustment =>
      'أدخل تعديلًا يجعل المبلغ النهائي أكبر من صفر.';

  @override
  String get expenseUpdated => 'تم تحديث المصروف';

  @override
  String get failedToUpdateExpense => 'تعذر تحديث المصروف. حاول مرة أخرى.';

  @override
  String get deleteExpenseTitle => 'حذف المصروف؟';

  @override
  String deleteExpenseMessage(String category, String amount, String date) {
    return 'هل تريد حذف مصروف $category بقيمة $amount بتاريخ $date؟';
  }

  @override
  String get expenseDeleted => 'تم حذف المصروف';

  @override
  String get failedToDeleteExpense => 'تعذر حذف المصروف. حاول مرة أخرى.';

  @override
  String get categories => 'الفئات';

  @override
  String get amount => 'المبلغ';

  @override
  String get min => 'الحد الأدنى';

  @override
  String get max => 'الحد الأقصى';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get currency => 'العملة';

  @override
  String get applyFilters => 'تطبيق الفلاتر';

  @override
  String get dateRange => 'نطاق التاريخ';

  @override
  String get anyDate => 'أي تاريخ';

  @override
  String get clearDates => 'مسح التواريخ';

  @override
  String get pickDates => 'اختيار التواريخ';

  @override
  String get welcome => 'مرحبًا';

  @override
  String get thisMonthSpending => 'مصروفات هذا الشهر';

  @override
  String get budgetLeft => 'المتبقي من الميزانية';

  @override
  String get budget => 'الميزانية';

  @override
  String get setMonthlyBudget => 'حدد ميزانية شهرية';

  @override
  String get topCategory => 'أعلى فئة';

  @override
  String get noSpendingYet => 'لا توجد مصروفات بعد';

  @override
  String get transactions => 'المعاملات';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get noExpensesYet => 'لا توجد مصروفات بعد';

  @override
  String get home => 'الرئيسية';

  @override
  String get stats => 'الإحصائيات';

  @override
  String get aiAssistant => 'المساعد الذكي';

  @override
  String get recurringExpenses => 'المصروفات المتكررة';

  @override
  String get savingGoals => 'أهداف الادخار';

  @override
  String get exportData => 'تصدير البيانات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get quickCaptureQuick => 'سريع';

  @override
  String get quickCaptureNatural => 'نص';

  @override
  String get quickCaptureReceipt => 'إيصال';

  @override
  String get quickCaptureMoreDetails => 'مزيد من التفاصيل';

  @override
  String get quickCaptureLessDetails => 'تفاصيل أقل';

  @override
  String get quickCaptureDraftReady => 'تم ملء المسودة. راجع الحقول ثم احفظ.';

  @override
  String get quickCaptureReceiptTitle => 'مسح إيصال';

  @override
  String get quickCaptureReceiptHelper =>
      'تفاصيل الإيصال تملأ نفس النموذج القابل للتعديل. الحفظ لا يتم إلا بزر الحفظ.';

  @override
  String get quickCaptureReceiptApplied =>
      'تم ملء مسودة الإيصال. راجع الحقول ثم احفظ.';

  @override
  String get quickCaptureReceiptReview => 'راجع حقول الإيصال قبل الحفظ.';

  @override
  String quickCaptureMissingFields(String fields) {
    return 'أكمل الحقول الناقصة: $fields.';
  }

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String get category => 'الفئة';

  @override
  String get description => 'الوصف';

  @override
  String get merchant => 'التاجر';

  @override
  String get tags => 'الوسوم';

  @override
  String get tagsHelper => 'افصل الوسوم بفواصل';

  @override
  String get possibleDuplicateExpense => 'مصروف مكرر محتمل';

  @override
  String possibleDuplicateExpenseMessage(
    String amount,
    String currency,
    String category,
    String date,
    String reasons,
  ) {
    return 'يوجد مصروف مشابه: $amount $currency، $category، $date. الأسباب: $reasons. هل تريد الحفظ على أي حال؟';
  }

  @override
  String get saveAnyway => 'الحفظ على أي حال';

  @override
  String get duplicateReasonSameDay => 'نفس اليوم';

  @override
  String get duplicateReasonSameAmount => 'نفس المبلغ';

  @override
  String get duplicateReasonSameCategory => 'نفس الفئة';

  @override
  String get duplicateReasonSameMerchant => 'نفس التاجر';

  @override
  String get date => 'التاريخ';

  @override
  String get noActiveCategoriesYet => 'لا توجد فئات نشطة بعد';

  @override
  String get enterValidExpenseAmount => 'أدخل مبلغ مصروف صحيح';

  @override
  String get selectCategoryBeforeSaving => 'اختر فئة قبل الحفظ';

  @override
  String get failedToSaveExpense => 'تعذر حفظ المصروف. حاول مرة أخرى.';

  @override
  String get failedToSaveCategory => 'تعذر حفظ الفئة. حاول مرة أخرى.';

  @override
  String get failedToLoadCategories => 'تعذر تحميل الفئات';

  @override
  String get categoryBudgets => 'ميزانيات الفئات';

  @override
  String get subscriptionCenter => 'مركز الاشتراكات';

  @override
  String get confirmLogoutTitle => 'تسجيل الخروج؟';

  @override
  String get confirmLogoutMessage =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى للوصول إلى مصروفاتك.';

  @override
  String get failedToLoadExpenses => 'تعذر تحميل المصروفات';

  @override
  String get checkConnectionTryAgain => 'تحقق من الاتصال ثم حاول مرة أخرى.';

  @override
  String get cash => 'نقدًا';

  @override
  String get visa => 'فيزا';

  @override
  String get wallet => 'محفظة';

  @override
  String get bankTransfer => 'تحويل بنكي';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get authenticatedAccount => 'الحساب المسجل';

  @override
  String get profileSettingsDescription =>
      'إدارة الملف المحلي وتفاصيل تسجيل الدخول وإجراءات الحساب.';

  @override
  String get profileFallbackUser => 'المستخدم';

  @override
  String get profileName => 'اسم الملف الشخصي';

  @override
  String get editProfileName => 'تعديل اسم الملف الشخصي';

  @override
  String get displayNameLabel => 'الاسم المعروض';

  @override
  String get displayNameHint => 'أدخل الاسم الذي يظهر داخل التطبيق';

  @override
  String get displayNameRequired => 'أدخل اسما للعرض.';

  @override
  String get displayNameTooLong => 'يجب ألا يزيد الاسم عن 60 حرفا.';

  @override
  String get displayNameUpdated => 'تم تحديث الاسم المعروض.';

  @override
  String get displayNameUpdateFailed => 'تعذر تحديث الاسم. حاول مرة أخرى.';

  @override
  String get accountId => 'معرف الحساب';

  @override
  String get copyAccountId => 'نسخ معرف الحساب';

  @override
  String get accountIdCopied => 'تم نسخ معرف الحساب.';

  @override
  String get accountProfileTitle => 'الحساب/الملف';

  @override
  String get accountProfileLoadFailed => 'تعذر تحميل ملف الحساب.';

  @override
  String get accountEmail => 'البريد الإلكتروني';

  @override
  String get accountEmailMissing => 'لا يوجد بريد إلكتروني لهذا الحساب';

  @override
  String get accountProvider => 'مزود تسجيل الدخول';

  @override
  String get accountProviderEmailPassword => 'البريد وكلمة المرور';

  @override
  String get accountProviderGoogle => 'Google';

  @override
  String get accountProviderUnknown => 'المزود غير متاح';

  @override
  String get accountActionUnavailableForProvider =>
      'هذا الإجراء غير متاح لمزود تسجيل الدخول الحالي.';

  @override
  String get accountPasswordReset => 'إعادة تعيين كلمة المرور';

  @override
  String get accountPasswordResetDescription =>
      'إرسال رسالة إعادة تعيين كلمة المرور إلى هذا الحساب.';

  @override
  String get accountPasswordResetSent =>
      'تم إرسال رسالة إعادة تعيين كلمة المرور.';

  @override
  String get accountPasswordResetFailed =>
      'تعذر إرسال رسالة إعادة تعيين كلمة المرور.';

  @override
  String get accountUpdateEmail => 'تحديث البريد';

  @override
  String get accountUpdateEmailDescription =>
      'تغيير البريد المستخدم لهذا الحساب.';

  @override
  String get accountNewEmail => 'البريد الجديد';

  @override
  String get accountEmailInvalid => 'أدخل بريدا إلكترونيا صحيحا.';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'تسجيل';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get enterEmailAddress => 'أدخل بريدك الإلكتروني.';

  @override
  String get enterPassword => 'أدخل كلمة المرور.';

  @override
  String get passwordMinLength => 'يجب ألا تقل كلمة المرور عن 6 أحرف.';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get accountEmailUpdated => 'تم تحديث البريد.';

  @override
  String get accountEmailUpdateFailed => 'تعذر تحديث البريد.';

  @override
  String get accountReauthRequired =>
      'سجل الدخول مرة أخرى قبل تغيير هذا الإعداد الحساس.';

  @override
  String get accountReauthTitle => 'تسجيل الدخول مرة أخرى';

  @override
  String get accountReauthPasswordDescription =>
      'أدخل كلمة المرور الحالية، ثم سيعيد التطبيق محاولة إجراء الحساب.';

  @override
  String get accountReauthGoogleDescription =>
      'تابع باستخدام Google، ثم سيعيد التطبيق محاولة إجراء الحساب.';

  @override
  String get accountReauthPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get accountReauthGoogleButton => 'متابعة باستخدام Google';

  @override
  String get accountReauthSucceeded =>
      'تم تأكيد تسجيل الدخول. جار إعادة محاولة إجراء الحساب.';

  @override
  String get accountReauthFailed => 'تعذر تأكيد تسجيل الدخول.';

  @override
  String get accountReauthCanceled => 'تم إلغاء تأكيد تسجيل الدخول.';

  @override
  String get accountReauthUnavailable =>
      'تأكيد تسجيل الدخول غير متاح لهذا المزود.';

  @override
  String get accountDeleteTitle => 'حذف الحساب';

  @override
  String get accountDeleteShortDescription =>
      'حذف حسابك وبيانات التطبيق المملوكة لك.';

  @override
  String get accountDeleteWarning =>
      'يطلب هذا حذف حسابك ومصروفاتك وفئاتك وميزانياتك والمصروفات المتكررة وأهداف الادخار والإعدادات وسجل إجراءات الذكاء الاصطناعي نهائيا. لا يمكن التراجع عن ذلك.';

  @override
  String get accountDeleteConfirmCheckbox =>
      'أفهم أن هذا الحذف لا يمكن التراجع عنه.';

  @override
  String get accountDeleteButton => 'حذف الحساب';

  @override
  String get accountDeleteConfirmationRequired => 'أكد التحذير قبل حذف حسابك.';

  @override
  String get accountDataDeleteFailed =>
      'تعذر حذف بيانات حسابك. لم يتم حذف حساب تسجيل الدخول.';

  @override
  String get accountAuthDeleteFailed =>
      'تم طلب حذف بيانات التطبيق، لكن تعذر حذف حساب تسجيل الدخول.';

  @override
  String get accountDeleted => 'تم حذف الحساب.';

  @override
  String get accountDeleteFailed => 'تعذر إكمال حذف الحساب.';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get appLanguageDescription =>
      'تتحكم اللغة في نصوص التطبيق والتواريخ ولغة الذكاء الاصطناعي والإملاء الصوتي، ولا تغير العملة.';

  @override
  String get languageSystem => 'النظام';

  @override
  String get languageSystemDescription =>
      'اتبع لغة الجهاز عندما تكون العربية أو الإنجليزية.';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageArabicDescription =>
      'استخدم النص العربي واتجاه العرض من اليمين إلى اليسار.';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageEnglishDescription =>
      'استخدم النص الإنجليزي واتجاه العرض من اليسار إلى اليمين.';

  @override
  String get failedToLoadSettings => 'تعذر تحميل الإعدادات.';

  @override
  String get baseCurrency => 'العملة الأساسية';

  @override
  String get supportedCurrencies => 'العملات المدعومة';

  @override
  String get currencySettingsDescription =>
      'اللغة والعملة مستقلتان. تستخدم العملة الأساسية كافتراضي للإدخال اليدوي والذكاء الاصطناعي. أسعار الصرف تحول إجماليات لوحة التحكم فقط.';

  @override
  String get exchangeRates => 'أسعار الصرف';

  @override
  String get exchangeRatesDescription =>
      'أدخل قيمة وحدة واحدة من كل عملة بعملتك الأساسية.';

  @override
  String exchangeRateInputLabel(String currency) {
    return '1 $currency =';
  }

  @override
  String get exchangeRateInvalid => 'أدخل سعر صرف أكبر من صفر.';

  @override
  String get exchangeRateSaved => 'تم حفظ سعر الصرف.';

  @override
  String convertedCurrenciesStatus(String currencies) {
    return 'تم التحويل: $currencies';
  }

  @override
  String unconvertedCurrenciesStatus(int count, String currencies) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لا توجد أسعار صرف لـ $currencies؛ لم يتم احتساب $count مصروفات',
      one: 'لا يوجد سعر صرف لـ $currencies؛ لم يتم احتساب مصروف واحد',
    );
    return '$_temp0';
  }

  @override
  String get settingsUnavailableTitle => 'تحتاج الإعدادات إلى مراجعة';

  @override
  String get settingsUnavailableMessage =>
      'أعد تحميل الإعدادات أو اختر العملة وطريقة الدفع قبل الحفظ.';

  @override
  String get chooseCurrencyAndPaymentBeforeSaving =>
      'اختر العملة وطريقة الدفع قبل الحفظ.';

  @override
  String get settingsLoadRequiredForAi =>
      'تعذر تحميل الإعدادات. أعد المحاولة قبل استخدام الذكاء الاصطناعي حتى لا يتم تخمين العملة وطريقة الدفع.';

  @override
  String get aiQuotaUnavailable =>
      'حد استخدام الذكاء الاصطناعي غير متاح حاليًا.';

  @override
  String get aiQuotaExhausted => 'استخدمت حد الذكاء الاصطناعي لهذا اليوم.';

  @override
  String get aiCouldNotUnderstand =>
      'لم أتمكن من فهم الطلب. جرّب إضافة المبلغ والفئة والتاريخ.';

  @override
  String get aiProviderUnavailable =>
      'خدمة الذكاء الاصطناعي غير متاحة. حاول لاحقًا.';

  @override
  String get aiFormFillTitle => 'املأ بالذكاء الاصطناعي';

  @override
  String get aiFormFillHint => 'مثال: صرفت 100 دولار على أكل امبارح';

  @override
  String get aiFormFillHelper =>
      'الذكاء الاصطناعي يملأ النموذج فقط. راجع واضغط حفظ بنفسك.';

  @override
  String get aiFormFillAction => 'ملء';

  @override
  String get aiFormFillApplied =>
      'تم ملء النموذج بالذكاء الاصطناعي. راجع قبل الحفظ.';

  @override
  String get aiFormFillFailed =>
      'تعذر ملء النموذج بالذكاء الاصطناعي. يمكنك إدخاله يدويًا.';

  @override
  String get aiFormFillNeedsReview =>
      'يحتاج الذكاء الاصطناعي لمراجعة إضافية. أكمل النموذج يدويًا.';

  @override
  String get no => 'لا';

  @override
  String get notificationsSettingsTitle => 'الإشعارات';

  @override
  String get budgetAlerts => 'تنبيهات الميزانية';

  @override
  String get budgetAlertsDescription =>
      'نبهني عند اقتراب المصروفات من الميزانية أو تجاوزها.';

  @override
  String get dailyCheckIn => 'مراجعة يومية';

  @override
  String get dailyCheckInDescription =>
      'راجع مصروفات اليوم وحافظ على الاستمرارية.';

  @override
  String get checkInTime => 'وقت المراجعة';

  @override
  String get weeklyDigest => 'ملخص أسبوعي';

  @override
  String get weeklyDigestDescription => 'ذكرني بمراجعة ملخص الإنفاق الأسبوعي.';

  @override
  String get weeklyDigestEmpty => 'لا يوجد إنفاق مسجل لهذا الأسبوع بعد.';

  @override
  String get weeklyDigestThisWeek => 'هذا الأسبوع';

  @override
  String get weeklyDigestPreviousWeek => 'الأسبوع السابق';

  @override
  String get weeklyDigestChange => 'التغير';

  @override
  String get weeklyDigestLocalInsight => 'رؤية محلية';

  @override
  String weeklyDigestIgnoredCurrencyExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم تجاهل $count مصروف بعملات أخرى لعدم توفر أسعار صرف محفوظة.',
      many: 'تم تجاهل $count مصروفا بعملات أخرى لعدم توفر أسعار صرف محفوظة.',
      few: 'تم تجاهل $count مصروفات بعملات أخرى لعدم توفر أسعار صرف محفوظة.',
      two: 'تم تجاهل مصروفين بعملات أخرى لعدم توفر أسعار صرف محفوظة.',
      one: 'تم تجاهل مصروف بعملة أخرى لعدم توفر سعر صرف محفوظ.',
    );
    return '$_temp0';
  }

  @override
  String weeklyDigestHealthScore(String label, int score) {
    return '$label ($score/100)';
  }

  @override
  String get weeklyInsightStartLogging => 'ابدأ بتسجيل مصروف واحد هذا الأسبوع.';

  @override
  String weeklyInsightTopCategory(String category) {
    return '$category هي أكبر فئة هذا الأسبوع.';
  }

  @override
  String get weeklyInsightFirstTrackedWeek =>
      'هذا أول أسبوع مسجل في هذه المقارنة.';

  @override
  String get weeklyInsightHigherThanLastWeek =>
      'الإنفاق أعلى من الأسبوع السابق.';

  @override
  String get weeklyInsightLowerThanLastWeek => 'الإنفاق أقل من الأسبوع السابق.';

  @override
  String get weeklyInsightUnchanged => 'الإنفاق لم يتغير عن الأسبوع السابق.';

  @override
  String get spendingHealthAddFewExpenses => 'أضف بعض المصروفات';

  @override
  String get spendingHealthOnTrack => 'ضمن المسار';

  @override
  String get spendingHealthWorthWatching => 'يستحق المتابعة';

  @override
  String get spendingHealthNeedsReview => 'يحتاج مراجعة';

  @override
  String get spendingHealthReasonLogExpensesOrBudget =>
      'سجل مصروفات أو حدد ميزانية شهرية لعرض النتيجة.';

  @override
  String get spendingHealthReasonBudgetExceeded =>
      'تم تجاوز الميزانية الشهرية.';

  @override
  String get spendingHealthReasonBudgetNearLimit =>
      'الميزانية الشهرية قريبة من الحد.';

  @override
  String get spendingHealthReasonBudgetOnTrack =>
      'الميزانية الشهرية ضمن المسار.';

  @override
  String get spendingHealthReasonNoBudget => 'لا توجد ميزانية شهرية محددة.';

  @override
  String get spendingHealthReasonOneCategoryHigh =>
      'فئة واحدة تتجاوز 60% من إنفاق هذا الشهر.';

  @override
  String get spendingHealthReasonSpreadAcrossCategories =>
      'الإنفاق موزع على عدة فئات.';

  @override
  String get spendingHealthReasonTrackedToday =>
      'يوجد مصروف واحد على الأقل مسجل اليوم.';

  @override
  String get spendingHealthReasonRecentTracking => 'نشاط التتبع الأخير مستمر.';

  @override
  String get spendingHealthReasonNoRecentStreak =>
      'لا توجد سلسلة تتبع حديثة بعد.';

  @override
  String get digestTime => 'وقت الملخص';

  @override
  String get monday => 'الاثنين';

  @override
  String get appProtection => 'حماية التطبيق';

  @override
  String get pinLock => 'قفل PIN';

  @override
  String get pinLockDescription =>
      'اطلب PIN محلي عند فتح التطبيق أو الرجوع إليه.';

  @override
  String get changePin => 'تغيير PIN';

  @override
  String get createPin => 'إنشاء PIN';

  @override
  String get createPinIntro => 'احم بيانات مصروفاتك برمز PIN محلي.';

  @override
  String get changePinIntro => 'اختر PIN جديدا للتطبيق.';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPinLabel => 'تأكيد PIN';

  @override
  String get saveNewPin => 'حفظ PIN الجديد';

  @override
  String get enableAppLock => 'تفعيل قفل التطبيق';

  @override
  String get pinDigitsValidation => 'يجب أن يتكون PIN من 4 إلى 8 أرقام.';

  @override
  String get pinConfirmationMismatch => 'تأكيد PIN غير مطابق.';

  @override
  String get expenseTrackerLocked => 'Expense Tracker مقفل';

  @override
  String get enterPinToContinue => 'أدخل PIN للمتابعة.';

  @override
  String get unlock => 'فتح';

  @override
  String get useBiometrics => 'استخدام البصمة';

  @override
  String get failedToSavePin => 'تعذر حفظ PIN.';

  @override
  String get failedToChangePin => 'تعذر تغيير PIN.';

  @override
  String get failedToDisableAppLock => 'تعذر إيقاف قفل التطبيق.';

  @override
  String get biometricAuthenticationUnavailable =>
      'المصادقة بالبصمة غير متاحة.';

  @override
  String get failedToUpdateBiometricSetting => 'تعذر تحديث إعداد البصمة.';

  @override
  String get incorrectPin => 'PIN غير صحيح.';

  @override
  String get failedToUnlock => 'تعذر فتح القفل.';

  @override
  String get usePinToUnlock => 'استخدم PIN لفتح القفل.';

  @override
  String get failedToLoadAppLockSettings => 'تعذر تحميل إعدادات قفل التطبيق.';

  @override
  String get biometricUnlock => 'فتح بالبصمة';

  @override
  String get biometricUnlockAvailableDescription =>
      'استخدم البصمة أو Face ID عند توفره.';

  @override
  String get biometricUnlockUnavailableDescription =>
      'غير متاح على هذا الجهاز.';

  @override
  String get watchAdForExtraAiUse =>
      'شاهد إعلانًا لاستخدام إضافي للذكاء الاصطناعي';

  @override
  String get rewardUnavailable => 'المكافأة غير متاحة الآن.';

  @override
  String get extraAiUseAdded => 'تمت إضافة استخدام إضافي للذكاء الاصطناعي.';

  @override
  String get retentionStartSetupTitle => 'ابدأ الإعداد';

  @override
  String get retentionStartSetupMessage =>
      'أضف مصروفًا واحدًا، وأنشئ فئات، ثم حدد ميزانية.';

  @override
  String get retentionKeepStreakTitle => 'حافظ على السلسلة';

  @override
  String get retentionStartStreakMessage =>
      'سجل اليوم مرة واحدة لبدء سلسلة تتبع.';

  @override
  String retentionKeepStreakMessage(int days) {
    return 'سجل اليوم للحفاظ على سلسلة $days يوم.';
  }

  @override
  String get retentionLogExpenseAction => 'تسجيل مصروف';

  @override
  String get weeklyCheckIn => 'مراجعة أسبوعية';

  @override
  String get viewDigest => 'عرض الملخص';

  @override
  String get retentionBudgetReviewTitle => 'مراجعة الميزانية';

  @override
  String get retentionBudgetExceededMessage =>
      'ميزانيتك الشهرية تجاوزت الهدف. راجع المصروفات الأخيرة.';

  @override
  String get retentionReviewBudgetAction => 'مراجعة الميزانية';

  @override
  String get retentionBudgetNudgeTitle => 'تنبيه الميزانية';

  @override
  String get retentionBudgetNearLimitMessage =>
      'أنت قريب من حد الميزانية. راجع أعلى فئة.';

  @override
  String get retentionOpenBudgetAction => 'فتح الميزانية';

  @override
  String get retentionSetTargetTitle => 'حدد هدفًا بسيطًا';

  @override
  String get retentionSetTargetMessage =>
      'أضف ميزانية شهرية لتسهيل تتبع التقدم.';

  @override
  String get retentionSetBudgetAction => 'تحديد ميزانية';

  @override
  String get retentionThreeDayChallengeTitle => 'تحدي ثلاثة أيام';

  @override
  String get retentionThreeDayChallengeMessage =>
      'استمر في التسجيل لبقية الأسبوع.';

  @override
  String get continueAction => 'متابعة';

  @override
  String get streak => 'الاستمرارية';

  @override
  String get health => 'الحالة';

  @override
  String get trackedToday => 'تم التسجيل اليوم';

  @override
  String get checkIn => 'سجل اليوم';

  @override
  String get needsData => 'تحتاج بيانات';

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get aiUsageSettingsTitle => 'استخدام الذكاء الاصطناعي';

  @override
  String get aiUsageSettingsDescription =>
      'حدود يومية مجانية للذكاء الاصطناعي. الإدخال اليدوي والتقارير المحلية يستمران عند عدم توفره.';

  @override
  String get aiUsageTextParsing => 'تحليل النص';

  @override
  String get aiUsageReceiptExtraction => 'استخراج الإيصال';

  @override
  String get aiUsageFinancialAdvice => 'نصائح مالية';

  @override
  String aiUsageUsed(int used, int limit) {
    return '$used/$limit مستخدم';
  }

  @override
  String aiUsageResetsAround(String time) {
    return 'يتجدد تقريبًا عند $time';
  }

  @override
  String get aiUsageWaitingForLiveUsage =>
      'في انتظار الاستخدام المباشر من Worker';

  @override
  String aiUsageRemaining(int count) {
    return 'متبقي $count';
  }

  @override
  String get freePlan => 'الخطة المجانية';

  @override
  String get premiumPlan => 'الخطة المميزة';

  @override
  String get unknownPlan => 'خطة غير معروفة';

  @override
  String get pendingPlan => 'خطة قيد التحقق';

  @override
  String get loadingLivePlanState => 'جار تحميل حالة الخطة المباشرة...';

  @override
  String get adsDisabled => 'الإعلانات معطلة';

  @override
  String get viewLimitsAdsAndPremium => 'عرض الحدود والإعلانات والمميز';

  @override
  String get removeAds => 'إزالة الإعلانات';

  @override
  String get removeAdsDescription => 'قادمة مع إعداد شراء الخطة المميزة.';

  @override
  String get usingFreeSafePlanState => 'استخدام حالة مجانية آمنة';

  @override
  String get refreshPlanState => 'تحديث حالة الخطة';

  @override
  String get privacyAndAdChoices => 'اختيارات الخصوصية والإعلانات';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get privacySettingsDescription =>
      'مصروفاتك تبقى مرتبطة بحسابك في Firebase. إجراءات الذكاء الاصطناعي تحتاج معاينة وتأكيد قبل أي كتابة.';

  @override
  String get dataOwnership => 'ملكية البيانات';

  @override
  String get dataOwnershipDescription =>
      'حسابك المسجل فقط يمكنه الوصول إلى بياناتك.';

  @override
  String get support => 'الدعم';

  @override
  String get supportSettingsDescription =>
      'أرسل ملاحظات بدون إرفاق بيانات المصروفات.';

  @override
  String get sendFeedback => 'إرسال ملاحظات';

  @override
  String get sendFeedbackDescription => 'يتضمن إصدار التطبيق فقط إذا وافقت.';

  @override
  String get feedbackDiagnosticsPrompt =>
      'لن يتم تضمين أوصاف المصروفات أو الإيصالات أو رموز الحساب أو PIN أو تفاصيل مزود الذكاء الاصطناعي. هل تريد إضافة إصدار التطبيق 1.0.0+1؟';

  @override
  String get includeVersion => 'تضمين الإصدار';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get feedbackShareTemplate =>
      'ملاحظات Expense Tracker\n\nماذا حدث؟\n\nماذا كنت تتوقع؟';

  @override
  String get feedbackSubject => 'ملاحظات Expense Tracker';

  @override
  String get paymentSettingsTitle => 'الدفع';

  @override
  String get paymentSettingsDescription =>
      'تستخدم كطريقة افتراضية عندما لا يحدد المصروف اليدوي أو الذكاء الاصطناعي طريقة الدفع.';

  @override
  String get defaultPaymentMethod => 'طريقة الدفع الافتراضية';

  @override
  String get onboardingTitle => 'إعداد أول تشغيل';

  @override
  String get onboardingLoading => 'جار تحميل الإعداد';

  @override
  String get onboardingLoadFailed =>
      'تعذر تحميل إعداداتك. تحقق من الاتصال ثم حاول مرة أخرى.';

  @override
  String get onboardingSaveFailed =>
      'تعذر حفظ اختياراتك. أبقها محددة ثم حاول مرة أخرى.';

  @override
  String get onboardingSelectRequired =>
      'اختر اللغة والعملة الأساسية وطريقة الدفع الافتراضية للمتابعة.';

  @override
  String get onboardingContinue => 'متابعة';

  @override
  String get onboardingBack => 'رجوع';

  @override
  String get onboardingFinish => 'إنهاء الإعداد';

  @override
  String get onboardingComplete => 'اكتمل الإعداد';

  @override
  String get onboardingSkipReminders => 'تخطي التذكيرات';

  @override
  String get onboardingEssentialsTitle => 'اختر الأساسيات';

  @override
  String get onboardingEssentialsSubtitle =>
      'تتحكم هذه الاختيارات في لغة التطبيق والافتراضيات المستخدمة قبل حفظ أي مصروف.';

  @override
  String get onboardingLanguageLabel => 'اللغة';

  @override
  String get onboardingLanguageEnglish => 'الإنجليزية';

  @override
  String get onboardingLanguageArabic => 'العربية';

  @override
  String get onboardingCurrencyLabel => 'العملة الأساسية';

  @override
  String get onboardingPaymentLabel => 'طريقة الدفع الافتراضية';

  @override
  String get onboardingAiTitle => 'الذكاء الاصطناعي تحت تحكمك';

  @override
  String get onboardingAiSubtitle =>
      'يمكن للذكاء الاصطناعي مساعدتك في تجهيز المصروفات، لكن الإعداد لا يتصل بالمزود ولا يستهلك الحصة.';

  @override
  String get onboardingAiPreviewTitle => 'المعاينة أولاً';

  @override
  String get onboardingAiPreviewBody =>
      'تظهر اقتراحات الذكاء الاصطناعي للمراجعة، ولا يتم حفظ أي شيء حتى تؤكد.';

  @override
  String get onboardingAiLimitTitle => 'حدود يومية مجانية';

  @override
  String get onboardingAiLimitBody =>
      'للذكاء الاصطناعي حدود يومية مجانية وقد لا يكون متاحاً، لذلك لا يعتمد التطبيق عليه للتتبع اليدوي.';

  @override
  String get onboardingAiManualTitle => 'الإدخال اليدوي يعمل دائماً';

  @override
  String get onboardingAiManualBody =>
      'يمكنك إضافة المصروفات بنفسك حتى عند انتهاء حصة الذكاء الاصطناعي أو توقف البوابة.';

  @override
  String get onboardingAiSample =>
      'مثال فقط: \"غداء 12 USD بالمحفظة\". لا يتم إرسال هذا المثال إلى الذكاء الاصطناعي.';

  @override
  String get onboardingAiSampleSemantics =>
      'نص مثال للذكاء الاصطناعي لا يتم إرساله';

  @override
  String get onboardingReminderTitle => 'تذكيرات اختيارية';

  @override
  String get onboardingReminderSubtitle =>
      'يمكن أن تساعدك التذكيرات على الاستمرار في التتبع، لكنها اختيارية ويمكن تغييرها لاحقاً.';

  @override
  String get onboardingDailyReminder => 'تذكير يومي بالمصروفات';

  @override
  String get onboardingDailyReminderDescription =>
      'اطلب مراجعة سريعة للمصروفات مساءً إذا لم تسجل مصروفات اليوم.';

  @override
  String get onboardingWeeklyDigest => 'ملخص إنفاق أسبوعي';

  @override
  String get onboardingWeeklyDigestDescription =>
      'اعرض تذكير ملخص يوم الاثنين للملخص الأسبوعي ودرجة صحة الإنفاق.';

  @override
  String get onboardingReminderLater =>
      'إذا رُفض الإذن، يكتمل الإعداد وتبقى التذكيرات متوقفة.';

  @override
  String get onboardingReminderPermissionDenied =>
      'لم يتم تفعيل التذكيرات لأن إذن الإشعارات أو الجدولة غير متاح.';

  @override
  String get guidedTourNext => 'التالي';

  @override
  String get guidedTourBack => 'رجوع';

  @override
  String get guidedTourSkip => 'تخطي';

  @override
  String get guidedTourDone => 'تم';

  @override
  String get guidedTourReplayTour => 'إعادة الجولة';

  @override
  String guidedTourStepCount(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get guidedTourAiTitle => 'تعرف على المساعد الذكي';

  @override
  String get guidedTourAiBody =>
      'اكتب المصروف أو أمليه هنا. يعرض الذكاء الاصطناعي معاينة دائما قبل الحفظ.';

  @override
  String get guidedTourManualExpenseTitle => 'أضف المصروفات يدويا';

  @override
  String get guidedTourManualExpenseBody =>
      'استخدم زر الإضافة لفتح نموذج المصروف العادي. يمكن للذكاء الاصطناعي ملؤه من الأعلى، ويظل الحفظ خطوتك الأخيرة.';

  @override
  String get guidedTourAiPreviewTitle => 'راجع قبل الحفظ';

  @override
  String get guidedTourAiPreviewBody =>
      'اقتراحات الذكاء الاصطناعي لا تحفظ مباشرة. تحقق من المبلغ والفئة والتاريخ وطريقة الدفع قبل التأكيد.';

  @override
  String get guidedTourBudgetTitle => 'تابع ميزانيتك';

  @override
  String get guidedTourBudgetBody =>
      'الميزانيات الشهرية تشغل عرض المتبقي والتنبيهات والنصائح المبنية على مصروفاتك الحقيقية.';

  @override
  String get guidedTourReportsTitle => 'اقرأ تقارير حقيقية';

  @override
  String get guidedTourReportsBody =>
      'تلخص التقارير إنفاقك الفعلي حسب الأسبوع والشهر والفئة.';

  @override
  String get guidedTourCategoriesTitle => 'نظم الفئات';

  @override
  String get guidedTourCategoriesBody =>
      'افتح القائمة للفئات. يمكنك تعديل الأسماء والأيقونات والألوان وأرشفة الخيارات بأمان.';

  @override
  String get guidedTourSettingsTitle => 'اضبط الإعدادات';

  @override
  String get guidedTourSettingsBody =>
      'تجمع الإعدادات العملة والدفع والتنبيهات والحماية واستخدام الذكاء الاصطناعي والاشتراك والخصوصية.';

  @override
  String get guidedTourFreePremiumTitle => 'المجاني والمميز';

  @override
  String get guidedTourFreePremiumBody =>
      'الخطة المجانية تبقي التتبع اليدوي متاحا. خيارات المميز والإعلانات والحدود موجودة في الإعدادات دون مقاطعة إدخال المصروفات.';

  @override
  String get guidedTourSettingsSectionTitle => 'الإرشاد';

  @override
  String get guidedTourSettingsSectionDescription =>
      'أعد تشغيل الجولة الإرشادية لإصدار التطبيق الحالي.';

  @override
  String get guidedTourReplayTourDescription =>
      'اعرض جولة الصفحة الرئيسية مرة أخرى.';

  @override
  String get archive => 'أرشفة';

  @override
  String get clear => 'مسح';

  @override
  String get close => 'إغلاق';

  @override
  String get parse => 'تحليل';

  @override
  String get add => 'إضافة';

  @override
  String get week => 'أسبوع';

  @override
  String get month => 'شهر';

  @override
  String get required => 'مطلوب';

  @override
  String get export => 'تصدير';

  @override
  String get shareFile => 'مشاركة الملف';

  @override
  String get allCurrencies => 'كل العملات';

  @override
  String get pickRange => 'اختيار النطاق';

  @override
  String get selectDateRangeBeforeExporting => 'اختر نطاق تاريخ قبل التصدير.';

  @override
  String exportReady(String fileName) {
    return 'التصدير جاهز: $fileName';
  }

  @override
  String get reports => 'التقارير';

  @override
  String get activeReportDrilldownFilter => 'فلتر تفصيل التقرير نشط';

  @override
  String get monthlyStoryTitle => 'قصة الشهر';

  @override
  String get monthlyStoryEmpty =>
      'لم يتم تسجيل إنفاق في هذا الشهر أو الشهر السابق.';

  @override
  String monthlyStoryNewSpending(String current) {
    return 'إنفاق هذا الشهر هو $current، ولا يوجد إنفاق في الشهر السابق للمقارنة بعد.';
  }

  @override
  String monthlyStoryIncrease(String current, String previous, int percent) {
    return 'ارتفع الإنفاق إلى $current من $previous، بزيادة $percent%.';
  }

  @override
  String monthlyStoryDecrease(String current, String previous, int percent) {
    return 'تحسن الإنفاق إلى $current من $previous، بانخفاض $percent%.';
  }

  @override
  String monthlyStoryFlat(String current, String previous) {
    return 'ظل الإنفاق قريبًا من الشهر السابق: $current الآن مقابل $previous سابقًا.';
  }

  @override
  String get monthlyStoryDriversHeading => 'أهم المحركات';

  @override
  String monthlyStoryDriver(String category, String amount, int percent) {
    return '$category: $amount، حوالي $percent% من هذا الشهر.';
  }

  @override
  String get monthlyStoryOutliersHeading => 'مصروفات كبيرة';

  @override
  String monthlyStoryOutlier(String expense, String amount) {
    return '$expense: $amount';
  }

  @override
  String monthlyStoryMissingRateCaveat(int count, String currencies) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'تستبعد هذه القصة $count مصروفات بسبب أسعار صرف مفقودة لـ $currencies.',
      one: 'تستبعد هذه القصة مصروفًا واحدًا بسبب سعر صرف مفقود لـ $currencies.',
    );
    return '$_temp0';
  }

  @override
  String get noSpendingInThisPeriod => 'لا يوجد إنفاق في هذه الفترة.';

  @override
  String get noCategorySpendingYet => 'لا يوجد إنفاق حسب الفئات بعد.';

  @override
  String get none => 'لا شيء';

  @override
  String topCategoryLabel(String category) {
    return 'أعلى فئة: $category';
  }

  @override
  String ignoredOtherCurrencyExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم تجاهل $count مصروفات بعملات أخرى.',
      one: 'تم تجاهل مصروف واحد بعملة أخرى.',
    );
    return '$_temp0';
  }

  @override
  String get periodComparison => 'مقارنة الفترة';

  @override
  String currentAmountLabel(String amount) {
    return 'الحالي: $amount';
  }

  @override
  String previousAmountLabel(String amount) {
    return 'السابق: $amount';
  }

  @override
  String get daily => 'يومي';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get frequency => 'التكرار';

  @override
  String get newRecurring => 'تكرار جديد';

  @override
  String get editRecurringExpense => 'تعديل مصروف متكرر';

  @override
  String get archiveRecurringExpense => 'أرشفة مصروف متكرر';

  @override
  String archiveRecurringExpenseMessage(String name) {
    return 'هل تريد أرشفة $name؟';
  }

  @override
  String get createActiveCategoryBeforeRecurring =>
      'أنشئ فئة نشطة قبل إضافة مصروفات متكررة.';

  @override
  String get noActiveRecurringExpensesYet => 'لا توجد مصروفات متكررة نشطة بعد';

  @override
  String nextDateLabel(String date) {
    return 'التالي $date';
  }

  @override
  String get enterRecurringAmountAndCategory => 'أدخل المبلغ والفئة.';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get noEndDate => 'بدون تاريخ انتهاء';

  @override
  String get clearEndDate => 'مسح تاريخ الانتهاء';

  @override
  String get savingGoalsTitle => 'أهداف الادخار';

  @override
  String get newSavingGoal => 'هدف ادخار جديد';

  @override
  String get editSavingGoal => 'تعديل هدف الادخار';

  @override
  String get goalName => 'اسم الهدف';

  @override
  String get targetAmount => 'المبلغ المستهدف';

  @override
  String get currentAmount => 'المبلغ الحالي';

  @override
  String get deadline => 'الموعد النهائي';

  @override
  String get noDeadline => 'بدون موعد نهائي';

  @override
  String get clearDeadline => 'مسح الموعد النهائي';

  @override
  String get addContribution => 'إضافة مساهمة';

  @override
  String get contributionAmount => 'مبلغ المساهمة';

  @override
  String addContributionToGoal(String goal) {
    return 'إضافة إلى $goal';
  }

  @override
  String get archiveSavingGoal => 'أرشفة هدف الادخار';

  @override
  String archiveSavingGoalMessage(String goal) {
    return 'هل تريد أرشفة $goal؟';
  }

  @override
  String get noActiveSavingGoalsYet => 'لا توجد أهداف ادخار نشطة بعد';

  @override
  String get enterSavingGoalNameAndTarget =>
      'أدخل اسمًا ومبلغًا مستهدفًا موجبًا.';

  @override
  String get currentAmountCannotBeNegative =>
      'لا يمكن أن يكون المبلغ الحالي سالبًا.';

  @override
  String get goalReached => 'تم الوصول إلى الهدف';

  @override
  String remainingAmountLabel(String amount) {
    return 'متبقي $amount';
  }

  @override
  String savedPercentLabel(String percent) {
    return 'تم ادخار $percent%';
  }

  @override
  String deadlineDateLabel(String date) {
    return 'الموعد النهائي $date';
  }

  @override
  String get freePremiumTitle => 'المجاني / المميز';

  @override
  String planRefreshFailedFreeSafe(String message) {
    return 'تعذر تحديث الخطة، لذلك تظهر حدود الخطة المجانية الآمنة. يظل تتبع المصروفات اليدوي متاحًا. $message';
  }

  @override
  String get premiumStillWorks =>
      'الخطة المميزة تزيل الإعلانات وترفع الحدود. يظل التتبع اليدوي هو التجربة الأساسية.';

  @override
  String get freeStillWorks =>
      'الخطة المجانية تُبقي المصروفات اليدوية والفئات والميزانيات والتقارير الأساسية والتصدير والمزامنة دون اتصال عاملة حتى عند انتهاء حصة الذكاء الاصطناعي.';

  @override
  String get adsOnFree => 'إعلانات في المجاني';

  @override
  String get premiumAdsDisabledBody =>
      'يجب ألا يبدأ التطبيق الإعلانات أو يطلبها أثناء تفعيل الخطة المميزة.';

  @override
  String get freeAdsBody =>
      'الإعلانات مخصصة لمواضع لافتات هادئة أو لحظات إكمال طبيعية. لا تقاطع إضافة المصروف أو معاينة الذكاء الاصطناعي أو تسجيل الدخول أو قفل التطبيق أو الشراء.';

  @override
  String consentStatusLabel(String status) {
    return 'الموافقة: $status';
  }

  @override
  String get todayAiUsage => 'استخدام الذكاء الاصطناعي اليوم';

  @override
  String get textParse => 'تحليل النص';

  @override
  String get receipts => 'الإيصالات';

  @override
  String get advice => 'النصائح';

  @override
  String leftByDefault(int count) {
    return 'متبقي $count افتراضيًا';
  }

  @override
  String leftCount(int count) {
    return 'متبقي $count';
  }

  @override
  String get showingPolicyDefaultsUntilWorker =>
      'تظهر افتراضات السياسة حتى يعيد Worker الاستخدام المباشر.';

  @override
  String resetsAroundWithPeriod(String time) {
    return 'يتجدد تقريبًا عند $time.';
  }

  @override
  String get free => 'مجاني';

  @override
  String get premium => 'مميز';

  @override
  String get included => 'مشمول';

  @override
  String get manualTracking => 'التتبع اليدوي';

  @override
  String get aiTextParse => 'تحليل النص بالذكاء الاصطناعي';

  @override
  String get higherFiniteLimit => 'حد أعلى ومحدد';

  @override
  String get moreReceipts => 'إيصالات أكثر';

  @override
  String get moreAdvice => 'نصائح أكثر';

  @override
  String get ads => 'الإعلانات';

  @override
  String get politeAds => 'إعلانات هادئة';

  @override
  String get noAds => 'بدون إعلانات';

  @override
  String get reportsExport => 'التقارير/التصدير';

  @override
  String get basic => 'أساسي';

  @override
  String get advancedLater => 'تقارير متقدمة وقوالب تصدير وميزانيات ذكية';

  @override
  String get premiumIsActive => 'الخطة المميزة نشطة';

  @override
  String get premiumActiveBody =>
      'تم تعطيل الإعلانات وتفعيل صلاحيات الخطة المميزة.';

  @override
  String get premiumComingSoon => 'الخطة المميزة قادمة قريبًا';

  @override
  String get premiumPurchasesDisabledBody =>
      'المشتريات غير مفعلة بعد لأن تحقق الخادم غير منشور. لن يزيف التطبيق اشتراكًا أو يخصم منك من هذه الشاشة.';

  @override
  String get checkAvailability => 'التحقق من الإتاحة';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get readinessComingSoonLabel => 'قريبًا';

  @override
  String get readinessDisabledLabel => 'غير متاح الآن';

  @override
  String get premiumRestoreDisabledBody =>
      'استعادة المشتريات متوقفة حتى يتم توفير تحقق موثوق من الاستحقاقات على الخادم.';

  @override
  String get premiumBackendVerificationUnavailable =>
      'الاشتراكات المدفوعة غير مفعلة لأن التحقق الخلفي غير مهيأ بعد.';

  @override
  String get walletsReadinessBody =>
      'إدارة المحافظ ستبقى غير مفعلة حتى تكتمل قائمة المحافظ، الإنشاء، التعديل، الأرشفة، وربط المصروفات.';

  @override
  String get transfersReadinessBody =>
      'التحويلات ستبقى غير مفعلة حتى يكتمل نموذج التحويل وسياسة العملات، وستظل منفصلة عن المصروفات.';

  @override
  String get backupExportTitle => 'نسخ احتياطي';

  @override
  String get backupExportReadinessBody =>
      'تصدير النسخ الاحتياطي غير متاح من الواجهة حتى يكتمل تجميع البيانات بأمان.';

  @override
  String get restorePreviewTitle => 'معاينة الاستعادة';

  @override
  String get restorePreviewReadinessBody =>
      'الاستعادة تحتاج معاينة للتغييرات وتأكيدًا صريحًا قبل أي تعديل في البيانات.';

  @override
  String get restoreExecutionTitle => 'تنفيذ الاستعادة';

  @override
  String get restoreExecutionReadinessBody =>
      'تنفيذ الاستعادة متوقف عمدًا حتى توجد سياسة تعارضات واختبارات كتابة للمستودعات.';

  @override
  String get aiInputExampleHint => 'مثال: صرفت 250 جنيه على أكل أمس بالكاش';

  @override
  String get receipt => 'إيصال';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get receiptImageReadFailed =>
      'تعذر قراءة صورة الإيصال. أضف المصروف يدويًا.';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get reviewBeforeSaving => 'راجع قبل الحفظ';

  @override
  String get newCategoryName => 'اسم الفئة الجديدة';

  @override
  String get confirmingCreatesCategoryFirst =>
      'سيتم إنشاء هذه الفئة أولًا عند التأكيد.';

  @override
  String suggestedNewCategory(String category) {
    return 'فئة جديدة مقترحة: $category';
  }

  @override
  String matchedCategory(String category) {
    return 'فئة مطابقة: $category';
  }

  @override
  String sourceLabel(String source) {
    return 'المصدر: $source';
  }

  @override
  String confidenceLabel(int percent) {
    return 'الثقة: $percent%';
  }

  @override
  String get aiCategoryId => 'معرّف فئة الذكاء الاصطناعي';

  @override
  String get aiCategoryName => 'اسم فئة الذكاء الاصطناعي';

  @override
  String get categoryAlias => 'اسم بديل للفئة';

  @override
  String get recentHistory => 'السجل الحديث';

  @override
  String get newCategorySuggestion => 'اقتراح فئة جديدة';

  @override
  String get manualSelection => 'اختيار يدوي';

  @override
  String get noMatch => 'لا يوجد تطابق';

  @override
  String get failedToCreateAiSuggestedCategory =>
      'تعذر إنشاء الفئة المقترحة بالذكاء الاصطناعي.';

  @override
  String get createCategoryBeforeSavingRecurrence =>
      'أنشئ فئة قبل حفظ التكرار.';

  @override
  String get recurringExpenseSuggestionSaved =>
      'تم حفظ اقتراح المصروف المتكرر.';

  @override
  String get failedToSaveAiExpense =>
      'تعذر حفظ مصروف الذكاء الاصطناعي. حاول مرة أخرى.';

  @override
  String get pleaseAddMoreDetails => 'أضف مزيدًا من التفاصيل.';

  @override
  String get couldNotParseExpense => 'تعذر تحليل هذا المصروف.';

  @override
  String get searchReady => 'البحث جاهز';

  @override
  String get readyToOpenFilteredExpenses => 'جاهز لفتح المصروفات المفلترة.';

  @override
  String get openResults => 'فتح النتائج';

  @override
  String get historyAnswer => 'السجل';

  @override
  String get historySourceLocal => 'المصدر: سجل محلي محسوب';

  @override
  String get historyNoMatchingExpenses =>
      'لا توجد مصروفات محملة تطابق سؤال السجل هذا.';

  @override
  String historyMatchingExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصروف مطابق.',
      many: '$count مصروفًا مطابقًا.',
      few: '$count مصروفات مطابقة.',
      two: 'مصروفان مطابقان.',
      one: 'مصروف واحد مطابق.',
    );
    return '$_temp0';
  }

  @override
  String get historyMutationReadOnly =>
      'إجابات السجل للقراءة فقط. استخدم مسار المعاينة والتأكيد الحالي لإجراء التغييرات.';

  @override
  String get summary => 'الملخص';

  @override
  String totalAmountLabel(String amount) {
    return 'الإجمالي: $amount';
  }

  @override
  String topCategoryWithAmount(String category, String amount) {
    return 'أعلى فئة: $category ($amount)';
  }

  @override
  String ignoredOtherCurrencyExpensesBecause(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم تجاهل $count مصروفات لأنها تستخدم عملة أخرى.',
      one: 'تم تجاهل مصروف واحد لأنه يستخدم عملة أخرى.',
    );
    return '$_temp0';
  }

  @override
  String get financialAdvice => 'نصيحة مالية';

  @override
  String get localAdviceFallback => 'بديل النصائح المحلي';

  @override
  String get aiFinancialAdvice => 'نصيحة مالية بالذكاء الاصطناعي';

  @override
  String aiAdviceEvidenceTotal(String amount, String currency) {
    return 'الإجمالي: $amount $currency';
  }

  @override
  String aiAdviceEvidenceTopCategory(
    String category,
    String amount,
    String currency,
  ) {
    return 'أعلى فئة: $category ($amount $currency)';
  }

  @override
  String aiAdviceEvidenceBudgetUsed(String percent) {
    return 'المستخدم من الميزانية: $percent%';
  }

  @override
  String aiAdviceEvidenceConvertedCurrencies(String currencies) {
    return 'عملات تم تحويلها: $currencies';
  }

  @override
  String aiAdviceEvidenceMissingRates(String currencies, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لم يتم تضمين $count مصروف',
      many: 'لم يتم تضمين $count مصروفا',
      few: 'لم يتم تضمين $count مصروفات',
      two: 'لم يتم تضمين مصروفين',
      one: 'لم يتم تضمين مصروف واحد',
    );
    return 'أسعار صرف غير متوفرة لـ $currencies؛ $_temp0';
  }

  @override
  String get aiAdviceNoSpending =>
      'لا يوجد إنفاق في هذه الفترة. استمر في تسجيل المصروفات لتصبح النصائح أدق.';

  @override
  String aiAdviceOverBudget(String category) {
    return 'تجاوزت الميزانية. راجع $category أولا وأوقف الإنفاق غير الضروري حتى الفترة التالية.';
  }

  @override
  String get aiAdviceOverBudgetFallback =>
      'تجاوزت الميزانية. راجع أكبر فئة أولا وأوقف الإنفاق غير الضروري حتى الفترة التالية.';

  @override
  String aiAdviceNearLimit(String category) {
    return 'أنت قريب من حد الميزانية. اجعل المشتريات القادمة صغيرة وراقب $category.';
  }

  @override
  String get aiAdviceNearLimitFallback =>
      'أنت قريب من حد الميزانية. اجعل المشتريات القادمة صغيرة وراقب أعلى فئة.';

  @override
  String aiAdviceFocusCategory(String category) {
    return 'بالنسبة إلى $category، قارن كل عملية شراء بخطتك قبل الإنفاق مرة أخرى هذه الفترة.';
  }

  @override
  String aiAdviceTopCategory(String category) {
    return 'أعلى إنفاق لديك في $category. حدد لها سقفا أصغر وانقل المشتريات المتكررة إلى أيام مخططة.';
  }

  @override
  String get aiAdviceStable =>
      'إنفاقك مستقر في هذه الفترة. واصل مراجعة الإجماليات قبل إضافة مصروفات غير ضرورية.';

  @override
  String aiAdviceRequestsLeftToday(int count) {
    return 'متبقي $count طلب نصيحة ذكاء اصطناعي اليوم.';
  }

  @override
  String get aiNeedsReview => 'الذكاء الاصطناعي يحتاج مراجعة';

  @override
  String get aiUnavailable => 'الذكاء الاصطناعي غير متاح';

  @override
  String get providerAiUnavailableManualStillWorks =>
      'الذكاء الاصطناعي عبر المزود غير متاح. يظل الإدخال اليدوي والرؤى المحلية تعمل.';

  @override
  String get localSpendingPrediction => 'توقع إنفاق محلي';

  @override
  String expectedThisMonth(String amount) {
    return 'المتوقع هذا الشهر: $amount';
  }

  @override
  String get repeatedExpenseFound => 'تم العثور على مصروف متكرر';

  @override
  String repeatedExpenseLooksFrequency(String description, String frequency) {
    return '$description يبدو $frequency.';
  }

  @override
  String matchingExpensesAverage(int count, String amount) {
    return '$count مصروفات مطابقة، بمتوسط $amount.';
  }

  @override
  String get reviewRecurring => 'مراجعة التكرار';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get confirmUpdate => 'تأكيد التعديل';

  @override
  String get chooseExactExpenseFirst => 'اختر المصروف المحدد أولًا.';

  @override
  String get update => 'تحديث';

  @override
  String get target => 'الهدف';

  @override
  String get after => 'بعد التعديل';

  @override
  String get preparingVoiceInput => 'جارٍ تجهيز الإدخال الصوتي...';

  @override
  String get listeningVoiceInput =>
      'يتم الاستماع. دعم التوقف المؤقت يعتمد على جهازك.';

  @override
  String get createCategory => 'إنشاء فئة';

  @override
  String get editCategory => 'تعديل الفئة';

  @override
  String get archiveCategory => 'أرشفة الفئة';

  @override
  String archiveCategoryMessage(String category) {
    return 'أرشفة $category؟ ستظل المصروفات القديمة تعرضها.';
  }

  @override
  String get categoryCreated => 'تم إنشاء الفئة.';

  @override
  String get categoryUpdated => 'تم تحديث الفئة.';

  @override
  String get categoryArchived => 'تمت أرشفة الفئة.';

  @override
  String get failedToCreateCategory => 'تعذر إنشاء الفئة.';

  @override
  String get failedToUpdateCategory => 'تعذر تحديث الفئة.';

  @override
  String get failedToArchiveCategory => 'تعذر أرشفة الفئة.';

  @override
  String get selectCategoryToArchive => 'اختر فئة لأرشفتها.';

  @override
  String get enterCategoryNameIconColor => 'أدخل اسم الفئة والأيقونة واللون.';

  @override
  String get categoryName => 'الاسم';

  @override
  String get categoryIcon => 'الأيقونة';

  @override
  String get selectedCategoryIcon => 'أيقونة الفئة المحددة';

  @override
  String get categoryColor => 'اللون';

  @override
  String get customColor => 'لون مخصص';

  @override
  String get saveColor => 'حفظ اللون';

  @override
  String get searchIcons => 'البحث في الأيقونات';

  @override
  String categoryIconSemantics(String label) {
    return 'أيقونة $label';
  }

  @override
  String categoryColorSemantics(String label) {
    return 'لون $label';
  }

  @override
  String categoryExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصروف',
      many: '$count مصروفًا',
      few: '$count مصروفات',
      two: 'مصروفان',
      one: 'مصروف واحد',
      zero: 'لا توجد مصروفات',
    );
    return '$_temp0';
  }

  @override
  String get monthlyBudgetTitle => 'الميزانية الشهرية';

  @override
  String get budgetAmount => 'مبلغ الميزانية';

  @override
  String get saveBudget => 'حفظ الميزانية';

  @override
  String get enterValidBudgetAmount => 'أدخل مبلغ ميزانية صحيحًا.';

  @override
  String get warningThresholdRange => 'يجب أن تكون نسبة التنبيه بين 1 و100.';

  @override
  String get failedToLoadBudget => 'تعذر تحميل الميزانية.';

  @override
  String get failedToSaveBudget => 'تعذر حفظ الميزانية.';

  @override
  String get budgetSetAction => 'تحديد';

  @override
  String get budgetNoBudgetSet => 'لا توجد ميزانية لهذا الشهر.';

  @override
  String get budgetSpentLabel => 'المصروف';

  @override
  String get budgetRemainingLabel => 'المتبقي';

  @override
  String budgetPercentOfLimit(String percent, String amount) {
    return '$percent% من $amount';
  }

  @override
  String get budgetExceededWarning => 'تم تجاوز الميزانية.';

  @override
  String get budgetNearLimitWarning => 'أنت قريب من حد الميزانية.';

  @override
  String budgetIgnoredCurrencyExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم استبعاد $count مصروف بعملات أخرى لعدم توفر أسعار صرف محفوظة.',
      many: 'تم استبعاد $count مصروفا بعملات أخرى لعدم توفر أسعار صرف محفوظة.',
      few: 'تم استبعاد $count مصروفات بعملات أخرى لعدم توفر أسعار صرف محفوظة.',
      two: 'تم استبعاد مصروفين بعملات أخرى لعدم توفر أسعار صرف محفوظة.',
      one: 'تم استبعاد مصروف بعملة أخرى لعدم توفر سعر صرف محفوظ.',
    );
    return '$_temp0';
  }

  @override
  String get categoryBudgetsCreateCategoryFirst =>
      'أنشئ فئة نشطة قبل ميزانيات الفئات.';

  @override
  String get categoryBudgetsLoadFailed => 'تعذر تحميل ميزانيات الفئات.';

  @override
  String get categoryBudgetSaved => 'تم حفظ ميزانية الفئة.';

  @override
  String get categoryBudgetSaveFailed => 'تعذر حفظ ميزانية الفئة.';

  @override
  String get categoryBudgetArchived => 'تمت أرشفة ميزانية الفئة.';

  @override
  String get categoryBudgetArchiveFailed => 'تعذر أرشفة ميزانية الفئة.';

  @override
  String get selectCategoryBudgetToArchive => 'اختر ميزانية فئة لأرشفتها.';

  @override
  String get archiveCategoryBudget => 'أرشفة ميزانية الفئة';

  @override
  String archiveCategoryBudgetMessage(String category) {
    return 'أرشفة ميزانية $category؟';
  }

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get nextMonth => 'الشهر التالي';

  @override
  String get noCategoryBudgetsYet => 'لا توجد ميزانيات فئات بعد';

  @override
  String get addCategoryBudget => 'إضافة ميزانية فئة';

  @override
  String get editCategoryBudget => 'تعديل ميزانية الفئة';

  @override
  String get limitAmount => 'حد الميزانية';

  @override
  String get warningThresholdPercent => 'نسبة التنبيه';

  @override
  String get budgetRecommendationTitle => 'ميزانية شهرية مقترحة';

  @override
  String budgetRecommendationMeta(String confidence, String period) {
    return 'ثقة $confidence - $period';
  }

  @override
  String get budgetRecommendationMonthlyExplanation =>
      'استنادا إلى الإنفاق الشهري الحديث واتجاهه.';

  @override
  String budgetRecommendationCategoryExplanation(String category) {
    return 'استنادا إلى إنفاق $category الحديث واتجاهه.';
  }

  @override
  String get useEditableRecommendation => 'استخدام الاقتراح القابل للتعديل';

  @override
  String get categoryBudgetRecommendationsTitle => 'ميزانيات فئات مقترحة';

  @override
  String categoryBudgetRecommendationSubtitle(
    String amount,
    String confidence,
  ) {
    return '$amount - ثقة $confidence';
  }

  @override
  String get recommendationConfidenceHigh => 'مرتفعة';

  @override
  String get recommendationConfidenceMedium => 'متوسطة';

  @override
  String get recommendationConfidenceLow => 'منخفضة';

  @override
  String get recommendationCaveatSparseHistory =>
      'السجل المحدود يجعل هذا تقديرا حذرا.';

  @override
  String get recommendationCaveatOutlierMonth =>
      'تم تخفيف تأثير شهر غير معتاد في التقدير.';

  @override
  String get recommendationCaveatMissingRates =>
      'تم استبعاد مصروفات تنقصها أسعار الصرف.';

  @override
  String get recommendationCaveatExistingBudget =>
      'لديك ميزانية هنا بالفعل؛ راجعها قبل استبدالها.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent من $limit';
  }

  @override
  String budgetRemainingAmount(String amount) {
    return 'المتبقي $amount';
  }

  @override
  String categoryBudgetIgnoredCurrencyExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم تجاهل $count مصروف بسبب العملة',
      many: 'تم تجاهل $count مصروفًا بسبب العملة',
      few: 'تم تجاهل $count مصروفات بسبب العملة',
      two: 'تم تجاهل مصروفين بسبب العملة',
      one: 'تم تجاهل مصروف واحد بسبب العملة',
    );
    return '$_temp0';
  }

  @override
  String get selectCategory => 'اختر فئة.';

  @override
  String get selectMonth => 'اختر شهرًا.';

  @override
  String get selectCurrency => 'اختر عملة.';

  @override
  String get enterValidBudgetLimit => 'أدخل حد ميزانية صحيح.';

  @override
  String get manageRecurringExpenses => 'إدارة المصروفات المتكررة';

  @override
  String get failedToLoadSubscriptions => 'تعذر تحميل الاشتراكات.';

  @override
  String get estimatedMonthlyImpact => 'الأثر الشهري التقديري';

  @override
  String get subscriptionMixedCurrencyCaveat =>
      'تبقى الإجماليات مفصولة حسب العملة حتى تتم مراجعة تحويل الاشتراكات.';

  @override
  String get dailyMonthlyImpactEstimateCaveat =>
      'يتم تقدير الاشتراكات اليومية على أساس 30 تجديدا في الشهر.';

  @override
  String get weeklyMonthlyImpactEstimateCaveat =>
      'يتم تقدير الاشتراكات الأسبوعية على أساس 52 تجديدا على 12 شهرا.';

  @override
  String get upcomingRenewals => 'التجديدات القادمة';

  @override
  String renewsOn(Object date) {
    return 'يتجدد $date';
  }

  @override
  String get possiblePriceChanges => 'تغييرات سعر محتملة';

  @override
  String possiblePriceIncrease(Object previous, Object current) {
    return 'زيادة محتملة من $previous إلى $current';
  }

  @override
  String get cautiousSignal => 'إشارة حذرة';

  @override
  String get activeSubscriptions => 'الاشتراكات النشطة';

  @override
  String subscriptionNextDue(
    String frequency,
    String paymentMethod,
    String date,
  ) {
    return '$frequency - $paymentMethod - التالي $date';
  }

  @override
  String monthlyImpactSuffix(String amount) {
    return '$amount/شهريًا';
  }

  @override
  String get noActiveSubscriptionsYet => 'لا توجد اشتراكات نشطة بعد';

  @override
  String get exportEndDateBeforeStart =>
      'يجب أن يكون تاريخ النهاية في نفس يوم البداية أو بعدها.';

  @override
  String get exportCurrencyFilterEmpty => 'يجب ألا يكون فلتر العملة فارغًا.';

  @override
  String get exportPdfTitle => 'تصدير المصروفات';

  @override
  String exportPdfPeriod(String startDate, String endDate) {
    return 'الفترة: $startDate - $endDate';
  }

  @override
  String exportPdfTotal(String total) {
    return 'الإجمالي: $total';
  }

  @override
  String get exportHeaderDate => 'التاريخ';

  @override
  String get exportHeaderAmount => 'المبلغ';

  @override
  String get exportHeaderCurrency => 'العملة';

  @override
  String get exportHeaderCategory => 'الفئة';

  @override
  String get exportHeaderPaymentMethod => 'طريقة الدفع';

  @override
  String get exportHeaderDescription => 'الوصف';

  @override
  String get exportHeaderConvertedAmount => 'المبلغ المحول';

  @override
  String get exportHeaderConvertedCurrency => 'عملة التحويل';

  @override
  String get exportHeaderConversionRate => 'سعر الصرف';

  @override
  String get exportHeaderConversionRateDate => 'تاريخ سعر الصرف';

  @override
  String get exportHeaderConversionStatus => 'حالة التحويل';

  @override
  String get exportConversionStatusOriginal => 'أصلي';

  @override
  String get exportConversionStatusConverted => 'تم التحويل';

  @override
  String get exportConversionStatusMissingRate => 'سعر غير متاح';

  @override
  String exportPdfConvertedTotal(String total) {
    return 'الإجمالي المحول: $total';
  }

  @override
  String exportPdfMissingRates(String currencies, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لا توجد أسعار صرف لـ $currencies؛ لم يتم احتساب $count صف.',
      many: 'لا توجد أسعار صرف لـ $currencies؛ لم يتم احتساب $count صفا.',
      few: 'لا توجد أسعار صرف لـ $currencies؛ لم يتم احتساب $count صفوف.',
      two: 'لا توجد أسعار صرف لـ $currencies؛ لم يتم احتساب صفين.',
      one: 'لا يوجد سعر صرف لـ $currencies؛ لم يتم احتساب صف واحد.',
    );
    return '$_temp0';
  }

  @override
  String get exportArabicFontMissing =>
      'يحتاج تصدير PDF إلى خط العربية المدمج قبل التشغيل. أضف assets/fonts/NotoSansArabic-Regular.ttf ثم أعد توليد الأصول.';

  @override
  String get wallets => 'المحافظ';

  @override
  String get walletAccount => 'حساب المحفظة';

  @override
  String get walletType => 'نوع المحفظة';

  @override
  String get openingBalance => 'الرصيد الافتتاحي';

  @override
  String get archiveWallet => 'أرشفة المحفظة';

  @override
  String get transfers => 'التحويلات';

  @override
  String get transfer => 'تحويل';

  @override
  String get sourceWallet => 'المحفظة المصدر';

  @override
  String get destinationWallet => 'المحفظة الوجهة';

  @override
  String get transferFee => 'رسوم التحويل';

  @override
  String get feeWallet => 'محفظة الرسوم';
}

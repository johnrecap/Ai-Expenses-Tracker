// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expense Tracker';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get retry => 'Retry';

  @override
  String get reset => 'Reset';

  @override
  String get settings => 'Settings';

  @override
  String get expenses => 'Expenses';

  @override
  String get filters => 'Filters';

  @override
  String get searchExpenses => 'Search expenses';

  @override
  String get clearSearch => 'Clear search';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get expenseResultsLimitedToLoadedHistory =>
      'Results are limited to loaded recent history. Load more or choose a date range to widen them.';

  @override
  String get expenseResultsLimitedToDateRange =>
      'Results are limited to the loaded page for this date range.';

  @override
  String get loadMoreExpenses => 'Load more';

  @override
  String get loadingMoreExpenses => 'Loading more';

  @override
  String get allLoadedExpensesShown => 'All loaded expenses are shown';

  @override
  String get noExpensesMatchFilters => 'No expenses match your filters';

  @override
  String get expenseDetailsSeparator => '•';

  @override
  String get expenseActions => 'Expense actions';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get expenseUpdated => 'Expense updated';

  @override
  String get failedToUpdateExpense =>
      'Failed to update expense. Please try again.';

  @override
  String get deleteExpenseTitle => 'Delete expense?';

  @override
  String deleteExpenseMessage(String category, String amount, String date) {
    return 'Delete $category expense for $amount on $date?';
  }

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get failedToDeleteExpense =>
      'Failed to delete expense. Please try again.';

  @override
  String get categories => 'Categories';

  @override
  String get amount => 'Amount';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get currency => 'Currency';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get dateRange => 'Date range';

  @override
  String get anyDate => 'Any date';

  @override
  String get clearDates => 'Clear dates';

  @override
  String get pickDates => 'Pick dates';

  @override
  String get welcome => 'Welcome';

  @override
  String get thisMonthSpending => 'This Month Spending';

  @override
  String get budgetLeft => 'Budget Left';

  @override
  String get budget => 'Budget';

  @override
  String get setMonthlyBudget => 'Set monthly budget';

  @override
  String get topCategory => 'Top Category';

  @override
  String get noSpendingYet => 'No spending yet';

  @override
  String get transactions => 'Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get home => 'Home';

  @override
  String get stats => 'Stats';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get recurringExpenses => 'Recurring Expenses';

  @override
  String get savingGoals => 'Saving Goals';

  @override
  String get exportData => 'Export Data';

  @override
  String get logout => 'Logout';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get quickCaptureQuick => 'Quick';

  @override
  String get quickCaptureNatural => 'Text';

  @override
  String get quickCaptureReceipt => 'Receipt';

  @override
  String get quickCaptureMoreDetails => 'More details';

  @override
  String get quickCaptureLessDetails => 'Fewer details';

  @override
  String get quickCaptureDraftReady =>
      'Draft filled. Review the fields, then save.';

  @override
  String get quickCaptureReceiptTitle => 'Scan receipt';

  @override
  String get quickCaptureReceiptHelper =>
      'Receipt details fill this same editable form. Saving still requires the Save button.';

  @override
  String get quickCaptureReceiptApplied =>
      'Receipt draft filled. Review the fields, then save.';

  @override
  String get quickCaptureReceiptReview =>
      'Review receipt fields before saving.';

  @override
  String quickCaptureMissingFields(String fields) {
    return 'Complete missing fields: $fields.';
  }

  @override
  String get addCategory => 'Add category';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get merchant => 'Merchant';

  @override
  String get tags => 'Tags';

  @override
  String get tagsHelper => 'Separate tags with commas';

  @override
  String get possibleDuplicateExpense => 'Possible duplicate expense';

  @override
  String possibleDuplicateExpenseMessage(String amount, String currency,
      String category, String date, String reasons) {
    return 'A similar expense already exists: $amount $currency, $category, $date. Reasons: $reasons. Save anyway?';
  }

  @override
  String get saveAnyway => 'Save anyway';

  @override
  String get duplicateReasonSameDay => 'same day';

  @override
  String get duplicateReasonSameAmount => 'same amount';

  @override
  String get duplicateReasonSameCategory => 'same category';

  @override
  String get duplicateReasonSameMerchant => 'same merchant';

  @override
  String get date => 'Date';

  @override
  String get noActiveCategoriesYet => 'No active categories yet';

  @override
  String get enterValidExpenseAmount => 'Enter a valid expense amount';

  @override
  String get selectCategoryBeforeSaving => 'Select a category before saving';

  @override
  String get failedToSaveExpense => 'Failed to save expense. Please try again.';

  @override
  String get failedToSaveCategory =>
      'Failed to save category. Please try again.';

  @override
  String get failedToLoadCategories => 'Failed to load categories';

  @override
  String get categoryBudgets => 'Category Budgets';

  @override
  String get subscriptionCenter => 'Subscription Center';

  @override
  String get confirmLogoutTitle => 'Log out?';

  @override
  String get confirmLogoutMessage =>
      'You will need to sign in again to access your expenses.';

  @override
  String get failedToLoadExpenses => 'Failed to load expenses';

  @override
  String get checkConnectionTryAgain =>
      'Please check your connection and try again.';

  @override
  String get cash => 'Cash';

  @override
  String get visa => 'Visa';

  @override
  String get wallet => 'Wallet';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get profile => 'Profile';

  @override
  String get authenticatedAccount => 'Authenticated account';

  @override
  String get profileSettingsDescription =>
      'Manage your app profile, sign-in details, and account actions.';

  @override
  String get profileFallbackUser => 'User';

  @override
  String get profileName => 'Profile name';

  @override
  String get editProfileName => 'Edit profile name';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get displayNameHint => 'Enter the name shown in the app';

  @override
  String get displayNameRequired => 'Enter a display name.';

  @override
  String get displayNameTooLong =>
      'Display name must be 60 characters or fewer.';

  @override
  String get displayNameUpdated => 'Display name updated.';

  @override
  String get displayNameUpdateFailed =>
      'Failed to update display name. Please try again.';

  @override
  String get accountId => 'Account ID';

  @override
  String get copyAccountId => 'Copy account ID';

  @override
  String get accountIdCopied => 'Account ID copied.';

  @override
  String get accountProfileTitle => 'Account/Profile';

  @override
  String get accountProfileLoadFailed => 'Account profile could not be loaded.';

  @override
  String get accountEmail => 'Email';

  @override
  String get accountEmailMissing => 'No email on this account';

  @override
  String get accountProvider => 'Sign-in provider';

  @override
  String get accountProviderEmailPassword => 'Email and password';

  @override
  String get accountProviderGoogle => 'Google';

  @override
  String get accountProviderUnknown => 'Provider unavailable';

  @override
  String get accountActionUnavailableForProvider =>
      'This action is unavailable for the current sign-in provider.';

  @override
  String get accountPasswordReset => 'Reset password';

  @override
  String get accountPasswordResetDescription =>
      'Send a password reset email to this account.';

  @override
  String get accountPasswordResetSent => 'Password reset email sent.';

  @override
  String get accountPasswordResetFailed => 'Password reset could not be sent.';

  @override
  String get accountUpdateEmail => 'Update email';

  @override
  String get accountUpdateEmailDescription =>
      'Change the email used for this account.';

  @override
  String get accountNewEmail => 'New email';

  @override
  String get accountEmailInvalid => 'Enter a valid email address.';

  @override
  String get accountEmailUpdated => 'Email updated.';

  @override
  String get accountEmailUpdateFailed => 'Email could not be updated.';

  @override
  String get accountReauthRequired =>
      'Sign in again before changing this sensitive account setting.';

  @override
  String get accountReauthTitle => 'Sign in again';

  @override
  String get accountReauthPasswordDescription =>
      'Enter your current password, then the app will retry the account action.';

  @override
  String get accountReauthGoogleDescription =>
      'Continue with Google, then the app will retry the account action.';

  @override
  String get accountReauthPasswordLabel => 'Current password';

  @override
  String get accountReauthGoogleButton => 'Continue with Google';

  @override
  String get accountReauthSucceeded =>
      'Sign-in confirmed. Retrying the account action.';

  @override
  String get accountReauthFailed => 'Sign-in could not be confirmed.';

  @override
  String get accountReauthCanceled => 'Sign-in confirmation was canceled.';

  @override
  String get accountReauthUnavailable =>
      'Sign-in confirmation is unavailable for this provider.';

  @override
  String get accountDeleteTitle => 'Delete account';

  @override
  String get accountDeleteShortDescription =>
      'Delete your account and user-owned app data.';

  @override
  String get accountDeleteWarning =>
      'This permanently requests deletion of your account and user-owned expenses, categories, budgets, recurring expenses, saving goals, settings, and AI action history. This cannot be undone.';

  @override
  String get accountDeleteConfirmCheckbox =>
      'I understand this deletion cannot be undone.';

  @override
  String get accountDeleteButton => 'Delete account';

  @override
  String get accountDeleteConfirmationRequired =>
      'Confirm the warning before deleting your account.';

  @override
  String get accountDataDeleteFailed =>
      'Your account data could not be deleted. Your sign-in account was not deleted.';

  @override
  String get accountAuthDeleteFailed =>
      'Your app data deletion was requested, but the sign-in account could not be deleted.';

  @override
  String get accountDeleted => 'Account deleted.';

  @override
  String get accountDeleteFailed => 'Account deletion could not be completed.';

  @override
  String get appLanguage => 'App language';

  @override
  String get appLanguageDescription =>
      'Language controls app text, dates, AI locale, and voice input. It does not change your currency.';

  @override
  String get languageSystem => 'System';

  @override
  String get languageSystemDescription =>
      'Follow the device language when it is Arabic or English.';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageArabicDescription =>
      'Use Arabic text and right-to-left layout.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishDescription =>
      'Use English text and left-to-right layout.';

  @override
  String get failedToLoadSettings => 'Settings could not be loaded.';

  @override
  String get baseCurrency => 'Base currency';

  @override
  String get supportedCurrencies => 'Supported currencies';

  @override
  String get currencySettingsDescription =>
      'Language and currency are independent. Base currency is used for manual and AI defaults. Exchange rates convert dashboard totals only.';

  @override
  String get exchangeRates => 'Exchange rates';

  @override
  String get exchangeRatesDescription =>
      'Enter how much 1 unit of each currency is worth in your base currency.';

  @override
  String exchangeRateInputLabel(String currency) {
    return '1 $currency =';
  }

  @override
  String get exchangeRateInvalid => 'Enter a rate greater than zero.';

  @override
  String get exchangeRateSaved => 'Exchange rate saved.';

  @override
  String convertedCurrenciesStatus(String currencies) {
    return 'Converted: $currencies';
  }

  @override
  String unconvertedCurrenciesStatus(int count, String currencies) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Missing rates for $currencies; $count expenses not included',
      one: 'Missing rate for $currencies; 1 expense not included',
    );
    return '$_temp0';
  }

  @override
  String get settingsUnavailableTitle => 'Settings need attention';

  @override
  String get settingsUnavailableMessage =>
      'Retry settings or choose currency and payment method before saving.';

  @override
  String get chooseCurrencyAndPaymentBeforeSaving =>
      'Choose currency and payment method before saving.';

  @override
  String get settingsLoadRequiredForAi =>
      'Settings could not be loaded. Retry settings before using AI so currency and payment defaults are not guessed.';

  @override
  String get aiQuotaUnavailable => 'AI quota is unavailable right now.';

  @override
  String get aiQuotaExhausted => 'You have used today\'s AI limit.';

  @override
  String get aiCouldNotUnderstand =>
      'I could not understand that request. Try adding the amount, category, and date.';

  @override
  String get aiProviderUnavailable =>
      'AI service is unavailable. Try again later.';

  @override
  String get aiFormFillTitle => 'Fill with AI';

  @override
  String get aiFormFillHint => 'Example: spent 100 dollars on food last night';

  @override
  String get aiFormFillHelper =>
      'AI fills the form only. Review and press Save yourself.';

  @override
  String get aiFormFillAction => 'Fill';

  @override
  String get aiFormFillApplied => 'AI filled the form. Review before saving.';

  @override
  String get aiFormFillFailed =>
      'AI could not fill the form. You can still enter it manually.';

  @override
  String get aiFormFillNeedsReview =>
      'AI needs more review. Complete the form manually.';

  @override
  String get no => 'No';

  @override
  String get notificationsSettingsTitle => 'Notifications';

  @override
  String get budgetAlerts => 'Budget alerts';

  @override
  String get budgetAlertsDescription =>
      'Warn when spending nears or exceeds budget.';

  @override
  String get dailyCheckIn => 'Daily check-in';

  @override
  String get dailyCheckInDescription =>
      'Review today\'s spending and keep your streak active.';

  @override
  String get checkInTime => 'Check-in time';

  @override
  String get weeklyDigest => 'Weekly digest';

  @override
  String get weeklyDigestDescription =>
      'Remind me to review my weekly spending summary.';

  @override
  String get weeklyDigestEmpty => 'No spending tracked for this week yet.';

  @override
  String get weeklyDigestThisWeek => 'This week';

  @override
  String get weeklyDigestPreviousWeek => 'Previous week';

  @override
  String get weeklyDigestChange => 'Change';

  @override
  String get weeklyDigestLocalInsight => 'Local insight';

  @override
  String weeklyDigestIgnoredCurrencyExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count expenses in other currencies were ignored because no saved rates were available.',
      one:
          '1 expense in another currency was ignored because no saved rate was available.',
    );
    return '$_temp0';
  }

  @override
  String weeklyDigestHealthScore(String label, int score) {
    return '$label ($score/100)';
  }

  @override
  String get weeklyInsightStartLogging =>
      'Start by logging one expense this week.';

  @override
  String weeklyInsightTopCategory(String category) {
    return '$category is your largest category this week.';
  }

  @override
  String get weeklyInsightFirstTrackedWeek =>
      'This is your first tracked week in this comparison.';

  @override
  String get weeklyInsightHigherThanLastWeek =>
      'Spending is higher than last week.';

  @override
  String get weeklyInsightLowerThanLastWeek =>
      'Spending is lower than last week.';

  @override
  String get weeklyInsightUnchanged => 'Spending is unchanged from last week.';

  @override
  String get spendingHealthAddFewExpenses => 'Add a few expenses';

  @override
  String get spendingHealthOnTrack => 'On track';

  @override
  String get spendingHealthWorthWatching => 'Worth watching';

  @override
  String get spendingHealthNeedsReview => 'Needs review';

  @override
  String get spendingHealthReasonLogExpensesOrBudget =>
      'Log expenses or set a monthly budget to see a score.';

  @override
  String get spendingHealthReasonBudgetExceeded =>
      'Monthly budget is exceeded.';

  @override
  String get spendingHealthReasonBudgetNearLimit =>
      'Monthly budget is near its limit.';

  @override
  String get spendingHealthReasonBudgetOnTrack => 'Monthly budget is on track.';

  @override
  String get spendingHealthReasonNoBudget => 'No monthly budget is set.';

  @override
  String get spendingHealthReasonOneCategoryHigh =>
      'One category is over 60% of this month\'s spending.';

  @override
  String get spendingHealthReasonSpreadAcrossCategories =>
      'Spending is spread across categories.';

  @override
  String get spendingHealthReasonTrackedToday =>
      'Today has at least one logged expense.';

  @override
  String get spendingHealthReasonRecentTracking =>
      'Recent tracking activity is active.';

  @override
  String get spendingHealthReasonNoRecentStreak =>
      'No recent tracking streak yet.';

  @override
  String get digestTime => 'Digest time';

  @override
  String get monday => 'Monday';

  @override
  String get appProtection => 'App Protection';

  @override
  String get pinLock => 'PIN lock';

  @override
  String get pinLockDescription => 'Require a local PIN on launch/resume.';

  @override
  String get changePin => 'Change PIN';

  @override
  String get createPin => 'Create PIN';

  @override
  String get createPinIntro => 'Protect your expense data with a local PIN.';

  @override
  String get changePinIntro => 'Choose a new app PIN.';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPinLabel => 'Confirm PIN';

  @override
  String get saveNewPin => 'Save New PIN';

  @override
  String get enableAppLock => 'Enable App Lock';

  @override
  String get pinDigitsValidation => 'PIN must be 4 to 8 digits.';

  @override
  String get pinConfirmationMismatch => 'PIN confirmation does not match.';

  @override
  String get expenseTrackerLocked => 'Expense Tracker is locked';

  @override
  String get enterPinToContinue => 'Enter your PIN to continue.';

  @override
  String get unlock => 'Unlock';

  @override
  String get useBiometrics => 'Use biometrics';

  @override
  String get biometricUnlock => 'Biometric unlock';

  @override
  String get biometricUnlockAvailableDescription =>
      'Use fingerprint or Face ID when available.';

  @override
  String get biometricUnlockUnavailableDescription =>
      'Not available on this device.';

  @override
  String get aiUsageSettingsTitle => 'AI Usage';

  @override
  String get aiUsageSettingsDescription =>
      'Free daily AI limits. Manual expenses and local reports keep working when AI is unavailable.';

  @override
  String get aiUsageTextParsing => 'Text parsing';

  @override
  String get aiUsageReceiptExtraction => 'Receipt extraction';

  @override
  String get aiUsageFinancialAdvice => 'Financial advice';

  @override
  String aiUsageUsed(int used, int limit) {
    return '$used/$limit used';
  }

  @override
  String aiUsageResetsAround(String time) {
    return 'resets around $time';
  }

  @override
  String get aiUsageWaitingForLiveUsage => 'waiting for live Worker usage';

  @override
  String aiUsageRemaining(int count) {
    return '$count left';
  }

  @override
  String get freePlan => 'Free plan';

  @override
  String get premiumPlan => 'Premium plan';

  @override
  String get unknownPlan => 'Unknown plan';

  @override
  String get pendingPlan => 'Pending plan';

  @override
  String get loadingLivePlanState => 'Loading live plan state...';

  @override
  String get adsDisabled => 'Ads disabled';

  @override
  String get viewLimitsAdsAndPremium => 'View limits, ads, and Premium';

  @override
  String get removeAds => 'Remove ads';

  @override
  String get removeAdsDescription => 'Coming with Premium purchase setup.';

  @override
  String get usingFreeSafePlanState => 'Using Free-safe plan state';

  @override
  String get refreshPlanState => 'Refresh plan state';

  @override
  String get privacyAndAdChoices => 'Privacy and ad choices';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacySettingsDescription =>
      'Your expenses stay user-scoped in Firebase. AI actions require preview and confirmation before any write.';

  @override
  String get dataOwnership => 'Data ownership';

  @override
  String get dataOwnershipDescription =>
      'Only your authenticated account can access your data.';

  @override
  String get support => 'Support';

  @override
  String get supportSettingsDescription =>
      'Send feedback without attaching expense data.';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get sendFeedbackDescription =>
      'Includes app version only if you approve it.';

  @override
  String get feedbackDiagnosticsPrompt =>
      'No expense descriptions, receipts, account tokens, PINs, or AI provider details will be included. Add app version 1.0.0+1?';

  @override
  String get includeVersion => 'Include version';

  @override
  String get appVersion => 'App version';

  @override
  String get feedbackShareTemplate =>
      'Expense Tracker feedback\n\nWhat happened?\n\nWhat did you expect?';

  @override
  String get feedbackSubject => 'Expense Tracker feedback';

  @override
  String get paymentSettingsTitle => 'Payment';

  @override
  String get paymentSettingsDescription =>
      'Used as the default when a manual or AI expense does not specify a payment method.';

  @override
  String get defaultPaymentMethod => 'Default payment method';

  @override
  String get onboardingTitle => 'First-run setup';

  @override
  String get onboardingLoading => 'Loading setup';

  @override
  String get onboardingLoadFailed =>
      'Setup could not load your settings. Check your connection and try again.';

  @override
  String get onboardingSaveFailed =>
      'Setup could not save your choices. Keep them selected and try again.';

  @override
  String get onboardingSelectRequired =>
      'Choose language, base currency, and default payment method to continue.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingFinish => 'Finish setup';

  @override
  String get onboardingComplete => 'Setup complete';

  @override
  String get onboardingSkipReminders => 'Skip reminders';

  @override
  String get onboardingEssentialsTitle => 'Choose your essentials';

  @override
  String get onboardingEssentialsSubtitle =>
      'These choices control app language and the defaults used before any expense is saved.';

  @override
  String get onboardingLanguageLabel => 'Language';

  @override
  String get onboardingLanguageEnglish => 'English';

  @override
  String get onboardingLanguageArabic => 'Arabic';

  @override
  String get onboardingCurrencyLabel => 'Base currency';

  @override
  String get onboardingPaymentLabel => 'Default payment method';

  @override
  String get onboardingAiTitle => 'AI stays under your control';

  @override
  String get onboardingAiSubtitle =>
      'AI can help prepare expenses, but setup never calls the AI provider or uses quota.';

  @override
  String get onboardingAiPreviewTitle => 'Preview first';

  @override
  String get onboardingAiPreviewBody =>
      'AI suggestions are shown for review. Nothing is saved until you confirm.';

  @override
  String get onboardingAiLimitTitle => 'Free daily limits';

  @override
  String get onboardingAiLimitBody =>
      'AI has free daily limits and can be unavailable, so the app never depends on it for manual tracking.';

  @override
  String get onboardingAiManualTitle => 'Manual entry always works';

  @override
  String get onboardingAiManualBody =>
      'You can add expenses yourself even when AI quota is finished or the gateway is offline.';

  @override
  String get onboardingAiSample =>
      'Example only: \"Lunch 12 USD by wallet\". This sample is not sent to AI.';

  @override
  String get onboardingAiSampleSemantics =>
      'AI example text that is not submitted';

  @override
  String get onboardingReminderTitle => 'Optional reminders';

  @override
  String get onboardingReminderSubtitle =>
      'Reminders can help you keep tracking, but they are optional and can be changed later.';

  @override
  String get onboardingDailyReminder => 'Daily expense check-in';

  @override
  String get onboardingDailyReminderDescription =>
      'Ask for a quick spending review in the evening when you have not logged today.';

  @override
  String get onboardingWeeklyDigest => 'Weekly spending digest';

  @override
  String get onboardingWeeklyDigestDescription =>
      'Show a Monday digest prompt for your weekly summary and health score.';

  @override
  String get onboardingReminderLater =>
      'If permission is denied, setup still finishes and reminders stay off.';

  @override
  String get onboardingReminderPermissionDenied =>
      'Reminders were not enabled because notification permission or scheduling was unavailable.';

  @override
  String get guidedTourNext => 'Next';

  @override
  String get guidedTourBack => 'Back';

  @override
  String get guidedTourSkip => 'Skip';

  @override
  String get guidedTourDone => 'Done';

  @override
  String get guidedTourReplayTour => 'Replay Tour';

  @override
  String guidedTourStepCount(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get guidedTourAiTitle => 'Meet the AI Assistant';

  @override
  String get guidedTourAiBody =>
      'Write or speak an expense here. AI always shows a preview before anything is saved.';

  @override
  String get guidedTourManualExpenseTitle => 'Add expenses manually';

  @override
  String get guidedTourManualExpenseBody =>
      'Use the plus button to open the normal expense form. AI can fill it at the top, and Save is still your final step.';

  @override
  String get guidedTourAiPreviewTitle => 'Review before saving';

  @override
  String get guidedTourAiPreviewBody =>
      'AI suggestions are never saved directly. Check the amount, category, date, and payment method before confirming.';

  @override
  String get guidedTourBudgetTitle => 'Track your budget';

  @override
  String get guidedTourBudgetBody =>
      'Monthly budgets power remaining-balance views, alerts, and grounded advice from real expenses.';

  @override
  String get guidedTourReportsTitle => 'Read real reports';

  @override
  String get guidedTourReportsBody =>
      'Reports summarize your actual spending by week, month, and category.';

  @override
  String get guidedTourCategoriesTitle => 'Organize categories';

  @override
  String get guidedTourCategoriesBody =>
      'Open the menu for categories. You can edit category names, icons, colors, and archived choices safely.';

  @override
  String get guidedTourSettingsTitle => 'Tune Settings';

  @override
  String get guidedTourSettingsBody =>
      'Settings keeps currency, payment, notifications, protection, AI usage, monetization, and privacy controls together.';

  @override
  String get guidedTourFreePremiumTitle => 'Free and Premium';

  @override
  String get guidedTourFreePremiumBody =>
      'Free keeps manual tracking available. Premium options, ads, and limits live in Settings without interrupting expense entry.';

  @override
  String get guidedTourSettingsSectionTitle => 'Guidance';

  @override
  String get guidedTourSettingsSectionDescription =>
      'Replay the guided tour for the current app version.';

  @override
  String get guidedTourReplayTourDescription => 'Show the Home tour again.';

  @override
  String get archive => 'Archive';

  @override
  String get clear => 'Clear';

  @override
  String get close => 'Close';

  @override
  String get parse => 'Parse';

  @override
  String get add => 'Add';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get required => 'Required';

  @override
  String get export => 'Export';

  @override
  String get shareFile => 'Share file';

  @override
  String get allCurrencies => 'All currencies';

  @override
  String get pickRange => 'Pick range';

  @override
  String get selectDateRangeBeforeExporting =>
      'Select a date range before exporting.';

  @override
  String exportReady(String fileName) {
    return 'Export ready: $fileName';
  }

  @override
  String get reports => 'Reports';

  @override
  String get activeReportDrilldownFilter => 'Report drilldown filter active';

  @override
  String get monthlyStoryTitle => 'Monthly story';

  @override
  String get monthlyStoryEmpty =>
      'No spending was recorded for this month or the previous month.';

  @override
  String monthlyStoryNewSpending(String current) {
    return 'This month has $current in spending, with no previous month spending to compare yet.';
  }

  @override
  String monthlyStoryIncrease(String current, String previous, int percent) {
    return 'Spending rose to $current from $previous, up $percent%.';
  }

  @override
  String monthlyStoryDecrease(String current, String previous, int percent) {
    return 'Spending improved to $current from $previous, down $percent%.';
  }

  @override
  String monthlyStoryFlat(String current, String previous) {
    return 'Spending stayed close to last month: $current now versus $previous before.';
  }

  @override
  String get monthlyStoryDriversHeading => 'Main drivers';

  @override
  String monthlyStoryDriver(String category, String amount, int percent) {
    return '$category: $amount, about $percent% of this month.';
  }

  @override
  String get monthlyStoryOutliersHeading => 'Large expenses';

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
          'This story excludes $count expenses with missing rates for $currencies.',
      one: 'This story excludes 1 expense with a missing rate for $currencies.',
    );
    return '$_temp0';
  }

  @override
  String get noSpendingInThisPeriod => 'No spending in this period.';

  @override
  String get noCategorySpendingYet => 'No category spending yet.';

  @override
  String get none => 'None';

  @override
  String topCategoryLabel(String category) {
    return 'Top category: $category';
  }

  @override
  String ignoredOtherCurrencyExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses in other currencies ignored.',
      one: '1 expense in another currency ignored.',
    );
    return '$_temp0';
  }

  @override
  String get periodComparison => 'Period Comparison';

  @override
  String currentAmountLabel(String amount) {
    return 'Current: $amount';
  }

  @override
  String previousAmountLabel(String amount) {
    return 'Previous: $amount';
  }

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get frequency => 'Frequency';

  @override
  String get newRecurring => 'New Recurring';

  @override
  String get editRecurringExpense => 'Edit Recurring Expense';

  @override
  String get archiveRecurringExpense => 'Archive Recurring Expense';

  @override
  String archiveRecurringExpenseMessage(String name) {
    return 'Archive $name?';
  }

  @override
  String get createActiveCategoryBeforeRecurring =>
      'Create an active category before recurring expenses.';

  @override
  String get noActiveRecurringExpensesYet => 'No active recurring expenses yet';

  @override
  String nextDateLabel(String date) {
    return 'Next $date';
  }

  @override
  String get enterRecurringAmountAndCategory => 'Enter amount and category.';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get noEndDate => 'No end date';

  @override
  String get clearEndDate => 'Clear end date';

  @override
  String get savingGoalsTitle => 'Saving Goals';

  @override
  String get newSavingGoal => 'New Saving Goal';

  @override
  String get editSavingGoal => 'Edit Saving Goal';

  @override
  String get goalName => 'Goal name';

  @override
  String get targetAmount => 'Target amount';

  @override
  String get currentAmount => 'Current amount';

  @override
  String get deadline => 'Deadline';

  @override
  String get noDeadline => 'No deadline';

  @override
  String get clearDeadline => 'Clear deadline';

  @override
  String get addContribution => 'Add contribution';

  @override
  String get contributionAmount => 'Contribution amount';

  @override
  String addContributionToGoal(String goal) {
    return 'Add to $goal';
  }

  @override
  String get archiveSavingGoal => 'Archive Saving Goal';

  @override
  String archiveSavingGoalMessage(String goal) {
    return 'Archive $goal?';
  }

  @override
  String get noActiveSavingGoalsYet => 'No active saving goals yet';

  @override
  String get enterSavingGoalNameAndTarget =>
      'Enter a name and positive target amount.';

  @override
  String get currentAmountCannotBeNegative =>
      'Current amount cannot be negative.';

  @override
  String get goalReached => 'Goal reached';

  @override
  String remainingAmountLabel(String amount) {
    return '$amount remaining';
  }

  @override
  String savedPercentLabel(String percent) {
    return '$percent% saved';
  }

  @override
  String deadlineDateLabel(String date) {
    return 'Deadline $date';
  }

  @override
  String get freePremiumTitle => 'Free / Premium';

  @override
  String planRefreshFailedFreeSafe(String message) {
    return 'Plan refresh failed, so Free-safe limits are shown. Manual expense tracking is still available. $message';
  }

  @override
  String get premiumStillWorks =>
      'Premium removes ads and raises limits. Manual tracking remains the core experience.';

  @override
  String get freeStillWorks =>
      'Free keeps manual expenses, categories, budgets, basic reports, exports, and offline sync working even when AI quota is finished.';

  @override
  String get adsOnFree => 'Ads on Free';

  @override
  String get premiumAdsDisabledBody =>
      'The app must not initialize or request ads while Premium is active.';

  @override
  String get freeAdsBody =>
      'Ads are reserved for passive banner slots or natural completion moments. They never interrupt add expense, AI preview, auth, app lock, or purchase flows.';

  @override
  String consentStatusLabel(String status) {
    return 'Consent: $status';
  }

  @override
  String get todayAiUsage => 'Today AI usage';

  @override
  String get textParse => 'Text parse';

  @override
  String get receipts => 'Receipts';

  @override
  String get advice => 'Advice';

  @override
  String leftByDefault(int count) {
    return '$count left by default';
  }

  @override
  String leftCount(int count) {
    return '$count left';
  }

  @override
  String get showingPolicyDefaultsUntilWorker =>
      'Showing policy defaults until the Worker returns live usage.';

  @override
  String resetsAroundWithPeriod(String time) {
    return 'Resets around $time.';
  }

  @override
  String get free => 'Free';

  @override
  String get premium => 'Premium';

  @override
  String get included => 'Included';

  @override
  String get manualTracking => 'Manual tracking';

  @override
  String get aiTextParse => 'AI text parse';

  @override
  String get higherFiniteLimit => 'Higher finite limit';

  @override
  String get moreReceipts => 'More receipts';

  @override
  String get moreAdvice => 'More advice';

  @override
  String get ads => 'Ads';

  @override
  String get politeAds => 'Polite ads';

  @override
  String get noAds => 'No ads';

  @override
  String get reportsExport => 'Reports/export';

  @override
  String get basic => 'Basic';

  @override
  String get advancedLater =>
      'Advanced reports, export templates, smart budgets';

  @override
  String get premiumIsActive => 'Premium is active';

  @override
  String get premiumActiveBody =>
      'Ads are disabled and Premium entitlements are enabled.';

  @override
  String get premiumComingSoon => 'Premium coming soon';

  @override
  String get premiumPurchasesDisabledBody =>
      'Purchases are not enabled yet because backend verification is not deployed. The app will not fake a subscription or charge you from this screen.';

  @override
  String get checkAvailability => 'Check availability';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get readinessComingSoonLabel => 'Coming soon';

  @override
  String get readinessDisabledLabel => 'Unavailable now';

  @override
  String get premiumRestoreDisabledBody =>
      'Purchase restore is disabled until trusted backend entitlement verification is available.';

  @override
  String get premiumBackendVerificationUnavailable =>
      'Paid subscriptions are disabled because backend verification is not configured yet.';

  @override
  String get walletsReadinessBody =>
      'Wallet management stays disabled until list, create, edit, archive, and expense assignment are complete.';

  @override
  String get transfersReadinessBody =>
      'Transfers stay disabled until the transfer form and currency policy are complete; they remain separate from expenses.';

  @override
  String get backupExportTitle => 'Backup export';

  @override
  String get backupExportReadinessBody =>
      'Backup export is not available from the app UI until safe data collection is complete.';

  @override
  String get restorePreviewTitle => 'Restore preview';

  @override
  String get restorePreviewReadinessBody =>
      'Restore requires an impact preview and explicit confirmation before any data can change.';

  @override
  String get restoreExecutionTitle => 'Restore execution';

  @override
  String get restoreExecutionReadinessBody =>
      'Restore execution is intentionally blocked until conflict policy and repository write tests exist.';

  @override
  String get aiInputExampleHint =>
      'Example: spent 250 EGP on food yesterday with cash';

  @override
  String get receipt => 'Receipt';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get receiptImageReadFailed =>
      'Could not read the receipt image. Add the expense manually.';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get reviewBeforeSaving => 'Review before saving';

  @override
  String get newCategoryName => 'New category name';

  @override
  String get confirmingCreatesCategoryFirst =>
      'Confirming will create this category first.';

  @override
  String suggestedNewCategory(String category) {
    return 'Suggested new category: $category';
  }

  @override
  String matchedCategory(String category) {
    return 'Matched category: $category';
  }

  @override
  String sourceLabel(String source) {
    return 'Source: $source';
  }

  @override
  String confidenceLabel(int percent) {
    return 'Confidence: $percent%';
  }

  @override
  String get aiCategoryId => 'AI category id';

  @override
  String get aiCategoryName => 'AI category name';

  @override
  String get categoryAlias => 'category alias';

  @override
  String get recentHistory => 'recent history';

  @override
  String get newCategorySuggestion => 'new category suggestion';

  @override
  String get manualSelection => 'manual selection';

  @override
  String get noMatch => 'no match';

  @override
  String get failedToCreateAiSuggestedCategory =>
      'Failed to create AI suggested category.';

  @override
  String get createCategoryBeforeSavingRecurrence =>
      'Create a category before saving recurrence.';

  @override
  String get recurringExpenseSuggestionSaved =>
      'Recurring expense suggestion saved.';

  @override
  String get failedToSaveAiExpense =>
      'Failed to save AI expense. Please try again.';

  @override
  String get pleaseAddMoreDetails => 'Please add more details.';

  @override
  String get couldNotParseExpense => 'Could not parse this expense.';

  @override
  String get searchReady => 'Search ready';

  @override
  String get readyToOpenFilteredExpenses => 'Ready to open filtered expenses.';

  @override
  String get openResults => 'Open results';

  @override
  String get historyAnswer => 'History';

  @override
  String get historySourceLocal => 'Source: deterministic local history';

  @override
  String get historyNoMatchingExpenses =>
      'No loaded expenses match that history question.';

  @override
  String historyMatchingExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matching expenses.',
      one: '1 matching expense.',
    );
    return '$_temp0';
  }

  @override
  String get historyMutationReadOnly =>
      'History answers are read-only. Use the existing preview and confirmation flow for changes.';

  @override
  String get summary => 'Summary';

  @override
  String totalAmountLabel(String amount) {
    return 'Total: $amount';
  }

  @override
  String topCategoryWithAmount(String category, String amount) {
    return 'Top category: $category ($amount)';
  }

  @override
  String ignoredOtherCurrencyExpensesBecause(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses ignored because they use another currency.',
      one: '1 expense ignored because it uses another currency.',
    );
    return '$_temp0';
  }

  @override
  String get financialAdvice => 'Financial advice';

  @override
  String get localAdviceFallback => 'Local advice fallback';

  @override
  String get aiFinancialAdvice => 'AI financial advice';

  @override
  String aiAdviceEvidenceTotal(String amount, String currency) {
    return 'Total: $amount $currency';
  }

  @override
  String aiAdviceEvidenceTopCategory(
      String category, String amount, String currency) {
    return 'Top category: $category ($amount $currency)';
  }

  @override
  String aiAdviceEvidenceBudgetUsed(String percent) {
    return 'Budget used: $percent%';
  }

  @override
  String aiAdviceEvidenceConvertedCurrencies(String currencies) {
    return 'Converted currencies: $currencies';
  }

  @override
  String aiAdviceEvidenceMissingRates(String currencies, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses were not included',
      one: '1 expense was not included',
    );
    return 'Missing rates for $currencies; $_temp0';
  }

  @override
  String get aiAdviceNoSpending =>
      'No spending found for this period. Keep recording expenses so advice can be more useful.';

  @override
  String aiAdviceOverBudget(String category) {
    return 'You are over budget. Review $category first and pause non-essential spending until the next period.';
  }

  @override
  String get aiAdviceOverBudgetFallback =>
      'You are over budget. Review your biggest category first and pause non-essential spending until the next period.';

  @override
  String aiAdviceNearLimit(String category) {
    return 'You are close to your budget limit. Keep the next purchases small and watch $category.';
  }

  @override
  String get aiAdviceNearLimitFallback =>
      'You are close to your budget limit. Keep the next purchases small and watch your top category.';

  @override
  String aiAdviceFocusCategory(String category) {
    return 'For $category, compare each purchase against your plan before spending again this period.';
  }

  @override
  String aiAdviceTopCategory(String category) {
    return 'Your highest spending is $category. Set a smaller limit for it and move routine purchases to planned days.';
  }

  @override
  String get aiAdviceStable =>
      'Your spending is stable for this period. Keep checking totals before adding new non-essential expenses.';

  @override
  String aiAdviceRequestsLeftToday(int count) {
    return '$count AI advice request(s) left today.';
  }

  @override
  String get aiNeedsReview => 'AI needs review';

  @override
  String get aiUnavailable => 'AI unavailable';

  @override
  String get providerAiUnavailableManualStillWorks =>
      'Provider-backed AI is unavailable. Manual entry and local insights still work.';

  @override
  String get localSpendingPrediction => 'Local spending prediction';

  @override
  String expectedThisMonth(String amount) {
    return 'Expected this month: $amount';
  }

  @override
  String get repeatedExpenseFound => 'Repeated expense found';

  @override
  String repeatedExpenseLooksFrequency(String description, String frequency) {
    return '$description looks $frequency.';
  }

  @override
  String matchingExpensesAverage(int count, String amount) {
    return '$count matching expenses, average $amount.';
  }

  @override
  String get reviewRecurring => 'Review recurring';

  @override
  String get confirmDelete => 'Confirm delete';

  @override
  String get confirmUpdate => 'Confirm update';

  @override
  String get chooseExactExpenseFirst => 'Choose the exact expense first.';

  @override
  String get update => 'Update';

  @override
  String get target => 'Target';

  @override
  String get after => 'After';

  @override
  String get preparingVoiceInput => 'Preparing voice input...';

  @override
  String get listeningVoiceInput =>
      'Listening. Pause support depends on your device.';

  @override
  String get createCategory => 'Create Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get archiveCategory => 'Archive Category';

  @override
  String archiveCategoryMessage(String category) {
    return 'Archive $category? Existing expenses will still show it.';
  }

  @override
  String get categoryCreated => 'Category created.';

  @override
  String get categoryUpdated => 'Category updated.';

  @override
  String get categoryArchived => 'Category archived.';

  @override
  String get failedToCreateCategory => 'Failed to create category.';

  @override
  String get failedToUpdateCategory => 'Failed to update category.';

  @override
  String get failedToArchiveCategory => 'Failed to archive category.';

  @override
  String get selectCategoryToArchive => 'Select a category to archive.';

  @override
  String get enterCategoryNameIconColor =>
      'Enter category name, icon, and color.';

  @override
  String get categoryName => 'Name';

  @override
  String get categoryIcon => 'Icon';

  @override
  String get selectedCategoryIcon => 'Selected category icon';

  @override
  String get categoryColor => 'Color';

  @override
  String get customColor => 'Custom color';

  @override
  String get saveColor => 'Save Color';

  @override
  String get searchIcons => 'Search icons';

  @override
  String categoryIconSemantics(String label) {
    return 'Icon $label';
  }

  @override
  String categoryColorSemantics(String label) {
    return 'Color $label';
  }

  @override
  String categoryExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
      zero: 'No expenses',
    );
    return '$_temp0';
  }

  @override
  String get monthlyBudgetTitle => 'Monthly Budget';

  @override
  String get budgetSetAction => 'Set';

  @override
  String get budgetNoBudgetSet => 'No budget set for this month.';

  @override
  String get budgetSpentLabel => 'Spent';

  @override
  String get budgetRemainingLabel => 'Remaining';

  @override
  String budgetPercentOfLimit(String percent, String amount) {
    return '$percent% of $amount';
  }

  @override
  String get budgetExceededWarning => 'Budget exceeded.';

  @override
  String get budgetNearLimitWarning => 'You are close to your budget limit.';

  @override
  String budgetIgnoredCurrencyExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count expenses in other currencies were excluded because no saved rates were available.',
      one:
          '1 expense in another currency was excluded because no saved rate was available.',
    );
    return '$_temp0';
  }

  @override
  String get categoryBudgetsCreateCategoryFirst =>
      'Create an active category before category budgets.';

  @override
  String get categoryBudgetsLoadFailed => 'Failed to load category budgets.';

  @override
  String get categoryBudgetSaved => 'Category budget saved.';

  @override
  String get categoryBudgetSaveFailed => 'Failed to save category budget.';

  @override
  String get categoryBudgetArchived => 'Category budget archived.';

  @override
  String get categoryBudgetArchiveFailed =>
      'Failed to archive category budget.';

  @override
  String get selectCategoryBudgetToArchive =>
      'Select a category budget to archive.';

  @override
  String get archiveCategoryBudget => 'Archive Category Budget';

  @override
  String archiveCategoryBudgetMessage(String category) {
    return 'Archive $category budget?';
  }

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get noCategoryBudgetsYet => 'No category budgets yet';

  @override
  String get addCategoryBudget => 'Add Category Budget';

  @override
  String get editCategoryBudget => 'Edit Category Budget';

  @override
  String get limitAmount => 'Limit amount';

  @override
  String get warningThresholdPercent => 'Warning threshold percent';

  @override
  String get budgetRecommendationTitle => 'Suggested monthly budget';

  @override
  String budgetRecommendationMeta(String confidence, String period) {
    return '$confidence confidence - $period';
  }

  @override
  String get budgetRecommendationMonthlyExplanation =>
      'Based on recent monthly spending and trend.';

  @override
  String budgetRecommendationCategoryExplanation(String category) {
    return 'Based on recent $category spending and trend.';
  }

  @override
  String get useEditableRecommendation => 'Use editable suggestion';

  @override
  String get categoryBudgetRecommendationsTitle => 'Suggested category budgets';

  @override
  String categoryBudgetRecommendationSubtitle(
      String amount, String confidence) {
    return '$amount - $confidence confidence';
  }

  @override
  String get recommendationConfidenceHigh => 'High';

  @override
  String get recommendationConfidenceMedium => 'Medium';

  @override
  String get recommendationConfidenceLow => 'Low';

  @override
  String get recommendationCaveatSparseHistory =>
      'Limited history makes this a cautious estimate.';

  @override
  String get recommendationCaveatOutlierMonth =>
      'One unusual month was reduced in the estimate.';

  @override
  String get recommendationCaveatMissingRates =>
      'Expenses with missing exchange rates were excluded.';

  @override
  String get recommendationCaveatExistingBudget =>
      'You already have a budget here; review before replacing it.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String budgetRemainingAmount(String amount) {
    return 'Remaining $amount';
  }

  @override
  String categoryBudgetIgnoredCurrencyExpenses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses ignored due to currency',
      one: '1 expense ignored due to currency',
    );
    return '$_temp0';
  }

  @override
  String get selectCategory => 'Select a category.';

  @override
  String get selectMonth => 'Select a month.';

  @override
  String get selectCurrency => 'Select a currency.';

  @override
  String get enterValidBudgetLimit => 'Enter a valid budget limit.';

  @override
  String get warningThresholdRange =>
      'Warning threshold must be between 1 and 100.';

  @override
  String get manageRecurringExpenses => 'Manage recurring expenses';

  @override
  String get failedToLoadSubscriptions => 'Failed to load subscriptions.';

  @override
  String get estimatedMonthlyImpact => 'Estimated monthly impact';

  @override
  String get subscriptionMixedCurrencyCaveat =>
      'Totals stay separated by currency until subscription conversion is audited.';

  @override
  String get dailyMonthlyImpactEstimateCaveat =>
      'Daily subscriptions are estimated as 30 renewals per month.';

  @override
  String get weeklyMonthlyImpactEstimateCaveat =>
      'Weekly subscriptions are estimated as 52 renewals across 12 months.';

  @override
  String get upcomingRenewals => 'Upcoming renewals';

  @override
  String renewsOn(Object date) {
    return 'Renews $date';
  }

  @override
  String get possiblePriceChanges => 'Possible price changes';

  @override
  String possiblePriceIncrease(Object previous, Object current) {
    return 'Possible increase from $previous to $current';
  }

  @override
  String get cautiousSignal => 'Cautious signal';

  @override
  String get activeSubscriptions => 'Active subscriptions';

  @override
  String subscriptionNextDue(
      String frequency, String paymentMethod, String date) {
    return '$frequency - $paymentMethod - Next $date';
  }

  @override
  String monthlyImpactSuffix(String amount) {
    return '$amount/mo';
  }

  @override
  String get noActiveSubscriptionsYet => 'No active subscriptions yet';

  @override
  String get exportEndDateBeforeStart =>
      'End date must be on or after start date.';

  @override
  String get exportCurrencyFilterEmpty => 'Currency filter must not be empty.';

  @override
  String get exportPdfTitle => 'Expense Export';

  @override
  String exportPdfPeriod(String startDate, String endDate) {
    return 'Period: $startDate - $endDate';
  }

  @override
  String exportPdfTotal(String total) {
    return 'Total: $total';
  }

  @override
  String get exportHeaderDate => 'date';

  @override
  String get exportHeaderAmount => 'amount';

  @override
  String get exportHeaderCurrency => 'currency';

  @override
  String get exportHeaderCategory => 'category';

  @override
  String get exportHeaderPaymentMethod => 'paymentMethod';

  @override
  String get exportHeaderDescription => 'description';

  @override
  String get exportHeaderConvertedAmount => 'convertedAmount';

  @override
  String get exportHeaderConvertedCurrency => 'convertedCurrency';

  @override
  String get exportHeaderConversionRate => 'conversionRate';

  @override
  String get exportHeaderConversionRateDate => 'conversionRateDate';

  @override
  String get exportHeaderConversionStatus => 'conversionStatus';

  @override
  String get exportConversionStatusOriginal => 'original';

  @override
  String get exportConversionStatusConverted => 'converted';

  @override
  String get exportConversionStatusMissingRate => 'missingRate';

  @override
  String exportPdfConvertedTotal(String total) {
    return 'Converted total: $total';
  }

  @override
  String exportPdfMissingRates(String currencies, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows were not included.',
      one: '1 row was not included.',
    );
    return 'Missing rates for $currencies; $_temp0';
  }

  @override
  String get exportArabicFontMissing =>
      'PDF export needs the bundled Arabic font asset before it can run. Add assets/fonts/NotoSansArabic-Regular.ttf and regenerate assets.';

  @override
  String get wallets => 'Wallets';

  @override
  String get walletAccount => 'Wallet account';

  @override
  String get walletType => 'Wallet type';

  @override
  String get openingBalance => 'Opening balance';

  @override
  String get archiveWallet => 'Archive wallet';

  @override
  String get transfers => 'Transfers';

  @override
  String get transfer => 'Transfer';

  @override
  String get sourceWallet => 'Source wallet';

  @override
  String get destinationWallet => 'Destination wallet';

  @override
  String get transferFee => 'Transfer fee';

  @override
  String get feeWallet => 'Fee wallet';
}

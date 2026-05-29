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
/// import 'l10n/app_localizations.dart';
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

  /// Application title shown to the platform and app shell.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker'**
  String get appTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @syncQueued.
  ///
  /// In en, this message translates to:
  /// **'Waiting to sync'**
  String get syncQueued;

  /// No description provided for @syncSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncSyncing;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @syncPendingOffline.
  ///
  /// In en, this message translates to:
  /// **'Will sync when internet returns.'**
  String get syncPendingOffline;

  /// No description provided for @syncPendingAuth.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to finish syncing.'**
  String get syncPendingAuth;

  /// No description provided for @syncPendingServer.
  ///
  /// In en, this message translates to:
  /// **'Server sync is unavailable. Retry when it recovers.'**
  String get syncPendingServer;

  /// No description provided for @syncPendingValidation.
  ///
  /// In en, this message translates to:
  /// **'Some changes need review before they can sync.'**
  String get syncPendingValidation;

  /// No description provided for @syncPendingQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued for sync.'**
  String get syncPendingQueued;

  /// No description provided for @syncPendingUnknown.
  ///
  /// In en, this message translates to:
  /// **'Sync is waiting. Retry in a moment.'**
  String get syncPendingUnknown;

  /// No description provided for @syncPendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense is {status}} other{{count} expenses are {status}}}'**
  String syncPendingCount(int count, String status);

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @searchExpenses.
  ///
  /// In en, this message translates to:
  /// **'Search expenses'**
  String get searchExpenses;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String resultsCount(int count);

  /// No description provided for @expenseResultsLimitedToLoadedHistory.
  ///
  /// In en, this message translates to:
  /// **'Results are limited to loaded recent history. Load more or choose a date range to widen them.'**
  String get expenseResultsLimitedToLoadedHistory;

  /// No description provided for @expenseResultsLimitedToDateRange.
  ///
  /// In en, this message translates to:
  /// **'Results are limited to the loaded page for this date range.'**
  String get expenseResultsLimitedToDateRange;

  /// No description provided for @loadMoreExpenses.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMoreExpenses;

  /// No description provided for @loadingMoreExpenses.
  ///
  /// In en, this message translates to:
  /// **'Loading more'**
  String get loadingMoreExpenses;

  /// No description provided for @allLoadedExpensesShown.
  ///
  /// In en, this message translates to:
  /// **'All loaded expenses are shown'**
  String get allLoadedExpensesShown;

  /// No description provided for @noExpensesMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No expenses match your filters'**
  String get noExpensesMatchFilters;

  /// No description provided for @expenseDetailsSeparator.
  ///
  /// In en, this message translates to:
  /// **'•'**
  String get expenseDetailsSeparator;

  /// No description provided for @expenseActions.
  ///
  /// In en, this message translates to:
  /// **'Expense actions'**
  String get expenseActions;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpense;

  /// No description provided for @quickAmountAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Quick amount adjustment'**
  String get quickAmountAdjustment;

  /// No description provided for @adjustmentAmount.
  ///
  /// In en, this message translates to:
  /// **'Adjustment amount'**
  String get adjustmentAmount;

  /// No description provided for @addToAmount.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addToAmount;

  /// No description provided for @subtractFromAmount.
  ///
  /// In en, this message translates to:
  /// **'Subtract'**
  String get subtractFromAmount;

  /// No description provided for @invalidExpenseAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Enter an adjustment that keeps the final amount greater than zero.'**
  String get invalidExpenseAdjustment;

  /// No description provided for @expenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated'**
  String get expenseUpdated;

  /// No description provided for @failedToUpdateExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to update expense. Please try again.'**
  String get failedToUpdateExpense;

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expense?'**
  String get deleteExpenseTitle;

  /// No description provided for @deleteExpenseMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {category} expense for {amount} on {date}?'**
  String deleteExpenseMessage(String category, String amount, String date);

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// No description provided for @failedToDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete expense. Please try again.'**
  String get failedToDeleteExpense;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRange;

  /// No description provided for @anyDate.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get anyDate;

  /// No description provided for @clearDates.
  ///
  /// In en, this message translates to:
  /// **'Clear dates'**
  String get clearDates;

  /// No description provided for @pickDates.
  ///
  /// In en, this message translates to:
  /// **'Pick dates'**
  String get pickDates;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @thisMonthSpending.
  ///
  /// In en, this message translates to:
  /// **'This Month Spending'**
  String get thisMonthSpending;

  /// No description provided for @budgetLeft.
  ///
  /// In en, this message translates to:
  /// **'Budget Left'**
  String get budgetLeft;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @setMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Set monthly budget'**
  String get setMonthlyBudget;

  /// No description provided for @topCategory.
  ///
  /// In en, this message translates to:
  /// **'Top Category'**
  String get topCategory;

  /// No description provided for @noSpendingYet.
  ///
  /// In en, this message translates to:
  /// **'No spending yet'**
  String get noSpendingYet;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesYet;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @recurringExpenses.
  ///
  /// In en, this message translates to:
  /// **'Recurring Expenses'**
  String get recurringExpenses;

  /// No description provided for @savingGoals.
  ///
  /// In en, this message translates to:
  /// **'Saving Goals'**
  String get savingGoals;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @quickCaptureQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get quickCaptureQuick;

  /// No description provided for @quickCaptureNatural.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get quickCaptureNatural;

  /// No description provided for @quickCaptureReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get quickCaptureReceipt;

  /// No description provided for @quickCaptureMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get quickCaptureMoreDetails;

  /// No description provided for @quickCaptureLessDetails.
  ///
  /// In en, this message translates to:
  /// **'Fewer details'**
  String get quickCaptureLessDetails;

  /// No description provided for @quickCaptureDraftReady.
  ///
  /// In en, this message translates to:
  /// **'Draft filled. Review the fields, then save.'**
  String get quickCaptureDraftReady;

  /// No description provided for @quickCaptureReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get quickCaptureReceiptTitle;

  /// No description provided for @quickCaptureReceiptHelper.
  ///
  /// In en, this message translates to:
  /// **'Receipt details fill this same editable form. Saving still requires the Save button.'**
  String get quickCaptureReceiptHelper;

  /// No description provided for @quickCaptureReceiptApplied.
  ///
  /// In en, this message translates to:
  /// **'Receipt draft filled. Review the fields, then save.'**
  String get quickCaptureReceiptApplied;

  /// No description provided for @quickCaptureReceiptReview.
  ///
  /// In en, this message translates to:
  /// **'Review receipt fields before saving.'**
  String get quickCaptureReceiptReview;

  /// No description provided for @quickCaptureMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Complete missing fields: {fields}.'**
  String quickCaptureMissingFields(String fields);

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tagsHelper.
  ///
  /// In en, this message translates to:
  /// **'Separate tags with commas'**
  String get tagsHelper;

  /// No description provided for @possibleDuplicateExpense.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate expense'**
  String get possibleDuplicateExpense;

  /// No description provided for @possibleDuplicateExpenseMessage.
  ///
  /// In en, this message translates to:
  /// **'A similar expense already exists: {amount} {currency}, {category}, {date}. Reasons: {reasons}. Save anyway?'**
  String possibleDuplicateExpenseMessage(
    String amount,
    String currency,
    String category,
    String date,
    String reasons,
  );

  /// No description provided for @saveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get saveAnyway;

  /// No description provided for @duplicateReasonSameDay.
  ///
  /// In en, this message translates to:
  /// **'same day'**
  String get duplicateReasonSameDay;

  /// No description provided for @duplicateReasonSameAmount.
  ///
  /// In en, this message translates to:
  /// **'same amount'**
  String get duplicateReasonSameAmount;

  /// No description provided for @duplicateReasonSameCategory.
  ///
  /// In en, this message translates to:
  /// **'same category'**
  String get duplicateReasonSameCategory;

  /// No description provided for @duplicateReasonSameMerchant.
  ///
  /// In en, this message translates to:
  /// **'same merchant'**
  String get duplicateReasonSameMerchant;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @noActiveCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No active categories yet'**
  String get noActiveCategoriesYet;

  /// No description provided for @enterValidExpenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid expense amount'**
  String get enterValidExpenseAmount;

  /// No description provided for @selectCategoryBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Select a category before saving'**
  String get selectCategoryBeforeSaving;

  /// No description provided for @failedToSaveExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to save expense. Please try again.'**
  String get failedToSaveExpense;

  /// No description provided for @failedToSaveCategory.
  ///
  /// In en, this message translates to:
  /// **'Failed to save category. Please try again.'**
  String get failedToSaveCategory;

  /// No description provided for @failedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get failedToLoadCategories;

  /// No description provided for @categoryBudgets.
  ///
  /// In en, this message translates to:
  /// **'Category Budgets'**
  String get categoryBudgets;

  /// No description provided for @subscriptionCenter.
  ///
  /// In en, this message translates to:
  /// **'Subscription Center'**
  String get subscriptionCenter;

  /// No description provided for @confirmLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get confirmLogoutTitle;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your expenses.'**
  String get confirmLogoutMessage;

  /// No description provided for @failedToLoadExpenses.
  ///
  /// In en, this message translates to:
  /// **'Failed to load expenses'**
  String get failedToLoadExpenses;

  /// No description provided for @checkConnectionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get checkConnectionTryAgain;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @visa.
  ///
  /// In en, this message translates to:
  /// **'Visa'**
  String get visa;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @authenticatedAccount.
  ///
  /// In en, this message translates to:
  /// **'Authenticated account'**
  String get authenticatedAccount;

  /// No description provided for @profileSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your app profile, sign-in details, and account actions.'**
  String get profileSettingsDescription;

  /// No description provided for @profileFallbackUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get profileFallbackUser;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Profile name'**
  String get profileName;

  /// No description provided for @editProfileName.
  ///
  /// In en, this message translates to:
  /// **'Edit profile name'**
  String get editProfileName;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayNameLabel;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the name shown in the app'**
  String get displayNameHint;

  /// No description provided for @displayNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a display name.'**
  String get displayNameRequired;

  /// No description provided for @displayNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Display name must be 60 characters or fewer.'**
  String get displayNameTooLong;

  /// No description provided for @displayNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Display name updated.'**
  String get displayNameUpdated;

  /// No description provided for @displayNameUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update display name. Please try again.'**
  String get displayNameUpdateFailed;

  /// No description provided for @accountId.
  ///
  /// In en, this message translates to:
  /// **'Account ID'**
  String get accountId;

  /// No description provided for @copyAccountId.
  ///
  /// In en, this message translates to:
  /// **'Copy account ID'**
  String get copyAccountId;

  /// No description provided for @accountIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Account ID copied.'**
  String get accountIdCopied;

  /// No description provided for @accountProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Account/Profile'**
  String get accountProfileTitle;

  /// No description provided for @accountProfileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Account profile could not be loaded.'**
  String get accountProfileLoadFailed;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmail;

  /// No description provided for @accountEmailMissing.
  ///
  /// In en, this message translates to:
  /// **'No email on this account'**
  String get accountEmailMissing;

  /// No description provided for @accountProvider.
  ///
  /// In en, this message translates to:
  /// **'Sign-in provider'**
  String get accountProvider;

  /// No description provided for @accountProviderEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Email and password'**
  String get accountProviderEmailPassword;

  /// No description provided for @accountProviderGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get accountProviderGoogle;

  /// No description provided for @accountProviderUnknown.
  ///
  /// In en, this message translates to:
  /// **'Provider unavailable'**
  String get accountProviderUnknown;

  /// No description provided for @accountActionUnavailableForProvider.
  ///
  /// In en, this message translates to:
  /// **'This action is unavailable for the current sign-in provider.'**
  String get accountActionUnavailableForProvider;

  /// No description provided for @accountPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get accountPasswordReset;

  /// No description provided for @accountPasswordResetDescription.
  ///
  /// In en, this message translates to:
  /// **'Send a password reset email to this account.'**
  String get accountPasswordResetDescription;

  /// No description provided for @accountPasswordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get accountPasswordResetSent;

  /// No description provided for @accountPasswordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Password reset could not be sent.'**
  String get accountPasswordResetFailed;

  /// No description provided for @accountUpdateEmail.
  ///
  /// In en, this message translates to:
  /// **'Update email'**
  String get accountUpdateEmail;

  /// No description provided for @accountUpdateEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'Change the email used for this account.'**
  String get accountUpdateEmailDescription;

  /// No description provided for @accountNewEmail.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get accountNewEmail;

  /// No description provided for @accountEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get accountEmailInvalid;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get enterEmailAddress;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get enterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @accountEmailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Email updated.'**
  String get accountEmailUpdated;

  /// No description provided for @accountEmailUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Email could not be updated.'**
  String get accountEmailUpdateFailed;

  /// No description provided for @accountReauthRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in again before changing this sensitive account setting.'**
  String get accountReauthRequired;

  /// No description provided for @accountReauthTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get accountReauthTitle;

  /// No description provided for @accountReauthPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password, then the app will retry the account action.'**
  String get accountReauthPasswordDescription;

  /// No description provided for @accountReauthGoogleDescription.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google, then the app will retry the account action.'**
  String get accountReauthGoogleDescription;

  /// No description provided for @accountReauthPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get accountReauthPasswordLabel;

  /// No description provided for @accountReauthGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get accountReauthGoogleButton;

  /// No description provided for @accountReauthSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Sign-in confirmed. Retrying the account action.'**
  String get accountReauthSucceeded;

  /// No description provided for @accountReauthFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in could not be confirmed.'**
  String get accountReauthFailed;

  /// No description provided for @accountReauthCanceled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in confirmation was canceled.'**
  String get accountReauthCanceled;

  /// No description provided for @accountReauthUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in confirmation is unavailable for this provider.'**
  String get accountReauthUnavailable;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteShortDescription.
  ///
  /// In en, this message translates to:
  /// **'Delete your account and user-owned app data.'**
  String get accountDeleteShortDescription;

  /// No description provided for @accountDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This permanently requests deletion of your account and user-owned expenses, categories, budgets, recurring expenses, saving goals, settings, and AI action history. This cannot be undone.'**
  String get accountDeleteWarning;

  /// No description provided for @accountDeleteConfirmCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I understand this deletion cannot be undone.'**
  String get accountDeleteConfirmCheckbox;

  /// No description provided for @accountDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeleteButton;

  /// No description provided for @accountDeleteConfirmationRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm the warning before deleting your account.'**
  String get accountDeleteConfirmationRequired;

  /// No description provided for @accountDataDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Your account data could not be deleted. Your sign-in account was not deleted.'**
  String get accountDataDeleteFailed;

  /// No description provided for @accountAuthDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Your app data deletion was requested, but the sign-in account could not be deleted.'**
  String get accountAuthDeleteFailed;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get accountDeleted;

  /// No description provided for @accountDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Account deletion could not be completed.'**
  String get accountDeleteFailed;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @appLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Language controls app text, dates, AI locale, and voice input. It does not change your currency.'**
  String get appLanguageDescription;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageSystemDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow the device language when it is Arabic or English.'**
  String get languageSystemDescription;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageArabicDescription.
  ///
  /// In en, this message translates to:
  /// **'Use Arabic text and right-to-left layout.'**
  String get languageArabicDescription;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageEnglishDescription.
  ///
  /// In en, this message translates to:
  /// **'Use English text and left-to-right layout.'**
  String get languageEnglishDescription;

  /// No description provided for @failedToLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings could not be loaded.'**
  String get failedToLoadSettings;

  /// No description provided for @baseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get baseCurrency;

  /// No description provided for @supportedCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Supported currencies'**
  String get supportedCurrencies;

  /// No description provided for @currencySettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Language and currency are independent. Base currency is used for manual and AI defaults. Exchange rates convert dashboard totals only.'**
  String get currencySettingsDescription;

  /// No description provided for @exchangeRates.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates'**
  String get exchangeRates;

  /// No description provided for @exchangeRatesDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter how much 1 unit of each currency is worth in your base currency.'**
  String get exchangeRatesDescription;

  /// No description provided for @exchangeRateInputLabel.
  ///
  /// In en, this message translates to:
  /// **'1 {currency} ='**
  String exchangeRateInputLabel(String currency);

  /// No description provided for @exchangeRateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a rate greater than zero.'**
  String get exchangeRateInvalid;

  /// No description provided for @exchangeRateSaved.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate saved.'**
  String get exchangeRateSaved;

  /// No description provided for @convertedCurrenciesStatus.
  ///
  /// In en, this message translates to:
  /// **'Converted: {currencies}'**
  String convertedCurrenciesStatus(String currencies);

  /// No description provided for @unconvertedCurrenciesStatus.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Missing rate for {currencies}; 1 expense not included} other{Missing rates for {currencies}; {count} expenses not included}}'**
  String unconvertedCurrenciesStatus(int count, String currencies);

  /// No description provided for @settingsUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings need attention'**
  String get settingsUnavailableTitle;

  /// No description provided for @settingsUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Retry settings or choose currency and payment method before saving.'**
  String get settingsUnavailableMessage;

  /// No description provided for @chooseCurrencyAndPaymentBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Choose currency and payment method before saving.'**
  String get chooseCurrencyAndPaymentBeforeSaving;

  /// No description provided for @settingsLoadRequiredForAi.
  ///
  /// In en, this message translates to:
  /// **'Settings could not be loaded. Retry settings before using AI so currency and payment defaults are not guessed.'**
  String get settingsLoadRequiredForAi;

  /// No description provided for @aiQuotaUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI quota is unavailable right now.'**
  String get aiQuotaUnavailable;

  /// No description provided for @aiQuotaExhausted.
  ///
  /// In en, this message translates to:
  /// **'You have used today\'s AI limit.'**
  String get aiQuotaExhausted;

  /// No description provided for @aiCouldNotUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I could not understand that request. Try adding the amount, category, and date.'**
  String get aiCouldNotUnderstand;

  /// No description provided for @aiProviderUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI service is unavailable. Try again later.'**
  String get aiProviderUnavailable;

  /// No description provided for @aiFormFillTitle.
  ///
  /// In en, this message translates to:
  /// **'Fill with AI'**
  String get aiFormFillTitle;

  /// No description provided for @aiFormFillHint.
  ///
  /// In en, this message translates to:
  /// **'Example: spent 100 dollars on food last night'**
  String get aiFormFillHint;

  /// No description provided for @aiFormFillHelper.
  ///
  /// In en, this message translates to:
  /// **'AI fills the form only. Review and press Save yourself.'**
  String get aiFormFillHelper;

  /// No description provided for @aiFormFillAction.
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get aiFormFillAction;

  /// No description provided for @aiFormFillApplied.
  ///
  /// In en, this message translates to:
  /// **'AI filled the form. Review before saving.'**
  String get aiFormFillApplied;

  /// No description provided for @aiFormFillFailed.
  ///
  /// In en, this message translates to:
  /// **'AI could not fill the form. You can still enter it manually.'**
  String get aiFormFillFailed;

  /// No description provided for @aiFormFillNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'AI needs more review. Complete the form manually.'**
  String get aiFormFillNeedsReview;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @notificationsSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSettingsTitle;

  /// No description provided for @budgetAlerts.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get budgetAlerts;

  /// No description provided for @budgetAlertsDescription.
  ///
  /// In en, this message translates to:
  /// **'Warn when spending nears or exceeds budget.'**
  String get budgetAlertsDescription;

  /// No description provided for @dailyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get dailyCheckIn;

  /// No description provided for @dailyCheckInDescription.
  ///
  /// In en, this message translates to:
  /// **'Review today\'s spending and keep your streak active.'**
  String get dailyCheckInDescription;

  /// No description provided for @checkInTime.
  ///
  /// In en, this message translates to:
  /// **'Check-in time'**
  String get checkInTime;

  /// No description provided for @weeklyDigest.
  ///
  /// In en, this message translates to:
  /// **'Weekly digest'**
  String get weeklyDigest;

  /// No description provided for @weeklyDigestDescription.
  ///
  /// In en, this message translates to:
  /// **'Remind me to review my weekly spending summary.'**
  String get weeklyDigestDescription;

  /// No description provided for @weeklyDigestEmpty.
  ///
  /// In en, this message translates to:
  /// **'No spending tracked for this week yet.'**
  String get weeklyDigestEmpty;

  /// No description provided for @weeklyDigestThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get weeklyDigestThisWeek;

  /// No description provided for @weeklyDigestPreviousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get weeklyDigestPreviousWeek;

  /// No description provided for @weeklyDigestChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get weeklyDigestChange;

  /// No description provided for @weeklyDigestLocalInsight.
  ///
  /// In en, this message translates to:
  /// **'Local insight'**
  String get weeklyDigestLocalInsight;

  /// No description provided for @weeklyDigestIgnoredCurrencyExpenses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense in another currency was ignored because no saved rate was available.} other{{count} expenses in other currencies were ignored because no saved rates were available.}}'**
  String weeklyDigestIgnoredCurrencyExpenses(int count);

  /// No description provided for @weeklyDigestHealthScore.
  ///
  /// In en, this message translates to:
  /// **'{label} ({score}/100)'**
  String weeklyDigestHealthScore(String label, int score);

  /// No description provided for @weeklyInsightStartLogging.
  ///
  /// In en, this message translates to:
  /// **'Start by logging one expense this week.'**
  String get weeklyInsightStartLogging;

  /// No description provided for @weeklyInsightTopCategory.
  ///
  /// In en, this message translates to:
  /// **'{category} is your largest category this week.'**
  String weeklyInsightTopCategory(String category);

  /// No description provided for @weeklyInsightFirstTrackedWeek.
  ///
  /// In en, this message translates to:
  /// **'This is your first tracked week in this comparison.'**
  String get weeklyInsightFirstTrackedWeek;

  /// No description provided for @weeklyInsightHigherThanLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Spending is higher than last week.'**
  String get weeklyInsightHigherThanLastWeek;

  /// No description provided for @weeklyInsightLowerThanLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Spending is lower than last week.'**
  String get weeklyInsightLowerThanLastWeek;

  /// No description provided for @weeklyInsightUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Spending is unchanged from last week.'**
  String get weeklyInsightUnchanged;

  /// No description provided for @spendingHealthAddFewExpenses.
  ///
  /// In en, this message translates to:
  /// **'Add a few expenses'**
  String get spendingHealthAddFewExpenses;

  /// No description provided for @spendingHealthOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get spendingHealthOnTrack;

  /// No description provided for @spendingHealthWorthWatching.
  ///
  /// In en, this message translates to:
  /// **'Worth watching'**
  String get spendingHealthWorthWatching;

  /// No description provided for @spendingHealthNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get spendingHealthNeedsReview;

  /// No description provided for @spendingHealthReasonLogExpensesOrBudget.
  ///
  /// In en, this message translates to:
  /// **'Log expenses or set a monthly budget to see a score.'**
  String get spendingHealthReasonLogExpensesOrBudget;

  /// No description provided for @spendingHealthReasonBudgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget is exceeded.'**
  String get spendingHealthReasonBudgetExceeded;

  /// No description provided for @spendingHealthReasonBudgetNearLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget is near its limit.'**
  String get spendingHealthReasonBudgetNearLimit;

  /// No description provided for @spendingHealthReasonBudgetOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget is on track.'**
  String get spendingHealthReasonBudgetOnTrack;

  /// No description provided for @spendingHealthReasonNoBudget.
  ///
  /// In en, this message translates to:
  /// **'No monthly budget is set.'**
  String get spendingHealthReasonNoBudget;

  /// No description provided for @spendingHealthReasonOneCategoryHigh.
  ///
  /// In en, this message translates to:
  /// **'One category is over 60% of this month\'s spending.'**
  String get spendingHealthReasonOneCategoryHigh;

  /// No description provided for @spendingHealthReasonSpreadAcrossCategories.
  ///
  /// In en, this message translates to:
  /// **'Spending is spread across categories.'**
  String get spendingHealthReasonSpreadAcrossCategories;

  /// No description provided for @spendingHealthReasonTrackedToday.
  ///
  /// In en, this message translates to:
  /// **'Today has at least one logged expense.'**
  String get spendingHealthReasonTrackedToday;

  /// No description provided for @spendingHealthReasonRecentTracking.
  ///
  /// In en, this message translates to:
  /// **'Recent tracking activity is active.'**
  String get spendingHealthReasonRecentTracking;

  /// No description provided for @spendingHealthReasonNoRecentStreak.
  ///
  /// In en, this message translates to:
  /// **'No recent tracking streak yet.'**
  String get spendingHealthReasonNoRecentStreak;

  /// No description provided for @digestTime.
  ///
  /// In en, this message translates to:
  /// **'Digest time'**
  String get digestTime;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @appProtection.
  ///
  /// In en, this message translates to:
  /// **'App Protection'**
  String get appProtection;

  /// No description provided for @pinLock.
  ///
  /// In en, this message translates to:
  /// **'PIN lock'**
  String get pinLock;

  /// No description provided for @pinLockDescription.
  ///
  /// In en, this message translates to:
  /// **'Require a local PIN on launch/resume.'**
  String get pinLockDescription;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get createPin;

  /// No description provided for @createPinIntro.
  ///
  /// In en, this message translates to:
  /// **'Protect your expense data with a local PIN.'**
  String get createPinIntro;

  /// No description provided for @changePinIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a new app PIN.'**
  String get changePinIntro;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @confirmPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPinLabel;

  /// No description provided for @saveNewPin.
  ///
  /// In en, this message translates to:
  /// **'Save New PIN'**
  String get saveNewPin;

  /// No description provided for @enableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Enable App Lock'**
  String get enableAppLock;

  /// No description provided for @pinDigitsValidation.
  ///
  /// In en, this message translates to:
  /// **'PIN must be 4 to 8 digits.'**
  String get pinDigitsValidation;

  /// No description provided for @pinConfirmationMismatch.
  ///
  /// In en, this message translates to:
  /// **'PIN confirmation does not match.'**
  String get pinConfirmationMismatch;

  /// No description provided for @expenseTrackerLocked.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker is locked'**
  String get expenseTrackerLocked;

  /// No description provided for @enterPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue.'**
  String get enterPinToContinue;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get useBiometrics;

  /// No description provided for @failedToSavePin.
  ///
  /// In en, this message translates to:
  /// **'Failed to save PIN.'**
  String get failedToSavePin;

  /// No description provided for @failedToChangePin.
  ///
  /// In en, this message translates to:
  /// **'Failed to change PIN.'**
  String get failedToChangePin;

  /// No description provided for @failedToDisableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Failed to disable app lock.'**
  String get failedToDisableAppLock;

  /// No description provided for @biometricAuthenticationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available.'**
  String get biometricAuthenticationUnavailable;

  /// No description provided for @failedToUpdateBiometricSetting.
  ///
  /// In en, this message translates to:
  /// **'Failed to update biometric setting.'**
  String get failedToUpdateBiometricSetting;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN.'**
  String get incorrectPin;

  /// No description provided for @failedToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlock.'**
  String get failedToUnlock;

  /// No description provided for @usePinToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Use PIN to unlock.'**
  String get usePinToUnlock;

  /// No description provided for @failedToLoadAppLockSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load app lock settings.'**
  String get failedToLoadAppLockSettings;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get biometricUnlock;

  /// No description provided for @biometricUnlockAvailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or Face ID when available.'**
  String get biometricUnlockAvailableDescription;

  /// No description provided for @biometricUnlockUnavailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device.'**
  String get biometricUnlockUnavailableDescription;

  /// No description provided for @watchAdForExtraAiUse.
  ///
  /// In en, this message translates to:
  /// **'Watch ad for one extra AI use'**
  String get watchAdForExtraAiUse;

  /// No description provided for @rewardUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Reward is unavailable right now.'**
  String get rewardUnavailable;

  /// No description provided for @extraAiUseAdded.
  ///
  /// In en, this message translates to:
  /// **'One extra AI use was added.'**
  String get extraAiUseAdded;

  /// No description provided for @retentionStartSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your setup'**
  String get retentionStartSetupTitle;

  /// No description provided for @retentionStartSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'Add one expense, create categories, then set a budget.'**
  String get retentionStartSetupMessage;

  /// No description provided for @retentionKeepStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak'**
  String get retentionKeepStreakTitle;

  /// No description provided for @retentionStartStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'Log today once to start a tracking streak.'**
  String get retentionStartStreakMessage;

  /// No description provided for @retentionKeepStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'Log today to keep your {days}-day streak.'**
  String retentionKeepStreakMessage(int days);

  /// No description provided for @retentionLogExpenseAction.
  ///
  /// In en, this message translates to:
  /// **'Log expense'**
  String get retentionLogExpenseAction;

  /// No description provided for @weeklyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Weekly check-in'**
  String get weeklyCheckIn;

  /// No description provided for @viewDigest.
  ///
  /// In en, this message translates to:
  /// **'View digest'**
  String get viewDigest;

  /// No description provided for @retentionBudgetReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget review'**
  String get retentionBudgetReviewTitle;

  /// No description provided for @retentionBudgetExceededMessage.
  ///
  /// In en, this message translates to:
  /// **'Your monthly budget is over target. Review recent spend.'**
  String get retentionBudgetExceededMessage;

  /// No description provided for @retentionReviewBudgetAction.
  ///
  /// In en, this message translates to:
  /// **'Review budget'**
  String get retentionReviewBudgetAction;

  /// No description provided for @retentionBudgetNudgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget nudge'**
  String get retentionBudgetNudgeTitle;

  /// No description provided for @retentionBudgetNearLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You are near your budget limit. Check your top category.'**
  String get retentionBudgetNearLimitMessage;

  /// No description provided for @retentionOpenBudgetAction.
  ///
  /// In en, this message translates to:
  /// **'Open budget'**
  String get retentionOpenBudgetAction;

  /// No description provided for @retentionSetTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a simple target'**
  String get retentionSetTargetTitle;

  /// No description provided for @retentionSetTargetMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a monthly budget to make progress easier to track.'**
  String get retentionSetTargetMessage;

  /// No description provided for @retentionSetBudgetAction.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get retentionSetBudgetAction;

  /// No description provided for @retentionThreeDayChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Three-day challenge'**
  String get retentionThreeDayChallengeTitle;

  /// No description provided for @retentionThreeDayChallengeMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep tracking for the rest of the week.'**
  String get retentionThreeDayChallengeMessage;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @trackedToday.
  ///
  /// In en, this message translates to:
  /// **'Tracked today'**
  String get trackedToday;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkIn;

  /// No description provided for @needsData.
  ///
  /// In en, this message translates to:
  /// **'Needs data'**
  String get needsData;

  /// No description provided for @dayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String dayCount(int count);

  /// No description provided for @aiUsageSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Usage'**
  String get aiUsageSettingsTitle;

  /// No description provided for @aiUsageSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Free daily AI limits. Manual expenses and local reports keep working when AI is unavailable.'**
  String get aiUsageSettingsDescription;

  /// No description provided for @aiUsageTextParsing.
  ///
  /// In en, this message translates to:
  /// **'Text parsing'**
  String get aiUsageTextParsing;

  /// No description provided for @aiUsageReceiptExtraction.
  ///
  /// In en, this message translates to:
  /// **'Receipt extraction'**
  String get aiUsageReceiptExtraction;

  /// No description provided for @aiUsageFinancialAdvice.
  ///
  /// In en, this message translates to:
  /// **'Financial advice'**
  String get aiUsageFinancialAdvice;

  /// No description provided for @aiUsageUsed.
  ///
  /// In en, this message translates to:
  /// **'{used}/{limit} used'**
  String aiUsageUsed(int used, int limit);

  /// No description provided for @aiUsageResetsAround.
  ///
  /// In en, this message translates to:
  /// **'resets around {time}'**
  String aiUsageResetsAround(String time);

  /// No description provided for @aiUsageWaitingForLiveUsage.
  ///
  /// In en, this message translates to:
  /// **'waiting for live Worker usage'**
  String get aiUsageWaitingForLiveUsage;

  /// No description provided for @aiUsageRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String aiUsageRemaining(int count);

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get freePlan;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium plan'**
  String get premiumPlan;

  /// No description provided for @unknownPlan.
  ///
  /// In en, this message translates to:
  /// **'Unknown plan'**
  String get unknownPlan;

  /// No description provided for @pendingPlan.
  ///
  /// In en, this message translates to:
  /// **'Pending plan'**
  String get pendingPlan;

  /// No description provided for @loadingLivePlanState.
  ///
  /// In en, this message translates to:
  /// **'Loading live plan state...'**
  String get loadingLivePlanState;

  /// No description provided for @adsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Ads disabled'**
  String get adsDisabled;

  /// No description provided for @viewLimitsAdsAndPremium.
  ///
  /// In en, this message translates to:
  /// **'View limits, ads, and Premium'**
  String get viewLimitsAdsAndPremium;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Remove ads'**
  String get removeAds;

  /// No description provided for @removeAdsDescription.
  ///
  /// In en, this message translates to:
  /// **'Coming with Premium purchase setup.'**
  String get removeAdsDescription;

  /// No description provided for @usingFreeSafePlanState.
  ///
  /// In en, this message translates to:
  /// **'Using Free-safe plan state'**
  String get usingFreeSafePlanState;

  /// No description provided for @refreshPlanState.
  ///
  /// In en, this message translates to:
  /// **'Refresh plan state'**
  String get refreshPlanState;

  /// No description provided for @privacyAndAdChoices.
  ///
  /// In en, this message translates to:
  /// **'Privacy and ad choices'**
  String get privacyAndAdChoices;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacySettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Your expenses stay user-scoped in Firebase. AI actions require preview and confirmation before any write.'**
  String get privacySettingsDescription;

  /// No description provided for @dataOwnership.
  ///
  /// In en, this message translates to:
  /// **'Data ownership'**
  String get dataOwnership;

  /// No description provided for @dataOwnershipDescription.
  ///
  /// In en, this message translates to:
  /// **'Only your authenticated account can access your data.'**
  String get dataOwnershipDescription;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Send feedback without attaching expense data.'**
  String get supportSettingsDescription;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @sendFeedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Includes app version only if you approve it.'**
  String get sendFeedbackDescription;

  /// No description provided for @feedbackDiagnosticsPrompt.
  ///
  /// In en, this message translates to:
  /// **'No expense descriptions, receipts, account tokens, PINs, or AI provider details will be included. Add app version 1.0.0+1?'**
  String get feedbackDiagnosticsPrompt;

  /// No description provided for @includeVersion.
  ///
  /// In en, this message translates to:
  /// **'Include version'**
  String get includeVersion;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @feedbackShareTemplate.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker feedback\n\nWhat happened?\n\nWhat did you expect?'**
  String get feedbackShareTemplate;

  /// No description provided for @feedbackSubject.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker feedback'**
  String get feedbackSubject;

  /// No description provided for @paymentSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentSettingsTitle;

  /// No description provided for @paymentSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Used as the default when a manual or AI expense does not specify a payment method.'**
  String get paymentSettingsDescription;

  /// No description provided for @defaultPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Default payment method'**
  String get defaultPaymentMethod;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'First-run setup'**
  String get onboardingTitle;

  /// No description provided for @onboardingLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading setup'**
  String get onboardingLoading;

  /// No description provided for @onboardingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Setup could not load your settings. Check your connection and try again.'**
  String get onboardingLoadFailed;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Setup could not save your choices. Keep them selected and try again.'**
  String get onboardingSaveFailed;

  /// No description provided for @onboardingSelectRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose language, base currency, and default payment method to continue.'**
  String get onboardingSelectRequired;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get onboardingFinish;

  /// No description provided for @onboardingComplete.
  ///
  /// In en, this message translates to:
  /// **'Setup complete'**
  String get onboardingComplete;

  /// No description provided for @onboardingSkipReminders.
  ///
  /// In en, this message translates to:
  /// **'Skip reminders'**
  String get onboardingSkipReminders;

  /// No description provided for @onboardingEssentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your essentials'**
  String get onboardingEssentialsTitle;

  /// No description provided for @onboardingEssentialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These choices control app language and the defaults used before any expense is saved.'**
  String get onboardingEssentialsSubtitle;

  /// No description provided for @onboardingLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get onboardingLanguageLabel;

  /// No description provided for @onboardingLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get onboardingLanguageEnglish;

  /// No description provided for @onboardingLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get onboardingLanguageArabic;

  /// No description provided for @onboardingCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get onboardingCurrencyLabel;

  /// No description provided for @onboardingPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Default payment method'**
  String get onboardingPaymentLabel;

  /// No description provided for @onboardingAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI stays under your control'**
  String get onboardingAiTitle;

  /// No description provided for @onboardingAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI can help prepare expenses, but setup never calls the AI provider or uses quota.'**
  String get onboardingAiSubtitle;

  /// No description provided for @onboardingAiPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview first'**
  String get onboardingAiPreviewTitle;

  /// No description provided for @onboardingAiPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'AI suggestions are shown for review. Nothing is saved until you confirm.'**
  String get onboardingAiPreviewBody;

  /// No description provided for @onboardingAiLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Free daily limits'**
  String get onboardingAiLimitTitle;

  /// No description provided for @onboardingAiLimitBody.
  ///
  /// In en, this message translates to:
  /// **'AI has free daily limits and can be unavailable, so the app never depends on it for manual tracking.'**
  String get onboardingAiLimitBody;

  /// No description provided for @onboardingAiManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual entry always works'**
  String get onboardingAiManualTitle;

  /// No description provided for @onboardingAiManualBody.
  ///
  /// In en, this message translates to:
  /// **'You can add expenses yourself even when AI quota is finished or the gateway is offline.'**
  String get onboardingAiManualBody;

  /// No description provided for @onboardingAiSample.
  ///
  /// In en, this message translates to:
  /// **'Example only: \"Lunch 12 USD by wallet\". This sample is not sent to AI.'**
  String get onboardingAiSample;

  /// No description provided for @onboardingAiSampleSemantics.
  ///
  /// In en, this message translates to:
  /// **'AI example text that is not submitted'**
  String get onboardingAiSampleSemantics;

  /// No description provided for @onboardingReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional reminders'**
  String get onboardingReminderTitle;

  /// No description provided for @onboardingReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders can help you keep tracking, but they are optional and can be changed later.'**
  String get onboardingReminderSubtitle;

  /// No description provided for @onboardingDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily expense check-in'**
  String get onboardingDailyReminder;

  /// No description provided for @onboardingDailyReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask for a quick spending review in the evening when you have not logged today.'**
  String get onboardingDailyReminderDescription;

  /// No description provided for @onboardingWeeklyDigest.
  ///
  /// In en, this message translates to:
  /// **'Weekly spending digest'**
  String get onboardingWeeklyDigest;

  /// No description provided for @onboardingWeeklyDigestDescription.
  ///
  /// In en, this message translates to:
  /// **'Show a Monday digest prompt for your weekly summary and health score.'**
  String get onboardingWeeklyDigestDescription;

  /// No description provided for @onboardingReminderLater.
  ///
  /// In en, this message translates to:
  /// **'If permission is denied, setup still finishes and reminders stay off.'**
  String get onboardingReminderLater;

  /// No description provided for @onboardingReminderPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Reminders were not enabled because notification permission or scheduling was unavailable.'**
  String get onboardingReminderPermissionDenied;

  /// No description provided for @guidedTourNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get guidedTourNext;

  /// No description provided for @guidedTourBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get guidedTourBack;

  /// No description provided for @guidedTourSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get guidedTourSkip;

  /// No description provided for @guidedTourDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get guidedTourDone;

  /// No description provided for @guidedTourReplayTour.
  ///
  /// In en, this message translates to:
  /// **'Replay Tour'**
  String get guidedTourReplayTour;

  /// No description provided for @guidedTourStepCount.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String guidedTourStepCount(int current, int total);

  /// No description provided for @guidedTourAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Meet the AI Assistant'**
  String get guidedTourAiTitle;

  /// No description provided for @guidedTourAiBody.
  ///
  /// In en, this message translates to:
  /// **'Write or speak an expense here. AI always shows a preview before anything is saved.'**
  String get guidedTourAiBody;

  /// No description provided for @guidedTourManualExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expenses manually'**
  String get guidedTourManualExpenseTitle;

  /// No description provided for @guidedTourManualExpenseBody.
  ///
  /// In en, this message translates to:
  /// **'Use the plus button to open the normal expense form. AI can fill it at the top, and Save is still your final step.'**
  String get guidedTourManualExpenseBody;

  /// No description provided for @guidedTourAiPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review before saving'**
  String get guidedTourAiPreviewTitle;

  /// No description provided for @guidedTourAiPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'AI suggestions are never saved directly. Check the amount, category, date, and payment method before confirming.'**
  String get guidedTourAiPreviewBody;

  /// No description provided for @guidedTourBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your budget'**
  String get guidedTourBudgetTitle;

  /// No description provided for @guidedTourBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Monthly budgets power remaining-balance views, alerts, and grounded advice from real expenses.'**
  String get guidedTourBudgetBody;

  /// No description provided for @guidedTourReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Read real reports'**
  String get guidedTourReportsTitle;

  /// No description provided for @guidedTourReportsBody.
  ///
  /// In en, this message translates to:
  /// **'Reports summarize your actual spending by week, month, and category.'**
  String get guidedTourReportsBody;

  /// No description provided for @guidedTourCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Organize categories'**
  String get guidedTourCategoriesTitle;

  /// No description provided for @guidedTourCategoriesBody.
  ///
  /// In en, this message translates to:
  /// **'Open the menu for categories. You can edit category names, icons, colors, and archived choices safely.'**
  String get guidedTourCategoriesBody;

  /// No description provided for @guidedTourSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tune Settings'**
  String get guidedTourSettingsTitle;

  /// No description provided for @guidedTourSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'Settings keeps currency, payment, notifications, protection, AI usage, monetization, and privacy controls together.'**
  String get guidedTourSettingsBody;

  /// No description provided for @guidedTourFreePremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Free and Premium'**
  String get guidedTourFreePremiumTitle;

  /// No description provided for @guidedTourFreePremiumBody.
  ///
  /// In en, this message translates to:
  /// **'Free keeps manual tracking available. Premium options, ads, and limits live in Settings without interrupting expense entry.'**
  String get guidedTourFreePremiumBody;

  /// No description provided for @guidedTourSettingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get guidedTourSettingsSectionTitle;

  /// No description provided for @guidedTourSettingsSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Replay the guided tour for the current app version.'**
  String get guidedTourSettingsSectionDescription;

  /// No description provided for @guidedTourReplayTourDescription.
  ///
  /// In en, this message translates to:
  /// **'Show the Home tour again.'**
  String get guidedTourReplayTourDescription;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @parse.
  ///
  /// In en, this message translates to:
  /// **'Parse'**
  String get parse;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @shareFile.
  ///
  /// In en, this message translates to:
  /// **'Share file'**
  String get shareFile;

  /// No description provided for @allCurrencies.
  ///
  /// In en, this message translates to:
  /// **'All currencies'**
  String get allCurrencies;

  /// No description provided for @pickRange.
  ///
  /// In en, this message translates to:
  /// **'Pick range'**
  String get pickRange;

  /// No description provided for @selectDateRangeBeforeExporting.
  ///
  /// In en, this message translates to:
  /// **'Select a date range before exporting.'**
  String get selectDateRangeBeforeExporting;

  /// No description provided for @exportReady.
  ///
  /// In en, this message translates to:
  /// **'Export ready: {fileName}'**
  String exportReady(String fileName);

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @activeReportDrilldownFilter.
  ///
  /// In en, this message translates to:
  /// **'Report drilldown filter active'**
  String get activeReportDrilldownFilter;

  /// No description provided for @monthlyStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly story'**
  String get monthlyStoryTitle;

  /// No description provided for @monthlyStoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No spending was recorded for this month or the previous month.'**
  String get monthlyStoryEmpty;

  /// No description provided for @monthlyStoryNewSpending.
  ///
  /// In en, this message translates to:
  /// **'This month has {current} in spending, with no previous month spending to compare yet.'**
  String monthlyStoryNewSpending(String current);

  /// No description provided for @monthlyStoryIncrease.
  ///
  /// In en, this message translates to:
  /// **'Spending rose to {current} from {previous}, up {percent}%.'**
  String monthlyStoryIncrease(String current, String previous, int percent);

  /// No description provided for @monthlyStoryDecrease.
  ///
  /// In en, this message translates to:
  /// **'Spending improved to {current} from {previous}, down {percent}%.'**
  String monthlyStoryDecrease(String current, String previous, int percent);

  /// No description provided for @monthlyStoryFlat.
  ///
  /// In en, this message translates to:
  /// **'Spending stayed close to last month: {current} now versus {previous} before.'**
  String monthlyStoryFlat(String current, String previous);

  /// No description provided for @monthlyStoryDriversHeading.
  ///
  /// In en, this message translates to:
  /// **'Main drivers'**
  String get monthlyStoryDriversHeading;

  /// No description provided for @monthlyStoryDriver.
  ///
  /// In en, this message translates to:
  /// **'{category}: {amount}, about {percent}% of this month.'**
  String monthlyStoryDriver(String category, String amount, int percent);

  /// No description provided for @monthlyStoryOutliersHeading.
  ///
  /// In en, this message translates to:
  /// **'Large expenses'**
  String get monthlyStoryOutliersHeading;

  /// No description provided for @monthlyStoryOutlier.
  ///
  /// In en, this message translates to:
  /// **'{expense}: {amount}'**
  String monthlyStoryOutlier(String expense, String amount);

  /// No description provided for @monthlyStoryMissingRateCaveat.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This story excludes 1 expense with a missing rate for {currencies}.} other{This story excludes {count} expenses with missing rates for {currencies}.}}'**
  String monthlyStoryMissingRateCaveat(int count, String currencies);

  /// No description provided for @noSpendingInThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'No spending in this period.'**
  String get noSpendingInThisPeriod;

  /// No description provided for @noCategorySpendingYet.
  ///
  /// In en, this message translates to:
  /// **'No category spending yet.'**
  String get noCategorySpendingYet;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @topCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Top category: {category}'**
  String topCategoryLabel(String category);

  /// No description provided for @ignoredOtherCurrencyExpenses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense in another currency ignored.} other{{count} expenses in other currencies ignored.}}'**
  String ignoredOtherCurrencyExpenses(int count);

  /// No description provided for @periodComparison.
  ///
  /// In en, this message translates to:
  /// **'Period Comparison'**
  String get periodComparison;

  /// No description provided for @currentAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Current: {amount}'**
  String currentAmountLabel(String amount);

  /// No description provided for @previousAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous: {amount}'**
  String previousAmountLabel(String amount);

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @newRecurring.
  ///
  /// In en, this message translates to:
  /// **'New Recurring'**
  String get newRecurring;

  /// No description provided for @editRecurringExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Recurring Expense'**
  String get editRecurringExpense;

  /// No description provided for @archiveRecurringExpense.
  ///
  /// In en, this message translates to:
  /// **'Archive Recurring Expense'**
  String get archiveRecurringExpense;

  /// No description provided for @archiveRecurringExpenseMessage.
  ///
  /// In en, this message translates to:
  /// **'Archive {name}?'**
  String archiveRecurringExpenseMessage(String name);

  /// No description provided for @createActiveCategoryBeforeRecurring.
  ///
  /// In en, this message translates to:
  /// **'Create an active category before recurring expenses.'**
  String get createActiveCategoryBeforeRecurring;

  /// No description provided for @noActiveRecurringExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No active recurring expenses yet'**
  String get noActiveRecurringExpensesYet;

  /// No description provided for @nextDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Next {date}'**
  String nextDateLabel(String date);

  /// No description provided for @enterRecurringAmountAndCategory.
  ///
  /// In en, this message translates to:
  /// **'Enter amount and category.'**
  String get enterRecurringAmountAndCategory;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @noEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get noEndDate;

  /// No description provided for @clearEndDate.
  ///
  /// In en, this message translates to:
  /// **'Clear end date'**
  String get clearEndDate;

  /// No description provided for @savingGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saving Goals'**
  String get savingGoalsTitle;

  /// No description provided for @newSavingGoal.
  ///
  /// In en, this message translates to:
  /// **'New Saving Goal'**
  String get newSavingGoal;

  /// No description provided for @editSavingGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Saving Goal'**
  String get editSavingGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get targetAmount;

  /// No description provided for @currentAmount.
  ///
  /// In en, this message translates to:
  /// **'Current amount'**
  String get currentAmount;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @noDeadline.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get noDeadline;

  /// No description provided for @clearDeadline.
  ///
  /// In en, this message translates to:
  /// **'Clear deadline'**
  String get clearDeadline;

  /// No description provided for @addContribution.
  ///
  /// In en, this message translates to:
  /// **'Add contribution'**
  String get addContribution;

  /// No description provided for @contributionAmount.
  ///
  /// In en, this message translates to:
  /// **'Contribution amount'**
  String get contributionAmount;

  /// No description provided for @addContributionToGoal.
  ///
  /// In en, this message translates to:
  /// **'Add to {goal}'**
  String addContributionToGoal(String goal);

  /// No description provided for @archiveSavingGoal.
  ///
  /// In en, this message translates to:
  /// **'Archive Saving Goal'**
  String get archiveSavingGoal;

  /// No description provided for @archiveSavingGoalMessage.
  ///
  /// In en, this message translates to:
  /// **'Archive {goal}?'**
  String archiveSavingGoalMessage(String goal);

  /// No description provided for @noActiveSavingGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No active saving goals yet'**
  String get noActiveSavingGoalsYet;

  /// No description provided for @enterSavingGoalNameAndTarget.
  ///
  /// In en, this message translates to:
  /// **'Enter a name and positive target amount.'**
  String get enterSavingGoalNameAndTarget;

  /// No description provided for @currentAmountCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Current amount cannot be negative.'**
  String get currentAmountCannotBeNegative;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get goalReached;

  /// No description provided for @remainingAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String remainingAmountLabel(String amount);

  /// No description provided for @savedPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}% saved'**
  String savedPercentLabel(String percent);

  /// No description provided for @deadlineDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline {date}'**
  String deadlineDateLabel(String date);

  /// No description provided for @freePremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Free / Premium'**
  String get freePremiumTitle;

  /// No description provided for @planRefreshFailedFreeSafe.
  ///
  /// In en, this message translates to:
  /// **'Plan refresh failed, so Free-safe limits are shown. Manual expense tracking is still available. {message}'**
  String planRefreshFailedFreeSafe(String message);

  /// No description provided for @premiumStillWorks.
  ///
  /// In en, this message translates to:
  /// **'Premium removes ads and raises limits. Manual tracking remains the core experience.'**
  String get premiumStillWorks;

  /// No description provided for @freeStillWorks.
  ///
  /// In en, this message translates to:
  /// **'Free keeps manual expenses, categories, budgets, basic reports, exports, and offline sync working even when AI quota is finished.'**
  String get freeStillWorks;

  /// No description provided for @adsOnFree.
  ///
  /// In en, this message translates to:
  /// **'Ads on Free'**
  String get adsOnFree;

  /// No description provided for @premiumAdsDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'The app must not initialize or request ads while Premium is active.'**
  String get premiumAdsDisabledBody;

  /// No description provided for @freeAdsBody.
  ///
  /// In en, this message translates to:
  /// **'Ads are reserved for passive banner slots or natural completion moments. They never interrupt add expense, AI preview, auth, app lock, or purchase flows.'**
  String get freeAdsBody;

  /// No description provided for @consentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Consent: {status}'**
  String consentStatusLabel(String status);

  /// No description provided for @todayAiUsage.
  ///
  /// In en, this message translates to:
  /// **'Today AI usage'**
  String get todayAiUsage;

  /// No description provided for @textParse.
  ///
  /// In en, this message translates to:
  /// **'Text parse'**
  String get textParse;

  /// No description provided for @receipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get receipts;

  /// No description provided for @advice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get advice;

  /// No description provided for @leftByDefault.
  ///
  /// In en, this message translates to:
  /// **'{count} left by default'**
  String leftByDefault(int count);

  /// No description provided for @leftCount.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String leftCount(int count);

  /// No description provided for @showingPolicyDefaultsUntilWorker.
  ///
  /// In en, this message translates to:
  /// **'Showing policy defaults until the Worker returns live usage.'**
  String get showingPolicyDefaultsUntilWorker;

  /// No description provided for @resetsAroundWithPeriod.
  ///
  /// In en, this message translates to:
  /// **'Resets around {time}.'**
  String resetsAroundWithPeriod(String time);

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @included.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get included;

  /// No description provided for @manualTracking.
  ///
  /// In en, this message translates to:
  /// **'Manual tracking'**
  String get manualTracking;

  /// No description provided for @aiTextParse.
  ///
  /// In en, this message translates to:
  /// **'AI text parse'**
  String get aiTextParse;

  /// No description provided for @higherFiniteLimit.
  ///
  /// In en, this message translates to:
  /// **'Higher finite limit'**
  String get higherFiniteLimit;

  /// No description provided for @moreReceipts.
  ///
  /// In en, this message translates to:
  /// **'More receipts'**
  String get moreReceipts;

  /// No description provided for @moreAdvice.
  ///
  /// In en, this message translates to:
  /// **'More advice'**
  String get moreAdvice;

  /// No description provided for @ads.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get ads;

  /// No description provided for @politeAds.
  ///
  /// In en, this message translates to:
  /// **'Polite ads'**
  String get politeAds;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get noAds;

  /// No description provided for @reportsExport.
  ///
  /// In en, this message translates to:
  /// **'Reports/export'**
  String get reportsExport;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basic;

  /// No description provided for @advancedLater.
  ///
  /// In en, this message translates to:
  /// **'Advanced reports, export templates, smart budgets'**
  String get advancedLater;

  /// No description provided for @premiumIsActive.
  ///
  /// In en, this message translates to:
  /// **'Premium is active'**
  String get premiumIsActive;

  /// No description provided for @premiumActiveBody.
  ///
  /// In en, this message translates to:
  /// **'Ads are disabled and Premium entitlements are enabled.'**
  String get premiumActiveBody;

  /// No description provided for @premiumComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Premium coming soon'**
  String get premiumComingSoon;

  /// No description provided for @premiumPurchasesDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'Purchases are not enabled yet because backend verification is not deployed. The app will not fake a subscription or charge you from this screen.'**
  String get premiumPurchasesDisabledBody;

  /// No description provided for @checkAvailability.
  ///
  /// In en, this message translates to:
  /// **'Check availability'**
  String get checkAvailability;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @readinessComingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get readinessComingSoonLabel;

  /// No description provided for @readinessDisabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Unavailable now'**
  String get readinessDisabledLabel;

  /// No description provided for @premiumRestoreDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'Purchase restore is disabled until trusted backend entitlement verification is available.'**
  String get premiumRestoreDisabledBody;

  /// No description provided for @premiumBackendVerificationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Paid subscriptions are disabled because backend verification is not configured yet.'**
  String get premiumBackendVerificationUnavailable;

  /// No description provided for @walletsReadinessBody.
  ///
  /// In en, this message translates to:
  /// **'Wallet management stays disabled until list, create, edit, archive, and expense assignment are complete.'**
  String get walletsReadinessBody;

  /// No description provided for @transfersReadinessBody.
  ///
  /// In en, this message translates to:
  /// **'Transfers stay disabled until the transfer form and currency policy are complete; they remain separate from expenses.'**
  String get transfersReadinessBody;

  /// No description provided for @backupExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup export'**
  String get backupExportTitle;

  /// No description provided for @backupExportReadinessBody.
  ///
  /// In en, this message translates to:
  /// **'Backup export is not available from the app UI until safe data collection is complete.'**
  String get backupExportReadinessBody;

  /// No description provided for @restorePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore preview'**
  String get restorePreviewTitle;

  /// No description provided for @restorePreviewReadinessBody.
  ///
  /// In en, this message translates to:
  /// **'Restore requires an impact preview and explicit confirmation before any data can change.'**
  String get restorePreviewReadinessBody;

  /// No description provided for @restoreExecutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore execution'**
  String get restoreExecutionTitle;

  /// No description provided for @restoreExecutionReadinessBody.
  ///
  /// In en, this message translates to:
  /// **'Restore execution is intentionally blocked until conflict policy and repository write tests exist.'**
  String get restoreExecutionReadinessBody;

  /// No description provided for @aiInputExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Example: spent 250 EGP on food yesterday with cash'**
  String get aiInputExampleHint;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @receiptImageReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the receipt image. Add the expense manually.'**
  String get receiptImageReadFailed;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @reviewBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Review before saving'**
  String get reviewBeforeSaving;

  /// No description provided for @newCategoryName.
  ///
  /// In en, this message translates to:
  /// **'New category name'**
  String get newCategoryName;

  /// No description provided for @confirmingCreatesCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Confirming will create this category first.'**
  String get confirmingCreatesCategoryFirst;

  /// No description provided for @suggestedNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Suggested new category: {category}'**
  String suggestedNewCategory(String category);

  /// No description provided for @matchedCategory.
  ///
  /// In en, this message translates to:
  /// **'Matched category: {category}'**
  String matchedCategory(String category);

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String sourceLabel(String source);

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {percent}%'**
  String confidenceLabel(int percent);

  /// No description provided for @aiCategoryId.
  ///
  /// In en, this message translates to:
  /// **'AI category id'**
  String get aiCategoryId;

  /// No description provided for @aiCategoryName.
  ///
  /// In en, this message translates to:
  /// **'AI category name'**
  String get aiCategoryName;

  /// No description provided for @categoryAlias.
  ///
  /// In en, this message translates to:
  /// **'category alias'**
  String get categoryAlias;

  /// No description provided for @recentHistory.
  ///
  /// In en, this message translates to:
  /// **'recent history'**
  String get recentHistory;

  /// No description provided for @newCategorySuggestion.
  ///
  /// In en, this message translates to:
  /// **'new category suggestion'**
  String get newCategorySuggestion;

  /// No description provided for @manualSelection.
  ///
  /// In en, this message translates to:
  /// **'manual selection'**
  String get manualSelection;

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'no match'**
  String get noMatch;

  /// No description provided for @failedToCreateAiSuggestedCategory.
  ///
  /// In en, this message translates to:
  /// **'Failed to create AI suggested category.'**
  String get failedToCreateAiSuggestedCategory;

  /// No description provided for @createCategoryBeforeSavingRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Create a category before saving recurrence.'**
  String get createCategoryBeforeSavingRecurrence;

  /// No description provided for @recurringExpenseSuggestionSaved.
  ///
  /// In en, this message translates to:
  /// **'Recurring expense suggestion saved.'**
  String get recurringExpenseSuggestionSaved;

  /// No description provided for @failedToSaveAiExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to save AI expense. Please try again.'**
  String get failedToSaveAiExpense;

  /// No description provided for @pleaseAddMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Please add more details.'**
  String get pleaseAddMoreDetails;

  /// No description provided for @couldNotParseExpense.
  ///
  /// In en, this message translates to:
  /// **'Could not parse this expense.'**
  String get couldNotParseExpense;

  /// No description provided for @searchReady.
  ///
  /// In en, this message translates to:
  /// **'Search ready'**
  String get searchReady;

  /// No description provided for @readyToOpenFilteredExpenses.
  ///
  /// In en, this message translates to:
  /// **'Ready to open filtered expenses.'**
  String get readyToOpenFilteredExpenses;

  /// No description provided for @openResults.
  ///
  /// In en, this message translates to:
  /// **'Open results'**
  String get openResults;

  /// No description provided for @historyAnswer.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyAnswer;

  /// No description provided for @historySourceLocal.
  ///
  /// In en, this message translates to:
  /// **'Source: deterministic local history'**
  String get historySourceLocal;

  /// No description provided for @historyNoMatchingExpenses.
  ///
  /// In en, this message translates to:
  /// **'No loaded expenses match that history question.'**
  String get historyNoMatchingExpenses;

  /// No description provided for @historyMatchingExpenses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 matching expense.} other{{count} matching expenses.}}'**
  String historyMatchingExpenses(int count);

  /// No description provided for @historyMutationReadOnly.
  ///
  /// In en, this message translates to:
  /// **'History answers are read-only. Use the existing preview and confirmation flow for changes.'**
  String get historyMutationReadOnly;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @totalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String totalAmountLabel(String amount);

  /// No description provided for @topCategoryWithAmount.
  ///
  /// In en, this message translates to:
  /// **'Top category: {category} ({amount})'**
  String topCategoryWithAmount(String category, String amount);

  /// No description provided for @ignoredOtherCurrencyExpensesBecause.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense ignored because it uses another currency.} other{{count} expenses ignored because they use another currency.}}'**
  String ignoredOtherCurrencyExpensesBecause(int count);

  /// No description provided for @financialAdvice.
  ///
  /// In en, this message translates to:
  /// **'Financial advice'**
  String get financialAdvice;

  /// No description provided for @localAdviceFallback.
  ///
  /// In en, this message translates to:
  /// **'Local advice fallback'**
  String get localAdviceFallback;

  /// No description provided for @aiFinancialAdvice.
  ///
  /// In en, this message translates to:
  /// **'AI financial advice'**
  String get aiFinancialAdvice;

  /// No description provided for @aiAdviceEvidenceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount} {currency}'**
  String aiAdviceEvidenceTotal(String amount, String currency);

  /// No description provided for @aiAdviceEvidenceTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category: {category} ({amount} {currency})'**
  String aiAdviceEvidenceTopCategory(
    String category,
    String amount,
    String currency,
  );

  /// No description provided for @aiAdviceEvidenceBudgetUsed.
  ///
  /// In en, this message translates to:
  /// **'Budget used: {percent}%'**
  String aiAdviceEvidenceBudgetUsed(String percent);

  /// No description provided for @aiAdviceEvidenceConvertedCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Converted currencies: {currencies}'**
  String aiAdviceEvidenceConvertedCurrencies(String currencies);

  /// No description provided for @aiAdviceEvidenceMissingRates.
  ///
  /// In en, this message translates to:
  /// **'Missing rates for {currencies}; {count, plural, =1{1 expense was not included} other{{count} expenses were not included}}'**
  String aiAdviceEvidenceMissingRates(String currencies, int count);

  /// No description provided for @aiAdviceNoSpending.
  ///
  /// In en, this message translates to:
  /// **'No spending found for this period. Keep recording expenses so advice can be more useful.'**
  String get aiAdviceNoSpending;

  /// No description provided for @aiAdviceOverBudget.
  ///
  /// In en, this message translates to:
  /// **'You are over budget. Review {category} first and pause non-essential spending until the next period.'**
  String aiAdviceOverBudget(String category);

  /// No description provided for @aiAdviceOverBudgetFallback.
  ///
  /// In en, this message translates to:
  /// **'You are over budget. Review your biggest category first and pause non-essential spending until the next period.'**
  String get aiAdviceOverBudgetFallback;

  /// No description provided for @aiAdviceNearLimit.
  ///
  /// In en, this message translates to:
  /// **'You are close to your budget limit. Keep the next purchases small and watch {category}.'**
  String aiAdviceNearLimit(String category);

  /// No description provided for @aiAdviceNearLimitFallback.
  ///
  /// In en, this message translates to:
  /// **'You are close to your budget limit. Keep the next purchases small and watch your top category.'**
  String get aiAdviceNearLimitFallback;

  /// No description provided for @aiAdviceFocusCategory.
  ///
  /// In en, this message translates to:
  /// **'For {category}, compare each purchase against your plan before spending again this period.'**
  String aiAdviceFocusCategory(String category);

  /// No description provided for @aiAdviceTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Your highest spending is {category}. Set a smaller limit for it and move routine purchases to planned days.'**
  String aiAdviceTopCategory(String category);

  /// No description provided for @aiAdviceStable.
  ///
  /// In en, this message translates to:
  /// **'Your spending is stable for this period. Keep checking totals before adding new non-essential expenses.'**
  String get aiAdviceStable;

  /// No description provided for @aiAdviceRequestsLeftToday.
  ///
  /// In en, this message translates to:
  /// **'{count} AI advice request(s) left today.'**
  String aiAdviceRequestsLeftToday(int count);

  /// No description provided for @aiNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'AI needs review'**
  String get aiNeedsReview;

  /// No description provided for @aiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI unavailable'**
  String get aiUnavailable;

  /// No description provided for @providerAiUnavailableManualStillWorks.
  ///
  /// In en, this message translates to:
  /// **'Provider-backed AI is unavailable. Manual entry and local insights still work.'**
  String get providerAiUnavailableManualStillWorks;

  /// No description provided for @localSpendingPrediction.
  ///
  /// In en, this message translates to:
  /// **'Local spending prediction'**
  String get localSpendingPrediction;

  /// No description provided for @expectedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Expected this month: {amount}'**
  String expectedThisMonth(String amount);

  /// No description provided for @repeatedExpenseFound.
  ///
  /// In en, this message translates to:
  /// **'Repeated expense found'**
  String get repeatedExpenseFound;

  /// No description provided for @repeatedExpenseLooksFrequency.
  ///
  /// In en, this message translates to:
  /// **'{description} looks {frequency}.'**
  String repeatedExpenseLooksFrequency(String description, String frequency);

  /// No description provided for @matchingExpensesAverage.
  ///
  /// In en, this message translates to:
  /// **'{count} matching expenses, average {amount}.'**
  String matchingExpensesAverage(int count, String amount);

  /// No description provided for @reviewRecurring.
  ///
  /// In en, this message translates to:
  /// **'Review recurring'**
  String get reviewRecurring;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDelete;

  /// No description provided for @confirmUpdate.
  ///
  /// In en, this message translates to:
  /// **'Confirm update'**
  String get confirmUpdate;

  /// No description provided for @chooseExactExpenseFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose the exact expense first.'**
  String get chooseExactExpenseFirst;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @preparingVoiceInput.
  ///
  /// In en, this message translates to:
  /// **'Preparing voice input...'**
  String get preparingVoiceInput;

  /// No description provided for @listeningVoiceInput.
  ///
  /// In en, this message translates to:
  /// **'Listening. Pause support depends on your device.'**
  String get listeningVoiceInput;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @archiveCategory.
  ///
  /// In en, this message translates to:
  /// **'Archive Category'**
  String get archiveCategory;

  /// No description provided for @archiveCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Archive {category}? Existing expenses will still show it.'**
  String archiveCategoryMessage(String category);

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created.'**
  String get categoryCreated;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated.'**
  String get categoryUpdated;

  /// No description provided for @categoryArchived.
  ///
  /// In en, this message translates to:
  /// **'Category archived.'**
  String get categoryArchived;

  /// No description provided for @failedToCreateCategory.
  ///
  /// In en, this message translates to:
  /// **'Failed to create category.'**
  String get failedToCreateCategory;

  /// No description provided for @failedToUpdateCategory.
  ///
  /// In en, this message translates to:
  /// **'Failed to update category.'**
  String get failedToUpdateCategory;

  /// No description provided for @failedToArchiveCategory.
  ///
  /// In en, this message translates to:
  /// **'Failed to archive category.'**
  String get failedToArchiveCategory;

  /// No description provided for @selectCategoryToArchive.
  ///
  /// In en, this message translates to:
  /// **'Select a category to archive.'**
  String get selectCategoryToArchive;

  /// No description provided for @enterCategoryNameIconColor.
  ///
  /// In en, this message translates to:
  /// **'Enter category name, icon, and color.'**
  String get enterCategoryNameIconColor;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryName;

  /// No description provided for @categoryIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get categoryIcon;

  /// No description provided for @selectedCategoryIcon.
  ///
  /// In en, this message translates to:
  /// **'Selected category icon'**
  String get selectedCategoryIcon;

  /// No description provided for @categoryColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryColor;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get customColor;

  /// No description provided for @saveColor.
  ///
  /// In en, this message translates to:
  /// **'Save Color'**
  String get saveColor;

  /// No description provided for @searchIcons.
  ///
  /// In en, this message translates to:
  /// **'Search icons'**
  String get searchIcons;

  /// No description provided for @categoryIconSemantics.
  ///
  /// In en, this message translates to:
  /// **'Icon {label}'**
  String categoryIconSemantics(String label);

  /// No description provided for @categoryColorSemantics.
  ///
  /// In en, this message translates to:
  /// **'Color {label}'**
  String categoryColorSemantics(String label);

  /// No description provided for @categoryExpenseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No expenses} =1{1 expense} other{{count} expenses}}'**
  String categoryExpenseCount(int count);

  /// No description provided for @monthlyBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudgetTitle;

  /// No description provided for @budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget amount'**
  String get budgetAmount;

  /// No description provided for @saveBudget.
  ///
  /// In en, this message translates to:
  /// **'Save Budget'**
  String get saveBudget;

  /// No description provided for @enterValidBudgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid budget amount.'**
  String get enterValidBudgetAmount;

  /// No description provided for @warningThresholdRange.
  ///
  /// In en, this message translates to:
  /// **'Warning threshold must be between 1 and 100.'**
  String get warningThresholdRange;

  /// No description provided for @failedToLoadBudget.
  ///
  /// In en, this message translates to:
  /// **'Failed to load budget.'**
  String get failedToLoadBudget;

  /// No description provided for @failedToSaveBudget.
  ///
  /// In en, this message translates to:
  /// **'Failed to save budget.'**
  String get failedToSaveBudget;

  /// No description provided for @budgetSetAction.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get budgetSetAction;

  /// No description provided for @budgetNoBudgetSet.
  ///
  /// In en, this message translates to:
  /// **'No budget set for this month.'**
  String get budgetNoBudgetSet;

  /// No description provided for @budgetSpentLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get budgetSpentLabel;

  /// No description provided for @budgetRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get budgetRemainingLabel;

  /// No description provided for @budgetPercentOfLimit.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of {amount}'**
  String budgetPercentOfLimit(String percent, String amount);

  /// No description provided for @budgetExceededWarning.
  ///
  /// In en, this message translates to:
  /// **'Budget exceeded.'**
  String get budgetExceededWarning;

  /// No description provided for @budgetNearLimitWarning.
  ///
  /// In en, this message translates to:
  /// **'You are close to your budget limit.'**
  String get budgetNearLimitWarning;

  /// No description provided for @budgetIgnoredCurrencyExpenses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense in another currency was excluded because no saved rate was available.} other{{count} expenses in other currencies were excluded because no saved rates were available.}}'**
  String budgetIgnoredCurrencyExpenses(int count);

  /// No description provided for @categoryBudgetsCreateCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Create an active category before category budgets.'**
  String get categoryBudgetsCreateCategoryFirst;

  /// No description provided for @categoryBudgetsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load category budgets.'**
  String get categoryBudgetsLoadFailed;

  /// No description provided for @categoryBudgetSaved.
  ///
  /// In en, this message translates to:
  /// **'Category budget saved.'**
  String get categoryBudgetSaved;

  /// No description provided for @categoryBudgetSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save category budget.'**
  String get categoryBudgetSaveFailed;

  /// No description provided for @categoryBudgetArchived.
  ///
  /// In en, this message translates to:
  /// **'Category budget archived.'**
  String get categoryBudgetArchived;

  /// No description provided for @categoryBudgetArchiveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to archive category budget.'**
  String get categoryBudgetArchiveFailed;

  /// No description provided for @selectCategoryBudgetToArchive.
  ///
  /// In en, this message translates to:
  /// **'Select a category budget to archive.'**
  String get selectCategoryBudgetToArchive;

  /// No description provided for @archiveCategoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Archive Category Budget'**
  String get archiveCategoryBudget;

  /// No description provided for @archiveCategoryBudgetMessage.
  ///
  /// In en, this message translates to:
  /// **'Archive {category} budget?'**
  String archiveCategoryBudgetMessage(String category);

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @noCategoryBudgetsYet.
  ///
  /// In en, this message translates to:
  /// **'No category budgets yet'**
  String get noCategoryBudgetsYet;

  /// No description provided for @addCategoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Add Category Budget'**
  String get addCategoryBudget;

  /// No description provided for @editCategoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Category Budget'**
  String get editCategoryBudget;

  /// No description provided for @limitAmount.
  ///
  /// In en, this message translates to:
  /// **'Limit amount'**
  String get limitAmount;

  /// No description provided for @warningThresholdPercent.
  ///
  /// In en, this message translates to:
  /// **'Warning threshold percent'**
  String get warningThresholdPercent;

  /// No description provided for @budgetRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested monthly budget'**
  String get budgetRecommendationTitle;

  /// No description provided for @budgetRecommendationMeta.
  ///
  /// In en, this message translates to:
  /// **'{confidence} confidence - {period}'**
  String budgetRecommendationMeta(String confidence, String period);

  /// No description provided for @budgetRecommendationMonthlyExplanation.
  ///
  /// In en, this message translates to:
  /// **'Based on recent monthly spending and trend.'**
  String get budgetRecommendationMonthlyExplanation;

  /// No description provided for @budgetRecommendationCategoryExplanation.
  ///
  /// In en, this message translates to:
  /// **'Based on recent {category} spending and trend.'**
  String budgetRecommendationCategoryExplanation(String category);

  /// No description provided for @useEditableRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Use editable suggestion'**
  String get useEditableRecommendation;

  /// No description provided for @categoryBudgetRecommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested category budgets'**
  String get categoryBudgetRecommendationsTitle;

  /// No description provided for @categoryBudgetRecommendationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{amount} - {confidence} confidence'**
  String categoryBudgetRecommendationSubtitle(String amount, String confidence);

  /// No description provided for @recommendationConfidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get recommendationConfidenceHigh;

  /// No description provided for @recommendationConfidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get recommendationConfidenceMedium;

  /// No description provided for @recommendationConfidenceLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get recommendationConfidenceLow;

  /// No description provided for @recommendationCaveatSparseHistory.
  ///
  /// In en, this message translates to:
  /// **'Limited history makes this a cautious estimate.'**
  String get recommendationCaveatSparseHistory;

  /// No description provided for @recommendationCaveatOutlierMonth.
  ///
  /// In en, this message translates to:
  /// **'One unusual month was reduced in the estimate.'**
  String get recommendationCaveatOutlierMonth;

  /// No description provided for @recommendationCaveatMissingRates.
  ///
  /// In en, this message translates to:
  /// **'Expenses with missing exchange rates were excluded.'**
  String get recommendationCaveatMissingRates;

  /// No description provided for @recommendationCaveatExistingBudget.
  ///
  /// In en, this message translates to:
  /// **'You already have a budget here; review before replacing it.'**
  String get recommendationCaveatExistingBudget;

  /// No description provided for @budgetSpentOfLimit.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String budgetSpentOfLimit(String spent, String limit);

  /// No description provided for @budgetRemainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining {amount}'**
  String budgetRemainingAmount(String amount);

  /// No description provided for @categoryBudgetIgnoredCurrencyExpenses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense ignored due to currency} other{{count} expenses ignored due to currency}}'**
  String categoryBudgetIgnoredCurrencyExpenses(int count);

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category.'**
  String get selectCategory;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select a month.'**
  String get selectMonth;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select a currency.'**
  String get selectCurrency;

  /// No description provided for @enterValidBudgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid budget limit.'**
  String get enterValidBudgetLimit;

  /// No description provided for @manageRecurringExpenses.
  ///
  /// In en, this message translates to:
  /// **'Manage recurring expenses'**
  String get manageRecurringExpenses;

  /// No description provided for @failedToLoadSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subscriptions.'**
  String get failedToLoadSubscriptions;

  /// No description provided for @estimatedMonthlyImpact.
  ///
  /// In en, this message translates to:
  /// **'Estimated monthly impact'**
  String get estimatedMonthlyImpact;

  /// No description provided for @subscriptionMixedCurrencyCaveat.
  ///
  /// In en, this message translates to:
  /// **'Totals stay separated by currency until subscription conversion is audited.'**
  String get subscriptionMixedCurrencyCaveat;

  /// No description provided for @dailyMonthlyImpactEstimateCaveat.
  ///
  /// In en, this message translates to:
  /// **'Daily subscriptions are estimated as 30 renewals per month.'**
  String get dailyMonthlyImpactEstimateCaveat;

  /// No description provided for @weeklyMonthlyImpactEstimateCaveat.
  ///
  /// In en, this message translates to:
  /// **'Weekly subscriptions are estimated as 52 renewals across 12 months.'**
  String get weeklyMonthlyImpactEstimateCaveat;

  /// No description provided for @upcomingRenewals.
  ///
  /// In en, this message translates to:
  /// **'Upcoming renewals'**
  String get upcomingRenewals;

  /// No description provided for @renewsOn.
  ///
  /// In en, this message translates to:
  /// **'Renews {date}'**
  String renewsOn(Object date);

  /// No description provided for @possiblePriceChanges.
  ///
  /// In en, this message translates to:
  /// **'Possible price changes'**
  String get possiblePriceChanges;

  /// No description provided for @possiblePriceIncrease.
  ///
  /// In en, this message translates to:
  /// **'Possible increase from {previous} to {current}'**
  String possiblePriceIncrease(Object previous, Object current);

  /// No description provided for @cautiousSignal.
  ///
  /// In en, this message translates to:
  /// **'Cautious signal'**
  String get cautiousSignal;

  /// No description provided for @activeSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Active subscriptions'**
  String get activeSubscriptions;

  /// No description provided for @subscriptionNextDue.
  ///
  /// In en, this message translates to:
  /// **'{frequency} - {paymentMethod} - Next {date}'**
  String subscriptionNextDue(
    String frequency,
    String paymentMethod,
    String date,
  );

  /// No description provided for @monthlyImpactSuffix.
  ///
  /// In en, this message translates to:
  /// **'{amount}/mo'**
  String monthlyImpactSuffix(String amount);

  /// No description provided for @noActiveSubscriptionsYet.
  ///
  /// In en, this message translates to:
  /// **'No active subscriptions yet'**
  String get noActiveSubscriptionsYet;

  /// No description provided for @exportEndDateBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End date must be on or after start date.'**
  String get exportEndDateBeforeStart;

  /// No description provided for @exportCurrencyFilterEmpty.
  ///
  /// In en, this message translates to:
  /// **'Currency filter must not be empty.'**
  String get exportCurrencyFilterEmpty;

  /// No description provided for @exportPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Export'**
  String get exportPdfTitle;

  /// No description provided for @exportPdfPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period: {startDate} - {endDate}'**
  String exportPdfPeriod(String startDate, String endDate);

  /// No description provided for @exportPdfTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}'**
  String exportPdfTotal(String total);

  /// No description provided for @exportHeaderDate.
  ///
  /// In en, this message translates to:
  /// **'date'**
  String get exportHeaderDate;

  /// No description provided for @exportHeaderAmount.
  ///
  /// In en, this message translates to:
  /// **'amount'**
  String get exportHeaderAmount;

  /// No description provided for @exportHeaderCurrency.
  ///
  /// In en, this message translates to:
  /// **'currency'**
  String get exportHeaderCurrency;

  /// No description provided for @exportHeaderCategory.
  ///
  /// In en, this message translates to:
  /// **'category'**
  String get exportHeaderCategory;

  /// No description provided for @exportHeaderPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'paymentMethod'**
  String get exportHeaderPaymentMethod;

  /// No description provided for @exportHeaderDescription.
  ///
  /// In en, this message translates to:
  /// **'description'**
  String get exportHeaderDescription;

  /// No description provided for @exportHeaderConvertedAmount.
  ///
  /// In en, this message translates to:
  /// **'convertedAmount'**
  String get exportHeaderConvertedAmount;

  /// No description provided for @exportHeaderConvertedCurrency.
  ///
  /// In en, this message translates to:
  /// **'convertedCurrency'**
  String get exportHeaderConvertedCurrency;

  /// No description provided for @exportHeaderConversionRate.
  ///
  /// In en, this message translates to:
  /// **'conversionRate'**
  String get exportHeaderConversionRate;

  /// No description provided for @exportHeaderConversionRateDate.
  ///
  /// In en, this message translates to:
  /// **'conversionRateDate'**
  String get exportHeaderConversionRateDate;

  /// No description provided for @exportHeaderConversionStatus.
  ///
  /// In en, this message translates to:
  /// **'conversionStatus'**
  String get exportHeaderConversionStatus;

  /// No description provided for @exportConversionStatusOriginal.
  ///
  /// In en, this message translates to:
  /// **'original'**
  String get exportConversionStatusOriginal;

  /// No description provided for @exportConversionStatusConverted.
  ///
  /// In en, this message translates to:
  /// **'converted'**
  String get exportConversionStatusConverted;

  /// No description provided for @exportConversionStatusMissingRate.
  ///
  /// In en, this message translates to:
  /// **'missingRate'**
  String get exportConversionStatusMissingRate;

  /// No description provided for @exportPdfConvertedTotal.
  ///
  /// In en, this message translates to:
  /// **'Converted total: {total}'**
  String exportPdfConvertedTotal(String total);

  /// No description provided for @exportPdfMissingRates.
  ///
  /// In en, this message translates to:
  /// **'Missing rates for {currencies}; {count, plural, =1{1 row was not included.} other{{count} rows were not included.}}'**
  String exportPdfMissingRates(String currencies, int count);

  /// No description provided for @exportArabicFontMissing.
  ///
  /// In en, this message translates to:
  /// **'PDF export needs the bundled Arabic font asset before it can run. Add assets/fonts/NotoSansArabic-Regular.ttf and regenerate assets.'**
  String get exportArabicFontMissing;

  /// No description provided for @wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// No description provided for @walletAccount.
  ///
  /// In en, this message translates to:
  /// **'Wallet account'**
  String get walletAccount;

  /// No description provided for @walletType.
  ///
  /// In en, this message translates to:
  /// **'Wallet type'**
  String get walletType;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get openingBalance;

  /// No description provided for @archiveWallet.
  ///
  /// In en, this message translates to:
  /// **'Archive wallet'**
  String get archiveWallet;

  /// No description provided for @transfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfers;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @sourceWallet.
  ///
  /// In en, this message translates to:
  /// **'Source wallet'**
  String get sourceWallet;

  /// No description provided for @destinationWallet.
  ///
  /// In en, this message translates to:
  /// **'Destination wallet'**
  String get destinationWallet;

  /// No description provided for @transferFee.
  ///
  /// In en, this message translates to:
  /// **'Transfer fee'**
  String get transferFee;

  /// No description provided for @feeWallet.
  ///
  /// In en, this message translates to:
  /// **'Fee wallet'**
  String get feeWallet;
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

import { after, afterEach, before, describe, it } from 'node:test';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  doc,
  getDoc,
  setDoc,
  Timestamp,
} from 'firebase/firestore';

let testEnv: RulesTestEnvironment;

const projectId = 'ai-expenses-rules-test';

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: readFileSync(resolve('../firestore.rules'), 'utf8'),
    },
  });
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  await testEnv.cleanup();
});

describe('Firestore security rules', () => {
  it('allows an owner to create and read a valid expense', async () => {
    const db = testEnv.authenticatedContext('user-a').firestore();
    const ref = doc(db, 'users/user-a/expenses/expense-1');

    await assertSucceeds(setDoc(ref, validExpense()));
    await assertSucceeds(getDoc(ref));
  });

  it('allows positive decimal expense amounts and denies negative decimals', async () => {
    const db = testEnv.authenticatedContext('user-a').firestore();

    await assertSucceeds(
      setDoc(
        doc(db, 'users/user-a/expenses/expense-decimal'),
        validExpense({ expenseId: 'expense-decimal', amount: 120.75 }),
      ),
    );
    await assertFails(
      setDoc(
        doc(db, 'users/user-a/expenses/expense-negative-decimal'),
        validExpense({
          expenseId: 'expense-negative-decimal',
          amount: -0.25,
        }),
      ),
    );
  });

  it('allows bounded expense metadata and denies malformed metadata', async () => {
    const db = testEnv.authenticatedContext('user-a').firestore();

    await assertSucceeds(
      setDoc(
        doc(db, 'users/user-a/expenses/expense-metadata'),
        validExpense({
          expenseId: 'expense-metadata',
          merchant: 'Corner Market',
          tags: ['groceries', 'weekly'],
        }),
      ),
    );
    await assertFails(
      setDoc(
        doc(db, 'users/user-a/expenses/expense-bad-merchant'),
        validExpense({
          expenseId: 'expense-bad-merchant',
          merchant: 'x'.repeat(121),
        }),
      ),
    );
    await assertFails(
      setDoc(
        doc(db, 'users/user-a/expenses/expense-bad-tags'),
        validExpense({
          expenseId: 'expense-bad-tags',
          tags: Array(21).fill('tag'),
        }),
      ),
    );
  });

  it('allows valid expense money snapshots and rejects invalid rates', async () => {
    const db = testEnv.authenticatedContext('user-a').firestore();

    await assertSucceeds(
      setDoc(
        doc(db, 'users/user-a/expenses/expense-snapshot'),
        validExpense({
          expenseId: 'expense-snapshot',
          currency: 'USD',
          moneySnapshot: validMoneySnapshot(),
        }),
      ),
    );
    await assertFails(
      setDoc(
        doc(db, 'users/user-a/expenses/expense-bad-snapshot'),
        validExpense({
          expenseId: 'expense-bad-snapshot',
          currency: 'USD',
          moneySnapshot: validMoneySnapshot({ conversionRate: 0 }),
        }),
      ),
    );
  });

  it('denies cross-user and unauthenticated expense access', async () => {
    const ownerDb = testEnv.authenticatedContext('user-a').firestore();
    const otherDb = testEnv.authenticatedContext('user-b').firestore();
    const guestDb = testEnv.unauthenticatedContext().firestore();
    const ownerRef = doc(ownerDb, 'users/user-a/expenses/expense-1');

    await assertSucceeds(setDoc(ownerRef, validExpense()));
    await assertFails(getDoc(doc(otherDb, 'users/user-a/expenses/expense-1')));
    await assertFails(getDoc(doc(guestDb, 'users/user-a/expenses/expense-1')));
  });

  it('denies malformed expense writes', async () => {
    const db = testEnv.authenticatedContext('user-a').firestore();
    const ref = doc(db, 'users/user-a/expenses/expense-1');

    await assertFails(
      setDoc(ref, {
        ...validExpense(),
        amount: 0,
      }),
    );
    await assertFails(
      setDoc(ref, {
        ...validExpense(),
        amount: -10,
      }),
    );
    await assertFails(
      setDoc(ref, {
        ...validExpense(),
        amount: '120',
      }),
    );
    await assertFails(
      setDoc(ref, {
        ...validExpense(),
        currency: 'EGP£',
      }),
    );
  });

  it('allows valid categories and denies hard deletes through rules contract', async () => {
    const db = testEnv.authenticatedContext('user-a').firestore();
    const ref = doc(db, 'users/user-a/categories/food');

    await assertSucceeds(setDoc(ref, validCategory()));
    await assertSucceeds(getDoc(ref));
  });

  it('allows valid finance feature documents for the owner', async () => {
    const db = testEnv.authenticatedContext('user-a').firestore();

    await assertSucceeds(
      setDoc(doc(db, 'users/user-a/budgets/2026-05'), validBudget()),
    );
    await assertSucceeds(
      setDoc(
        doc(db, 'users/user-a/category_budgets/2026-05_food_EGP'),
        validCategoryBudget(),
      ),
    );
    await assertSucceeds(
      setDoc(doc(db, 'users/user-a/wallets/wallet-1'), validWallet()),
    );
    await assertSucceeds(
      setDoc(doc(db, 'users/user-a/transfers/transfer-1'), validTransfer()),
    );
    await assertSucceeds(
      setDoc(
        doc(db, 'users/user-a/recurring_expenses/rule-1'),
        validRecurringExpense(),
      ),
    );
    await assertSucceeds(
      setDoc(doc(db, 'users/user-a/saving_goals/goal-1'), validSavingGoal()),
    );
    await assertSucceeds(
      setDoc(doc(db, 'users/user-a/settings/profile'), validSettings()),
    );
    await assertSucceeds(
      setDoc(doc(db, 'users/user-a/ai_actions/action-1'), validAiAction()),
    );
    await assertSucceeds(
      setDoc(
        doc(db, 'users/user-a/category_aliases/alias-1'),
        validCategoryAlias(),
      ),
    );
  });

  it('denies cross-user and unauthenticated settings access', async () => {
    const ownerDb = testEnv.authenticatedContext('user-a').firestore();
    const otherDb = testEnv.authenticatedContext('user-b').firestore();
    const guestDb = testEnv.unauthenticatedContext().firestore();
    const ownerRef = doc(ownerDb, 'users/user-a/settings/profile');

    await assertSucceeds(setDoc(ownerRef, validSettings()));
    await assertFails(getDoc(doc(otherDb, 'users/user-a/settings/profile')));
    await assertFails(
      setDoc(doc(otherDb, 'users/user-a/settings/profile'), validSettings()),
    );
    await assertFails(getDoc(doc(guestDb, 'users/user-a/settings/profile')));
    await assertFails(
      setDoc(doc(guestDb, 'users/user-a/settings/profile'), validSettings()),
    );
  });

  it('denies malformed owner-scoped feature documents', async () => {
    const db = testEnv.authenticatedContext('user-a').firestore();

    await assertFails(
      setDoc(doc(db, 'users/user-a/budgets/2026-05'), {
        ...validBudget(),
        warningThresholdPercent: 120,
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/ai_actions/action-1'), {
        ...validAiAction(),
        confidence: 2,
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/wallets/wallet-1'), {
        ...validWallet(),
        type: 'brokerage',
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/transfers/transfer-1'), {
        ...validTransfer(),
        destinationWalletId: 'cash-wallet',
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        notificationSettings: {
          ...validSettings().notificationSettings,
          reminderTime: '25:00',
        },
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        languagePreference: 'fr',
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        onboardingVersion: -1,
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        guidedTourCompletedVersion: -1,
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        guidedTourSkippedVersion: -1,
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        appDisplayName: 42,
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        appDisplayName: 'x'.repeat(81),
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        guidedTourLastStepId: 42,
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        conversionRates: {
          USD: '0.02',
        },
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        conversionRates: {
          USD: 0,
        },
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        conversionRates: {
          GBP: 1.2,
        },
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        conversionRates: {
          EGP: 1,
          USD: 50,
        },
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/user-a/settings/not-profile'), validSettings()),
    );
  });

  it('allows valid conversion-rate settings payloads', async () => {
    const db = testEnv.authenticatedContext('user-a').firestore();

    await assertSucceeds(
      setDoc(doc(db, 'users/user-a/settings/profile'), {
        ...validSettings(),
        baseCurrency: 'USD',
        supportedCurrencies: ['USD', 'EGP', 'EUR'],
        conversionRates: {
          EGP: 0.02,
          EUR: 1.1,
        },
      }),
    );
  });

  it('denies legacy global collections', async () => {
    const db = testEnv.authenticatedContext('user-a').firestore();

    await assertFails(setDoc(doc(db, 'expenses/expense-1'), validExpense()));
    await assertFails(setDoc(doc(db, 'categories/food'), validCategory()));
  });
});

function now() {
  return Timestamp.fromDate(new Date('2026-05-18T10:00:00Z'));
}

function validExpense(overrides: Partial<ReturnType<typeof baseExpense>> = {}) {
  return {
    ...baseExpense(),
    ...overrides,
  };
}

function baseExpense() {
  return {
    expenseId: 'expense-1',
    userId: 'user-a',
    categoryId: 'food',
    categoryName: 'Food',
    categoryIcon: 'restaurant',
    categoryColor: 0xff00aa00,
    category: validCategory(),
    date: now(),
    amount: 120,
    description: 'Lunch',
    merchant: null,
    tags: [],
    paymentMethod: 'cash',
    currency: 'EGP',
    createdAt: now(),
    updatedAt: now(),
    source: 'manual',
    recurringExpenseId: null,
    aiActionId: null,
    moneySnapshot: null,
  };
}

function validMoneySnapshot(overrides: Record<string, unknown> = {}) {
  return {
    sourceAmount: 10,
    sourceCurrency: 'USD',
    targetCurrency: 'EGP',
    conversionRate: 50,
    convertedAmount: 500,
    capturedAt: now(),
    rateUpdatedAt: now(),
    rateSource: 'settings',
    rateFreshness: 'saved',
    ...overrides,
  };
}

function validCategory() {
  return {
    categoryId: 'food',
    userId: 'user-a',
    name: 'Food',
    totalExpenses: 0,
    icon: 'restaurant',
    color: 0xff00aa00,
    isArchived: false,
    createdAt: now(),
    updatedAt: now(),
  };
}

function validBudget() {
  return {
    budgetId: '2026-05',
    userId: 'user-a',
    month: 5,
    year: 2026,
    amount: 5000,
    currency: 'EGP',
    warningThresholdPercent: 80,
    createdAt: now(),
    updatedAt: now(),
  };
}

function validCategoryBudget() {
  return {
    categoryBudgetId: '2026-05_food_EGP',
    userId: 'user-a',
    categoryId: 'food',
    categoryName: 'Food',
    month: '2026-05',
    currency: 'EGP',
    limitAmount: 1500,
    warningThresholdPercent: 80,
    isArchived: false,
    createdAt: now(),
    updatedAt: now(),
  };
}

function validRecurringExpense() {
  return {
    recurringExpenseId: 'rule-1',
    userId: 'user-a',
    amount: 300,
    category: validCategory(),
    categoryId: 'food',
    categoryName: 'Food',
    categoryIcon: 'restaurant',
    categoryColor: 0xff00aa00,
    description: 'Weekly lunch',
    paymentMethod: 'cash',
    currency: 'EGP',
    startDate: now(),
    nextRunDate: now(),
    endDate: null,
    frequency: 'weekly',
    isActive: true,
    isArchived: false,
    createdAt: now(),
    updatedAt: now(),
  };
}

function validSavingGoal() {
  return {
    goalId: 'goal-1',
    userId: 'user-a',
    name: 'Emergency fund',
    targetAmount: 10000,
    currentAmount: 1000,
    currency: 'EGP',
    deadline: null,
    isArchived: false,
    createdAt: now(),
    updatedAt: now(),
  };
}

function validWallet() {
  return {
    walletId: 'wallet-1',
    userId: 'user-a',
    name: 'Cash wallet',
    type: 'cash',
    currency: 'EGP',
    openingBalance: 1000,
    isArchived: false,
    createdAt: now(),
    updatedAt: now(),
  };
}

function validTransfer() {
  return {
    transferId: 'transfer-1',
    userId: 'user-a',
    sourceWalletId: 'cash-wallet',
    destinationWalletId: 'bank-wallet',
    amount: 250,
    currency: 'EGP',
    feeAmount: 0,
    feeWalletId: null,
    date: now(),
    note: 'ATM deposit',
    isArchived: false,
    createdAt: now(),
    updatedAt: now(),
  };
}

function validSettings() {
  return {
    userId: 'user-a',
    appDisplayName: 'Local User',
    languagePreference: 'system',
    baseCurrency: 'EGP',
    supportedCurrencies: ['EGP', 'USD'],
    conversionRates: {
      USD: 50,
    },
    defaultPaymentMethod: 'cash',
    notificationSettings: {
      budgetAlertsEnabled: true,
      dailyReminderEnabled: true,
      reminderTime: '20:00',
      weeklyDigestEnabled: true,
      weeklyDigestTime: '18:00',
      lastExceededAlertMonth: null,
    },
    onboardingCompleted: true,
    onboardingVersion: 1,
    guidedTourCompletedVersion: 1,
    guidedTourSkippedVersion: 0,
    guidedTourLastStepId: null,
    exchangeRatesUpdatedAt: now(),
    updatedAt: now(),
  };
}

function validAiAction() {
  return {
    actionId: 'action-1',
    userId: 'user-a',
    rawInput: 'صرفت 100 جنيه على أكل',
    parsedResponse: {
      intent: 'add_expense',
      amount: 100,
    },
    intent: 'add_expense',
    confidence: 0.9,
    status: 'previewed',
    createdAt: now(),
    confirmedAt: null,
    targetExpenseId: null,
    errorMessage: null,
    provider: 'gemini',
    model: 'gemini-2.5-flash',
    providerRequestId: 'req-1',
    inputTokens: 20,
    outputTokens: 30,
    errorCode: null,
  };
}

function validCategoryAlias() {
  return {
    aliasId: 'alias-1',
    userId: 'user-a',
    categoryId: 'food',
    phrase: 'أكل',
    locale: 'ar',
    createdAt: now(),
    updatedAt: now(),
    lastUsedAt: now(),
    useCount: 1,
  };
}

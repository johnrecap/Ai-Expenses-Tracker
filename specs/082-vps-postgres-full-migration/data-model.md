# Data Model: VPS PostgreSQL Full Migration

## Global Sync Columns

All synced app-owned tables should include:

- `id`: stable UUID or preserved legacy string id where compatibility requires it.
- `user_id`: backend user owner id.
- `created_at`: server-visible creation timestamp.
- `updated_at`: latest effective update timestamp.
- `deleted_at`: nullable tombstone timestamp.
- `server_revision`: monotonically increasing server revision.
- `client_updated_at`: last client-side update timestamp when provided.
- `origin_device_id`: nullable device id that produced the latest change.
- `legacy_firestore_path`: nullable migration audit reference during cutover.

## users

Represents an app account mapped to Firebase Auth.

- `id`
- `firebase_uid` unique
- `email`
- `provider_summary`
- `app_display_name`
- `created_at`
- `updated_at`
- `deleted_at`

Relationships:

- Has many devices and all finance records.

Validation:

- `firebase_uid` is required and unique.
- User data access always scopes by authenticated Firebase uid mapped to this row.

## devices

Represents an installed app instance participating in sync.

- `id`
- `user_id`
- `device_label`
- `platform`
- `app_version`
- `last_seen_at`
- `last_pull_cursor`

Validation:

- Device belongs to one user.
- Device id is generated locally and registered with backend after auth.

## user_settings

Stores app-local settings currently held under Firestore settings profile.

- `user_id`
- `app_display_name`
- `language_preference`
- `base_currency`
- `supported_currencies`
- `conversion_rates`
- `exchange_rates_updated_at`
- `default_payment_method`
- `notification_settings`
- `onboarding_completed`
- `onboarding_version`
- `guided_tour_completed_version`
- `guided_tour_skipped_version`
- `guided_tour_last_step_id`
- sync columns

Validation:

- Base currency must be included in supported currencies.
- Conversion rates must be positive finite numbers.
- Language preference is `system`, `en`, or `ar`.

## categories

User-owned category metadata.

- `id`
- `user_id`
- `name`
- `icon`
- `color`
- `is_archived`
- sync columns

Relationships:

- Expenses store category id plus historical snapshot fields.
- Category aliases can point to active categories.

## category_aliases

Learned AI aliases and curated mapping support.

- `id`
- `user_id`
- `alias`
- `category_id`
- `locale`
- sync columns

Validation:

- Alias lookup ignores archived category targets.

## expenses

User-owned finance transaction.

- `id`
- `user_id`
- `category_id`
- `category_name`
- `category_icon`
- `category_color`
- `category_snapshot`
- `date`
- `amount`
- `amount_minor`
- `currency`
- `base_currency_at_entry`
- `conversion_rate_to_base`
- `conversion_rate_date`
- `description`
- `merchant`
- `tags`
- `payment_method`
- `source`
- `wallet_account_id`
- `wallet_account_name`
- `recurring_expense_id`
- `ai_action_id`
- sync columns

Validation:

- Amount must be positive.
- Currency must be a supported ISO-style code used by the app.
- Transfers are not expenses; transfer rows must not be counted as spending.

## budgets

Monthly total budget.

- `id`
- `user_id`
- `month`
- `amount`
- `currency`
- sync columns

Validation:

- One active budget per user/month/currency policy.

## category_budgets

Monthly category budget.

- `id`
- `user_id`
- `month`
- `category_id`
- `amount`
- `currency`
- `is_archived`
- sync columns

Validation:

- Category budget calculations must not silently sum unsupported currencies.

## recurring_expenses

Client-side recurrence rule source.

- `id`
- `user_id`
- `category_id`
- `amount`
- `currency`
- `description`
- `payment_method`
- `frequency`
- `start_date`
- `next_due_date`
- `is_paused`
- `is_archived`
- sync columns

Validation:

- Generated expenses preserve `recurring_expense_id`.

## saving_goals

User-owned target savings.

- `id`
- `user_id`
- `name`
- `target_amount`
- `current_amount`
- `currency`
- `deadline`
- `is_archived`
- sync columns

Validation:

- Current amount cannot be negative.

## wallet_accounts

Manual wallet/account metadata.

- `id`
- `user_id`
- `name`
- `currency`
- `opening_balance`
- `is_archived`
- sync columns

Validation:

- Wallet balances across currencies require explicit conversion policy before combined display.

## transfers

Movement between wallet accounts, separate from spending.

- `id`
- `user_id`
- `from_wallet_id`
- `to_wallet_id`
- `amount`
- `currency`
- `date`
- `note`
- sync columns

Validation:

- Transfers must be excluded from expense totals unless a future plan defines fee behavior.

## ai_action_logs

Audit log for AI actions.

- `id`
- `user_id`
- `status`
- `intent`
- `provider`
- `model`
- `provider_request_id`
- `input_tokens`
- `output_tokens`
- `error_code`
- `created_at`
- sync columns

Validation:

- Must not store provider secrets, raw authorization headers, or unredacted sensitive prompts beyond current app policy.

## exchange_rates

Daily and historical rate metadata.

- `id`
- `base_currency`
- `target_currency`
- `rate`
- `rate_date`
- `provider`
- `fetched_at`

Validation:

- One current provider rate per base/target/date.
- Expense snapshots should use transaction-date or entry-date rate metadata when available.

## sync_changes

Optional server-side audit of changes for pull cursors.

- `id`
- `user_id`
- `entity_type`
- `entity_id`
- `operation`
- `server_revision`
- `changed_at`
- `changed_by_device_id`

Validation:

- Pull requests only return changes for the authenticated user.

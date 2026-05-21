# Feature Specification: Incomplete Feature Surface Readiness

**Feature Branch**: `079-incomplete-feature-surface-readiness`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: Review found several foundations exist without complete user-facing flows: Premium backend, Wallets/Transfers UI, and Backup/Restore execution.

## User Scenarios & Testing

### User Story 1 - Users do not see unfinished features as complete (Priority: P1)

As a user, I want features that are not ready to be clearly hidden, disabled, or marked as not yet available, so I do not trust an incomplete flow with important financial data.

**Why this priority**: An incomplete premium, wallet, or restore feature can damage trust more than not showing it at all.

**Independent Test**: Navigate Settings/Home/menus as Free and Premium-like states; no incomplete action can start a destructive or paid flow.

### User Story 2 - Wallets and transfers become a coherent first slice (Priority: P2)

As a user, I want wallet and transfer screens only when I can create/view wallets, assign expenses, and record transfers consistently.

**Why this priority**: Wallet data exists in the domain layer, but without UI it is not a complete product feature.

**Independent Test**: User can open Wallets, create/edit/archive a wallet, choose wallet on Add/Edit Expense, and create a transfer that does not count as spending.

### User Story 3 - Backup restore remains safe until fully confirmed (Priority: P2)

As a user, I want backup export and restore to show exactly what will happen before data is changed, so restore cannot silently overwrite or duplicate financial records.

**Why this priority**: Restore is a high-risk data operation.

**Independent Test**: Restore preview shows adds/updates/conflicts/skips, requires explicit confirmation, and does not write until confirmed.

### User Story 4 - Premium is honest until backend verification exists (Priority: P2)

As a user, I want premium screens to clearly say whether purchases are available, verified, or not configured, so I am not asked to pay for an unverified entitlement.

**Why this priority**: Premium without backend verification risks fake unlocks and user confusion.

**Independent Test**: Purchase CTA stays disabled or sandbox-only unless trusted backend verification is configured.

## Requirements

- **FR-001**: Any incomplete feature entry point MUST be hidden, disabled, or labelled as unavailable with a safe explanation.
- **FR-002**: Restore execution MUST remain unavailable until preview, conflict policy, confirmation, and repository write tests exist.
- **FR-003**: Wallet/Transfer UI MUST not appear as complete unless wallet list, add/edit/archive, expense wallet selector, transfer form, and report exclusion are implemented.
- **FR-004**: Premium paid unlock MUST not be offered as real production purchase until backend verification and restore entitlement flow are implemented.
- **FR-005**: Feature gates MUST keep core manual expense tracking free and usable.
- **FR-006**: All disabled/unavailable explanations MUST be localized.
- **FR-007**: High-risk actions like restore and account/payment operations MUST require explicit confirmation.

## Key Entities

- **FeatureSurface**: A visible entry point, settings row, route, button, or card.
- **ReadinessState**: Available, disabled, coming soon, sandbox only, or hidden.
- **HighRiskAction**: Restore, purchase, transfer, or destructive data operation.

## Success Criteria

- **SC-001**: No visible incomplete feature can perform a destructive or paid operation.
- **SC-002**: Wallet/Transfer UI acceptance path passes before the feature is presented as available.
- **SC-003**: Restore cannot write data without passing preview and confirmation tests.
- **SC-004**: Premium purchase UI clearly blocks real purchase without backend verification.

## Assumptions

- Foundations from plans 074, 075, and 076 are retained.
- This plan can either hide incomplete features or complete a minimal slice, depending on task priority.


import 'package:expenses_tracker/guided_tour/models/guided_tour_step.dart';

const guidedTourVersion = 1;

class GuidedTourTargetIds {
  static const aiAssistant = 'guided_tour.ai_assistant';
  static const manualExpense = 'guided_tour.manual_expense';
  static const budget = 'guided_tour.budget';
  static const reports = 'guided_tour.reports';
  static const categories = 'guided_tour.categories';
  static const settings = 'guided_tour.settings';
}

class GuidedTourStepIds {
  static const aiAssistant = 'ai_assistant';
  static const manualExpense = 'manual_expense';
  static const aiPreview = 'ai_preview';
  static const budget = 'budget';
  static const reports = 'reports';
  static const categories = 'categories';
  static const settings = 'settings';
  static const freePremium = 'free_premium';
}

final guidedTourSteps = List<GuidedTourStep>.unmodifiable([
  GuidedTourStep(
    stepId: GuidedTourStepIds.aiAssistant,
    targetId: GuidedTourTargetIds.aiAssistant,
    titleBuilder: (l10n) => l10n.guidedTourAiTitle,
    bodyBuilder: (l10n) => l10n.guidedTourAiBody,
    placement: GuidedTourPlacement.below,
    canSkipIfMissing: false,
  ),
  GuidedTourStep(
    stepId: GuidedTourStepIds.manualExpense,
    targetId: GuidedTourTargetIds.manualExpense,
    titleBuilder: (l10n) => l10n.guidedTourManualExpenseTitle,
    bodyBuilder: (l10n) => l10n.guidedTourManualExpenseBody,
    placement: GuidedTourPlacement.above,
    canSkipIfMissing: false,
  ),
  GuidedTourStep(
    stepId: GuidedTourStepIds.aiPreview,
    targetId: GuidedTourTargetIds.aiAssistant,
    titleBuilder: (l10n) => l10n.guidedTourAiPreviewTitle,
    bodyBuilder: (l10n) => l10n.guidedTourAiPreviewBody,
    placement: GuidedTourPlacement.below,
    canSkipIfMissing: false,
  ),
  GuidedTourStep(
    stepId: GuidedTourStepIds.budget,
    targetId: GuidedTourTargetIds.budget,
    titleBuilder: (l10n) => l10n.guidedTourBudgetTitle,
    bodyBuilder: (l10n) => l10n.guidedTourBudgetBody,
    canSkipIfMissing: true,
  ),
  GuidedTourStep(
    stepId: GuidedTourStepIds.reports,
    targetId: GuidedTourTargetIds.reports,
    titleBuilder: (l10n) => l10n.guidedTourReportsTitle,
    bodyBuilder: (l10n) => l10n.guidedTourReportsBody,
    placement: GuidedTourPlacement.above,
    canSkipIfMissing: true,
  ),
  GuidedTourStep(
    stepId: GuidedTourStepIds.categories,
    targetId: GuidedTourTargetIds.categories,
    titleBuilder: (l10n) => l10n.guidedTourCategoriesTitle,
    bodyBuilder: (l10n) => l10n.guidedTourCategoriesBody,
    placement: GuidedTourPlacement.below,
    canSkipIfMissing: true,
  ),
  GuidedTourStep(
    stepId: GuidedTourStepIds.settings,
    targetId: GuidedTourTargetIds.settings,
    titleBuilder: (l10n) => l10n.guidedTourSettingsTitle,
    bodyBuilder: (l10n) => l10n.guidedTourSettingsBody,
    placement: GuidedTourPlacement.below,
    canSkipIfMissing: true,
  ),
  GuidedTourStep(
    stepId: GuidedTourStepIds.freePremium,
    targetId: GuidedTourTargetIds.settings,
    titleBuilder: (l10n) => l10n.guidedTourFreePremiumTitle,
    bodyBuilder: (l10n) => l10n.guidedTourFreePremiumBody,
    placement: GuidedTourPlacement.below,
    canSkipIfMissing: true,
  ),
]);

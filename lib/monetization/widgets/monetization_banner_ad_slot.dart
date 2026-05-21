import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/monetization_cubit.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'adaptive_banner_ad_slot.dart';

class MonetizationBannerAdSlot extends StatelessWidget {
  const MonetizationBannerAdSlot({
    required this.placementKey,
    this.reservedHeight = 56,
    super.key,
  });

  final AdPlacementKey placementKey;
  final double reservedHeight;

  @override
  Widget build(BuildContext context) {
    final cubit = _readOrNull<MonetizationCubit>(context);
    final adService = _readOrNull<AdService>(context);
    if (cubit == null || adService == null) return const SizedBox.shrink();

    return BlocBuilder<MonetizationCubit, MonetizationState>(
      bloc: cubit,
      buildWhen: (previous, current) =>
          previous.entitlement != current.entitlement ||
          previous.consent != current.consent ||
          previous.policy != current.policy,
      builder: (context, state) {
        final enabled = cubit.shouldReserveBanner(placementKey);
        return AdaptiveBannerAdSlot(
          placementKey: placementKey,
          enabled: enabled,
          adService: adService,
          reservedHeight: reservedHeight,
        );
      },
    );
  }

  T? _readOrNull<T>(BuildContext context) {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }
}

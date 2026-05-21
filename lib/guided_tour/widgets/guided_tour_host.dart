import 'package:expenses_tracker/guided_tour/cubit/guided_tour_cubit.dart';
import 'package:expenses_tracker/guided_tour/models/guided_tour_state.dart';
import 'package:expenses_tracker/guided_tour/widgets/tour_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GuidedTourHost extends StatelessWidget {
  const GuidedTourHost({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cubit = _readCubit(context);
    if (cubit == null) return child;

    return BlocBuilder<GuidedTourCubit, GuidedTourState>(
      builder: (context, state) {
        return PopScope<void>(
          canPop: !state.isActive,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || !state.isActive) return;
            await cubit.handleBackButton();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              child,
              if (state.isActive)
                TourOverlay(
                  state: state,
                  onNext: cubit.next,
                  onBack: cubit.back,
                  onSkip: cubit.skip,
                  onDone: cubit.complete,
                ),
            ],
          ),
        );
      },
    );
  }

  GuidedTourCubit? _readCubit(BuildContext context) {
    try {
      return context.read<GuidedTourCubit>();
    } catch (_) {
      return null;
    }
  }
}

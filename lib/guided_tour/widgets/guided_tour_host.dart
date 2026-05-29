import 'package:expenses_tracker/guided_tour/cubit/guided_tour_cubit.dart';
import 'package:expenses_tracker/guided_tour/models/guided_tour_state.dart';
import 'package:expenses_tracker/guided_tour/widgets/tour_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GuidedTourHost extends StatefulWidget {
  const GuidedTourHost({required this.child, super.key});

  final Widget child;

  @override
  State<GuidedTourHost> createState() => _GuidedTourHostState();
}

class _GuidedTourHostState extends State<GuidedTourHost>
    with WidgetsBindingObserver {
  GuidedTourCubit? _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = _readCubit(context);
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit?.refreshActiveTarget();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit ?? _readCubit(context);
    if (cubit == null) return widget.child;

    return BlocBuilder<GuidedTourCubit, GuidedTourState>(
      builder: (context, state) {
        if (state.isActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _cubit?.refreshActiveTarget();
          });
        }
        return PopScope<void>(
          canPop: !state.isActive,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || !state.isActive) return;
            await cubit.handleBackButton();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
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

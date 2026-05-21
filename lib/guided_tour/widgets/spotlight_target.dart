import 'package:expenses_tracker/guided_tour/cubit/guided_tour_cubit.dart';
import 'package:expenses_tracker/guided_tour/models/guided_tour_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpotlightTarget extends StatefulWidget {
  const SpotlightTarget({
    required this.targetId,
    required this.child,
    this.shape = SpotlightShape.roundedRectangle,
    this.padding = const EdgeInsets.all(8),
    super.key,
  });

  final String targetId;
  final Widget child;
  final SpotlightShape shape;
  final EdgeInsets padding;

  @override
  State<SpotlightTarget> createState() => _SpotlightTargetState();
}

class _SpotlightTargetState extends State<SpotlightTarget> {
  final _targetKey = GlobalKey();
  GuidedTourCubit? _cubit;
  bool _registrationScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = _readCubit();
    _scheduleRegistration();
  }

  @override
  void didUpdateWidget(covariant SpotlightTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetId != widget.targetId) {
      _cubit?.unregisterTarget(oldWidget.targetId, _targetKey);
    }
    _scheduleRegistration();
  }

  @override
  void dispose() {
    _cubit?.unregisterTarget(widget.targetId, _targetKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _targetKey,
      child: widget.child,
    );
  }

  GuidedTourCubit? _readCubit() {
    try {
      return context.read<GuidedTourCubit>();
    } catch (_) {
      return null;
    }
  }

  void _scheduleRegistration() {
    final cubit = _cubit;
    if (cubit == null) return;
    if (_registrationScheduled) return;
    _registrationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registrationScheduled = false;
      if (!mounted) return;
      cubit.registerTarget(
        targetId: widget.targetId,
        key: _targetKey,
        shape: widget.shape,
        padding: widget.padding,
      );
    });
  }
}

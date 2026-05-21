import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';

class AdaptiveBannerAdSlot extends StatefulWidget {
  const AdaptiveBannerAdSlot({
    required this.placementKey,
    required this.enabled,
    required this.adService,
    this.reservedHeight = 56,
    super.key,
  });

  final AdPlacementKey placementKey;
  final bool enabled;
  final AdService adService;
  final double reservedHeight;

  @override
  State<AdaptiveBannerAdSlot> createState() => _AdaptiveBannerAdSlotState();
}

class _AdaptiveBannerAdSlotState extends State<AdaptiveBannerAdSlot> {
  BannerAdHandle? _handle;
  bool _failed = false;
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _load();
    }
  }

  @override
  void didUpdateWidget(covariant AdaptiveBannerAdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.placementKey != widget.placementKey) {
      _disposeHandle();
      _failed = false;
      _load();
    }
  }

  @override
  void dispose() {
    _disposeHandle();
    super.dispose();
  }

  Future<void> _load() async {
    if (!widget.enabled) return;
    if (!widget.adService.isInitialized) {
      await widget.adService.initialize();
    }
    if (!mounted) return;
    final width = MediaQuery.sizeOf(context).width;
    final handle = await widget.adService.loadBanner(
      placementKey: widget.placementKey,
      width: width,
    );
    if (!mounted) return;
    setState(() {
      _handle = handle;
      _failed = handle == null;
    });
  }

  Future<void> _disposeHandle() async {
    final handle = _handle;
    if (handle != null) {
      await widget.adService.disposeBanner(handle);
    }
    _handle = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();

    return SizedBox(
      key: ValueKey<String>('adaptive_banner_slot_${widget.placementKey.name}'),
      height: widget.reservedHeight,
      width: double.infinity,
      child: AnimatedOpacity(
        opacity: _handle == null || _failed ? 0 : 1,
        duration: const Duration(milliseconds: 180),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Center(
            child: _handle?.child ??
                Text(
                  _handle?.debugLabel ?? '',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
          ),
        ),
      ),
    );
  }
}

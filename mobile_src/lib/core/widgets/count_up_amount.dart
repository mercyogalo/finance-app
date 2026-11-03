import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/money.dart';

class CountUpAmount extends StatefulWidget {
  const CountUpAmount({required this.amountMinor, this.style, super.key});

  final int amountMinor;
  final TextStyle? style;

  @override
  State<CountUpAmount> createState() => _CountUpAmountState();
}

class _CountUpAmountState extends State<CountUpAmount> {
  late int _shown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animateTo(widget.amountMinor);
  }

  @override
  void didUpdateWidget(CountUpAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amountMinor != widget.amountMinor) {
      _animateTo(widget.amountMinor);
    }
  }

  void _animateTo(int target) {
    _timer?.cancel();
    const steps = 24;
    const stepDuration = Duration(milliseconds: 25);
    final start = _shown;
    var step = 0;
    _timer = Timer.periodic(stepDuration, (timer) {
      step += 1;
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _shown = start + (((target - start) * step) ~/ steps);
      });
      if (step >= steps) {
        timer.cancel();
        setState(() => _shown = target);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatKes(_shown),
      style: widget.style ??
          Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

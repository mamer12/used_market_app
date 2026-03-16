import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FlashCountdownTimer extends StatefulWidget {
  final DateTime endsAt;
  final VoidCallback? onExpired;

  const FlashCountdownTimer({
    super.key,
    required this.endsAt,
    this.onExpired,
  });

  @override
  State<FlashCountdownTimer> createState() => _FlashCountdownTimerState();
}

class _FlashCountdownTimerState extends State<FlashCountdownTimer>
    with SingleTickerProviderStateMixin {
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  bool _pulseVisible = true;
  Timer? _pulseTicker;

  @override
  void initState() {
    super.initState();
    _update();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseTicker?.cancel();
    super.dispose();
  }

  void _update() {
    final remaining = widget.endsAt.difference(DateTime.now());
    if (!mounted) return;

    if (remaining.isNegative || remaining == Duration.zero) {
      setState(() => _remaining = Duration.zero);
      _ticker?.cancel();
      _pulseTicker?.cancel();
      widget.onExpired?.call();
      return;
    }

    setState(() => _remaining = remaining);

    // Start pulse when <= 300 seconds
    if (remaining.inSeconds <= 300 && _pulseTicker == null) {
      _pulseTicker = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) {
          if (mounted) setState(() => _pulseVisible = !_pulseVisible);
        },
      );
    } else if (remaining.inSeconds > 300 && _pulseTicker != null) {
      _pulseTicker?.cancel();
      _pulseTicker = null;
      _pulseVisible = true;
    }
  }

  Color _textColor() {
    final secs = _remaining.inSeconds;
    if (secs <= 600) return const Color(0xFFFF3D5A);
    if (secs <= 1800) return const Color(0xFFEA580C);
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final secs = _remaining.inSeconds;
    final isPulsing = secs <= 300 && secs > 0;

    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    final label = '$hours:$minutes:$seconds';

    final textWidget = Text(
      label,
      style: GoogleFonts.cairo(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: _textColor(),
      ),
    );

    if (isPulsing) {
      return AnimatedOpacity(
        opacity: _pulseVisible ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 500),
        child: textWidget,
      );
    }

    return textWidget;
  }
}

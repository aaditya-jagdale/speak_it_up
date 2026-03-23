import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speak_it_up/shared/services/settings_service.dart';
import 'package:speak_it_up/shared/widgets/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Default timer duration (seconds)
// ─────────────────────────────────────────────────────────────────────────────
int _kDefaultSeconds = 60;

class TimerScreen extends StatefulWidget {
  final String topic;
  const TimerScreen({super.key, required this.topic});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  // ── Timer state ─────────────────────────────────────────────────────────────
  int _totalSeconds = _kDefaultSeconds;
  int _remainingSeconds = _kDefaultSeconds;
  bool _isRunning = false;
  Timer? _countdownTimer;

  // ── Ring animation controller ────────────────────────────────────────────────
  late final AnimationController _ringController;

  // ── "New Topic" spin animation controller ───────────────────────────────────
  late final AnimationController _spinController;
  late final Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();
    _kDefaultSeconds = SettingsService.instance.timerDuration;
    _ringController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _kDefaultSeconds),
    )..value = 1.0; // starts full

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _spinAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeInOut),
    );
    _resetTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _ringController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String get _formattedTime {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _ringProgress =>
      _totalSeconds == 0 ? 0 : _remainingSeconds / _totalSeconds;

  void _startTimer() {
    if (_isRunning) return;
    if (_remainingSeconds == 0) {
      _resetTimer();
      _startTimer();
      return;
    }
    if (SettingsService.instance.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    setState(() => _isRunning = true);

    // Animate ring from current progress to 0 over remaining time
    _ringController.duration = Duration(seconds: _remainingSeconds);
    _ringController.animateTo(
      0.0,
      duration: Duration(seconds: _remainingSeconds),
      curve: Curves.linear,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isRunning = false;
          t.cancel();
          if (SettingsService.instance.vibrationEnabled) {
            HapticFeedback.heavyImpact();
          }
        }
      });
    });
  }

  void _stopTimer() {
    if (SettingsService.instance.vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    _countdownTimer?.cancel();
    _ringController.stop();
    if (!mounted) return;
    setState(() => _isRunning = false);
  }

  void _adjustTime(int deltaSeconds) {
    if (SettingsService.instance.vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    _countdownTimer?.cancel();
    _ringController.stop();
    setState(() {
      _isRunning = false;
      _remainingSeconds = (_remainingSeconds + deltaSeconds).clamp(
        0,
        5999,
      ); // max 99:59
      _totalSeconds = _remainingSeconds;
      _ringController.value = 1.0;
    });
  }

  void _resetTimer() {
    if (SettingsService.instance.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    _countdownTimer?.cancel();
    _ringController.stop();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _kDefaultSeconds;
      _totalSeconds = _kDefaultSeconds;
      _ringController.value = 1.0;
    });
  }

  void _goNewTopic() {
    if (SettingsService.instance.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    _spinController.forward(from: 0).then((_) {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // ── Back arrow ────────────────────────────────────────────────────
              _buildBackRow(),
              const SizedBox(height: 32),

              // ── Topic display ─────────────────────────────────────────────────
              _buildTopicDisplay(),
              const SizedBox(height: 48),

              // ── Circular timer ────────────────────────────────────────────────
              Expanded(child: _buildCircularTimer()),
              const SizedBox(height: 32),

              // ── Adjust row (+/-30s) ───────────────────────────────────────────
              if (!_isRunning) _buildAdjustRow(),
              const SizedBox(height: 16),

              // ── Main Start / Stop button ──────────────────────────────────────
              _buildMainButton(),
              const SizedBox(height: 12),

              // ── Secondary row (Reset + New Topic) ────────────────────────────
              _buildSecondaryRow(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Section builders
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildBackRow() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (SettingsService.instance.vibrationEnabled) {
            HapticFeedback.lightImpact();
          }
          Navigator.of(context).pop();
        },
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF090909),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicDisplay() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey(widget.topic),
        children: [
          const Text(
            'Your topic',
            style: TextStyle(
              fontFamily: 'geist',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.black50,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.topic,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'shrikhand',
              fontSize: 28,
              height: 1.1,
              color: Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularTimer() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedBuilder(
          animation: _ringController,
          builder: (context, _) {
            final progress = _isRunning ? _ringController.value : _ringProgress;
            return CustomPaint(
              painter: _RingPainter(progress: progress),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 120),
                  child: Text(
                    _formattedTime,
                    key: ValueKey(_remainingSeconds),
                    style: const TextStyle(
                      fontFamily: 'shrikhand',
                      fontSize: 54,
                      height: 1.0,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdjustRow() {
    return Row(
      children: [
        Expanded(
          child: _AdjustButton(label: '−30s', onTap: () => _adjustTime(-30)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AdjustButton(label: '+30s', onTap: () => _adjustTime(30)),
        ),
      ],
    );
  }

  Widget _buildMainButton() {
    return GestureDetector(
      onTap: _isRunning ? _stopTimer : _startTimer,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          color: _isRunning ? AppColors.danger : AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            child: Text(
              _isRunning ? 'Stop' : 'Start',
              key: ValueKey(_isRunning),
              style: const TextStyle(
                fontFamily: 'geist',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryRow() {
    return Row(
      children: [
        // Reset button
        Expanded(
          child: GestureDetector(
            onTap: _resetTimer,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    // Reset {default time} min/sec
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black75,
                    ),
                  ),
                  Text(
                    // Reset {default time} min/sec
                    '(${SettingsService.instance.timerDuration / 60} min)',
                    style: TextStyle(
                      fontFamily: 'geist',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black75,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // New Topic button
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _goNewTopic,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _spinAnimation,
                      builder: (context, child) => Transform.rotate(
                        angle: _spinAnimation.value,
                        child: child,
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'New Topic',
                      style: TextStyle(
                        fontFamily: 'geist',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AdjustButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary5,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'geist',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ring painter — draws the countdown arc
// ─────────────────────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 10;
    const strokeWidth = 10.0;

    // Track (background ring)
    final trackPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

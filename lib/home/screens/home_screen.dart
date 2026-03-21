import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:speak_it_up/home/screens/timer_screen.dart';
import 'package:speak_it_up/shared/widgets/colors.dart';
import 'package:speak_it_up/shared/widgets/transitions.dart';

/// List of topics shown in the slot machine
const List<String> _topics = [
  'Celebrating too early',
  'Defending yourself',
  'Just be yourself',
  'Overcoming fear',
  'Daily gratitude',
  'Body language',
  'Power of silence',
  'Active listening',
  'Storytelling tips',
  'Eye contact skills',
  'Handling criticism',
  'Public speaking',
  'Confidence hacks',
  'Humor in speech',
  'Persuasion tactics',
  'Building rapport',
  'Vocal tone tips',
  'Nervousness cures',
  'Impromptu speaking',
  'Debate strategies',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── slot machine state ──────────────────────────────────────────────
  int _currentIndex = 0;
  bool _isSpinning = false;
  late final AnimationController _reelController;
  late final Animation<double> _reelAnim;

  static const double _itemHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _reelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _reelAnim = Tween<double>(begin: 0, end: -_itemHeight).animate(
      CurvedAnimation(parent: _reelController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _reelController.dispose();
    super.dispose();
  }

  // ── helpers ─────────────────────────────────────────────────────────
  String _topic(int offset) =>
      _topics[(_currentIndex + offset + _topics.length * 10) % _topics.length];

  // ── Per-tick hook ─────────────────────────────────────────────────────
  // Called once for every slot tick during a spin.
  // [tick]  : 0-based index of the current tick
  // [total] : total number of ticks in this spin
  // Add more effects here freely — haptics, visuals, counters, etc.
  Future<void> _onSpinTick(int tick, int total) async {
    HapticFeedback.lightImpact();
  }

  Future<void> _spin() async {
    if (_isSpinning) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSpinning = true);

    // ── Spin speed ──────────────────────────────────────────────────────
    // Increase _spinSpeedScale to slow down, decrease to speed up.
    // 1.0 = base speed, 2.0 = twice as slow, 0.5 = twice as fast.
    const double _spinSpeedScale = 2.5;

    // Accelerate then decelerate
    const int totalTicks = 10;
    for (int i = 0; i < totalTicks; i++) {
      // Speed curve: slow start → fast middle → slow end
      final int baseDelayMs = i < 3
          ? (180 - i * 30).clamp(80, 180)
          : i > 6
          ? (80 + (i - 6) * 60).clamp(80, 300)
          : 80;
      final int delayMs = (baseDelayMs * _spinSpeedScale).round();

      // ── Fire all per-tick effects ──────────────────────────────
      unawaited(_onSpinTick(i, totalTicks));

      _reelController.reset();
      _reelController.duration = Duration(milliseconds: delayMs);
      await _reelController.forward();

      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _topics.length;
      });
      _reelController.reset();
    }

    HapticFeedback.lightImpact();
    if (!mounted) return;
    setState(() => _isSpinning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                // TODO: open settings
              },
              child: SvgPicture.asset(
                'assets/icons/settings.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF090909),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Title ──────────────────────────────────────────────
                    _buildTitle(),
                    const SizedBox(height: 32),

                    // ── 3-step cards ───────────────────────────────────────
                    _buildStepCards(),
                    const SizedBox(height: 60),

                    // ── Slot machine ───────────────────────────────────────
                    _buildSlotMachine(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // ── Bottom action buttons ─────────────────────────────
              _buildActionButtons(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Widgets
  // ────────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Text(
          'Speak',
          style: TextStyle(
            fontFamily: 'shrikhand',
            fontSize: 62,
            height: 1.05,
            color: const Color(0xFF212121),
          ),
        ),
        Text(
          'it up',
          style: TextStyle(
            fontFamily: 'shrikhand',
            fontSize: 62,
            height: 1.05,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCards() {
    final steps = [
      ('01', 'Get a topic'),
      ('02', 'Set a timer'),
      ('03', 'Speak'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final isLast = entry.key == steps.length - 1;
          final step = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 8),
              child: _StepCard(number: step.$1, label: step.$2),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSlotMachine() {
    const double visibleHeight = _itemHeight * 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: visibleHeight,
        child: Stack(
          children: [
            // ── Active row highlight (fixed, behind the reel) ──────────
            Positioned(
              top: _itemHeight,
              left: 0,
              right: 0,
              height: _itemHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // ── Scrolling reel (clipped to 3 rows) ────────────────────
            ClipRect(
              child: AnimatedBuilder(
                animation: _reelAnim,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, _reelAnim.value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // We render 4 slots so the 4th is visible sliding in
                        // during the last frame: prev, current, next, nextNext
                        _buildReelItem(_topic(-1), isActive: false),
                        _buildReelItem(_topic(0), isActive: true),
                        _buildReelItem(_topic(1), isActive: false),
                        // _buildReelItem(_topic(2), isActive: false),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReelItem(String text, {required bool isActive}) {
    return SizedBox(
      height: _itemHeight,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'geist',
              fontSize: isActive ? 18 : 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? AppColors.primary : const Color(0xFFBBBBBB),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // SPIN button — filled primary
        Expanded(
          flex: 3,
          child: _SpinButton(isSpinning: _isSpinning, onTap: _spin),
        ),
        const SizedBox(width: 12),

        // TIMER button — void (outlined)
        Expanded(
          flex: 2,
          child: _OutlinedButton(
            label: 'Timer',
            onTap: () {
              HapticFeedback.lightImpact();
              upSlideTransition(
                context,
                TimerScreen(topic: _topics[_currentIndex]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final String number;
  final String label;

  const _StepCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontFamily: 'shrikhand',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'geist',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinButton extends StatelessWidget {
  final bool isSpinning;
  final VoidCallback onTap;

  const _SpinButton({required this.isSpinning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSpinning ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          color: isSpinning
              ? AppColors.primary.withValues(alpha: 0.85)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Spin!',
            style: TextStyle(
              fontFamily: 'geist',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSpinning ? Colors.white.withAlpha(100) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlinedButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'geist',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

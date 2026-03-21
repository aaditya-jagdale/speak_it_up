import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:speak_it_up/shared/widgets/colors.dart';

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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ── slot machine state ──────────────────────────────────────────────
  int _currentIndex = 0;
  bool _isSpinning = false;

  // ── helpers ─────────────────────────────────────────────────────────
  String get _prevTopic =>
      _topics[(_currentIndex - 1 + _topics.length) % _topics.length];
  String get _currentTopic => _topics[_currentIndex];
  String get _nextTopic => _topics[(_currentIndex + 1) % _topics.length];

  Future<void> _spin() async {
    if (_isSpinning) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSpinning = true);

    // Run several fast spins then settle
    const int totalTicks = 12;
    for (int i = 0; i < totalTicks; i++) {
      await Future.delayed(Duration(milliseconds: 50 + (i * 12).clamp(0, 200)));
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _topics.length;
      });
    }

    await Future.delayed(const Duration(milliseconds: 80));
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

    return Row(
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
    );
  }

  Widget _buildSlotMachine() {
    const double itemHeight = 60.0;
    const double visibleHeight = 180.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRect(
        child: SizedBox(
          height: visibleHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ghost row above
              SizedBox(
                height: itemHeight,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 80),
                    child: Text(
                      _prevTopic,
                      key: ValueKey('prev_$_currentIndex'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFBBBBBB),
                      ),
                    ),
                  ),
                ),
              ),

              // Active row (highlighted card)
              Container(
                height: itemHeight,
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 80),
                    transitionBuilder: (child, animation) {
                      final slide =
                          Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _currentTopic,
                        key: ValueKey('curr_$_currentIndex'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'geist',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Ghost row below
              SizedBox(
                height: itemHeight,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 80),
                    child: Text(
                      _nextTopic,
                      key: ValueKey('next_$_currentIndex'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFBBBBBB),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
              // TODO: open timer
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontFamily: 'geist',
              fontSize: 14,
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

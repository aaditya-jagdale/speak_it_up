import 'dart:math';
import 'package:speak_it_up/shared/widgets/colors.dart';

import 'package:flutter/cupertino.dart';

class CustomProgressBar extends StatefulWidget {
  final double progressPercent;
  final Color progressColor;
  const CustomProgressBar({
    super.key,
    required this.progressPercent,
    this.progressColor = AppColors.primary,
  });

  @override
  State<CustomProgressBar> createState() => _CustomProgressBarState();
}

class _CustomProgressBarState extends State<CustomProgressBar> {
  @override
  Widget build(BuildContext context) {
    print(widget.progressPercent);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.black50.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: min(1, widget.progressPercent)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (BuildContext context, double animatedFactor, Widget? child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: animatedFactor,
            child: Container(
              decoration: BoxDecoration(
                color: widget.progressColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        },
      ),
    );
  }
}

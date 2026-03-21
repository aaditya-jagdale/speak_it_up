import 'package:flutter/material.dart';
import 'package:speak_it_up/shared/widgets/colors.dart';

class CustomProgressIndicator extends StatelessWidget {
  final Color color;
  const CustomProgressIndicator({super.key, this.color = AppColors.black});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeCap: StrokeCap.round,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

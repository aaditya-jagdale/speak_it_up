import 'package:flutter/material.dart';
import 'package:speak_it_up/shared/widgets/colors.dart';
import 'package:speak_it_up/shared/widgets/custom_progress_indicator.dart';

class PrimaryButton extends StatefulWidget {
  final String title;
  final TextStyle textStyle;
  final Widget? icon;
  final Widget trailingIcon;
  final bool isLoading;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;

  final void Function()? onPressed;
  const PrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.textStyle = const TextStyle(
      fontSize: 16,
      color: AppColors.white,
      fontWeight: FontWeight.w500,
    ),
    this.icon,
    this.trailingIcon = const SizedBox(),
    this.isLoading = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          backgroundColor: AppColors.black,
          shadowColor: AppColors.black25,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        onPressed: widget.onPressed,
        child:
            widget.isLoading
                ? const CustomProgressIndicator(color: AppColors.white)
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment:
                      widget.mainAxisAlignment ?? MainAxisAlignment.center,
                  crossAxisAlignment:
                      widget.crossAxisAlignment ?? CrossAxisAlignment.center,
                  children: [
                    if (widget.icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: widget.icon,
                      ),
                    Text(widget.title, style: widget.textStyle),
                  ],
                ),
      ),
    );
  }
}

class GhostButton extends StatefulWidget {
  final String title;
  final TextStyle textStyle;
  final Widget icon;
  final Widget trailingIcon;
  final TextAlign? textAlign;
  final void Function()? onPressed;
  const GhostButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.textAlign,
    this.textStyle = const TextStyle(
      fontSize: 18,
      color: AppColors.black,
      fontWeight: FontWeight.normal,
    ),
    this.icon = const SizedBox(),
    this.trailingIcon = const SizedBox(),
  });

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          backgroundColor: AppColors.white,
          shadowColor: AppColors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: const BorderSide(color: AppColors.black),
          ),
        ),
        onPressed: widget.onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.icon != const SizedBox())
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: widget.icon,
              ),
            Text(
              widget.title,
              textAlign: widget.textAlign,
              style: widget.textStyle,
            ),
            const Spacer(),
            widget.trailingIcon,
          ],
        ),
      ),
    );
  }
}

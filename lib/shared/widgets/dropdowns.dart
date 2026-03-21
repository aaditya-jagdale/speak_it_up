import 'package:flutter/material.dart';
import 'package:speak_it_up/shared/widgets/colors.dart';

class CustomDropDown extends StatelessWidget {
  final String? selectedGender;
  final List<String> items;
  final Function(String?)? onChanged;
  final String? hintText;
  const CustomDropDown({
    super.key,
    required this.selectedGender,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primary)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            hintText ?? '',
            style: TextStyle(color: AppColors.primary.withOpacity(0.4)),
          ),
          value: selectedGender,
          isExpanded: true,
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          items: items.map((String gender) {
            return DropdownMenuItem<String>(value: gender, child: Text(gender));
          }).toList(),
        ),
      ),
    );
  }
}

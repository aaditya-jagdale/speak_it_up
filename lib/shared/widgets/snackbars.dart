import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showCustomSnackBar(
  BuildContext context, {
  required String? message,
  // required ToastificationType type,
  required IconData icon,
  List<SnackBarAction>? actions, // Optional actions parameter
}) {
  if (message == null || message.isEmpty) return;

  // ScaffoldMessenger.of(context).clearSnackBars();
  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(
  //     content: Row(
  //       children: [
  //         Icon(icon, color: Colors.white, size: 24),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Text(
  //             message,
  //             style: const TextStyle(color: Colors.white, fontSize: 16),
  //           ),
  //         ),
  //         if (actions != null) ...actions, // Add actions if provided
  //       ],
  //     ),
  //     backgroundColor: backgroundColor.withOpacity(0.9),
  //     behavior: SnackBarBehavior.floating, // Makes it float above UI
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12), // Rounded corners
  //     ),
  //     elevation: 6, // Adds shadow for depth
  //   ),
  // );
  // Toast
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

void successSnackBar(
  BuildContext context,
  String? message, {
  List<SnackBarAction>? actions,
}) {
  showCustomSnackBar(
    context,
    message: message,
    // type: ToastificationType.success,
    icon: Icons.check_circle_rounded,
    actions: actions,
  );
}

// Error Snackbar
void errorSnackBar(
  BuildContext context,
  String? message, {
  List<SnackBarAction>? actions,
}) {
  showCustomSnackBar(
    context,
    message: message,
    // type: ToastificationType.error,
    icon: Icons.error_rounded,
    actions: actions,
  );
}

// Info Snackbar
void infoSnackBar(
  BuildContext context,
  String? message, {
  List<SnackBarAction>? actions,
}) {
  showCustomSnackBar(
    context,
    message: message,
    // type: ToastificationType.info,
    icon: Icons.info_rounded,
    actions: actions,
  );
}

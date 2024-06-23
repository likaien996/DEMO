import 'package:flutter/material.dart';

void myShowDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.all(15),
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

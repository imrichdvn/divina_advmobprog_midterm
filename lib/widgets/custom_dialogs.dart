import 'package:divina/constants.dart';
import 'package:flutter/material.dart';

void customDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  final AlertDialog alertDialog = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: <Widget>[
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: FB_DARK_PRIMARY,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Okay'),
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alertDialog;
    },
  );
}

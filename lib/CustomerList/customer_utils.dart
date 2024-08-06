import 'package:flutter/material.dart';
import 'package:final_project/AppLocalizations.dart';


void showAlertDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void showUsageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context).translate('instructions')),
        content: Text(AppLocalizations.of(context)
            .translate('instructions_detail')),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context).translate('close')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

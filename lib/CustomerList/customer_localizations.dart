import 'package:flutter/material.dart';
import 'package:final_project/AppLocalizations.dart';

String translate(BuildContext context, String key) {
  return AppLocalizations.of(context).translate(key);
}

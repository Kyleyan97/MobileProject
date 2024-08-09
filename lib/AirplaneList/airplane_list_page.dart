import 'package:flutter/material.dart';
import 'package:final_project/AppLocalizations.dart';
import 'package:final_project/main.dart';
import 'package:final_project/AirplaneList/Airplane.dart';
import 'package:final_project/AirplaneList/AirplaneDAO.dart';
import 'package:final_project/Database.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'AirplaneListState.dart';

/// A StatefulWidget that represents the page displaying a list of airplanes.
///
/// The [AirplaneListPage] widget interacts with the [AirplaneListState] to manage the state
/// and UI of the airplane list. It is the main entry point for viewing and interacting with the
/// airplane data.
class AirplaneListPage extends StatefulWidget {
  /// Constructs an [AirplaneListPage].
  ///
  /// The [key] parameter is used to uniquely identify this widget in the widget tree.
  const AirplaneListPage({Key? key}) : super(key: key);

  /// Creates the mutable state for this widget, represented by [AirplaneListState].
  @override
  State<AirplaneListPage> createState() => AirplaneListState();
}

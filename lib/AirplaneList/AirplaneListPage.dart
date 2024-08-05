import 'package:final_project/AppLocalizations.dart';
import 'package:final_project/main.dart';
import 'package:flutter/material.dart';
import 'package:final_project/AirplaneList/Airplane.dart';
import 'package:final_project/AirplaneList/AirplaneDAO.dart';
import 'package:final_project/AppDatabase.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class AirplaneListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AirplaneListPageState();
  }
}

/// State class for [AirplaneListPage] that handles airplane data and UI.
class _AirplaneListPageState extends State<AirplaneListPage> {
  /// EncryptedSharedPreferences instance for securely storing data.
  late EncryptedSharedPreferences savedData;

  /// Data Access Object for airplanes.
  late AirplaneDAO myAirplaneDAO;

  /// List of airplanes.
  List<Airplane> airplanes = [];

  /// Controller for managing scroll behavior.
  late ScrollController _scrollController;

  /// Currently selected airplane, if any.
  Airplane? selectedAirplane;

  /// Flag to indicate if a new airplane is being added.
  bool isAddingNewAirplane = false;

  /// Flag to indicate if an airplane is being updated.
  bool isUpdatingAirplane = false;

  /// Controller for airplane details input fields.
  late TextEditingController typeController;
  late TextEditingController passengersController;
  late TextEditingController speedController;
  late TextEditingController distanceController;

  /// ID of the airplane being updated.
  int? _airplaneToUpdateId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    typeController = TextEditingController();
    passengersController = TextEditingController();
    speedController = TextEditingController();
    distanceController = TextEditingController();
    initDb();
    initEncryptedSharedPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSnackBar();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    typeController.dispose();
    passengersController.dispose();
    speedController.dispose();
    distanceController.dispose();
    super.dispose();
  }

  /// Initializes the database and loads airplanes.
  void initDb() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    myAirplaneDAO = database.airplaneDAO;
    loadAirplanes();
  }

  /// Loads airplanes from the database.
  void loadAirplanes() async {
    airplanes = await myAirplaneDAO.findAllAirplanes();
    setState(() {});
  }

  /// Initializes encrypted shared preferences for storing sensitive data.
  void initEncryptedSharedPreferences() async {
    savedData = EncryptedSharedPreferences();
  }

  /// Adds a new airplane to the database and updates the list.
  void addAirplane() async {
    if (typeController.text.isNotEmpty &&
        passengersController.text.isNotEmpty &&
        speedController.text.isNotEmpty &&
        distanceController.text.isNotEmpty) {
      final airplane = Airplane(
        Airplane.ID++,
        typeController.text,
        int.parse(passengersController.text),
        int.parse(speedController.text),
        int.parse(distanceController.text),
      );
      await myAirplaneDAO.insertAirplane(airplane);
      loadAirplanes();
      clearInputFields();
      setState(() {
        isAddingNewAirplane = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Airplane added successfully')),
      );
    } else {
      showAlertDialog("Error", "All fields are required.");
    }
  }

  /// Clears the input fields.
  void clearInputFields() {
    typeController.clear();
    passengersController.clear();
    speedController.clear();
    distanceController.clear();
  }

  /// Shows an alert dialog with a given title and message.
  void showAlertDialog(String title, String message) {
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

  /// Shows a snack bar with a welcome message.
  void showSnackBar() {
    var showSnackBar = ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text(AppLocalizations.of(context).translate('welcome_to_airplane_list'))
      )
    );
  }

  /// Widget for displaying the list of airplanes.
  /// Widget for displaying the list of airplanes.
  Widget airplaneList() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Scrollbar(
        controller: _scrollController,
        thickness: 8.0,
        radius: Radius.circular(10.0),
        thumbVisibility: false,
        child: airplanes.isEmpty
            ? Center(
          child: Text(AppLocalizations.of(context).translate('no_airplane_selected')),
        )
            : ListView.builder(
          controller: _scrollController,
          itemCount: airplanes.length,
          itemBuilder: (BuildContext context, int index) {
            var airplane = airplanes[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAirplane = airplane;
                });
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Delete Airplane"),
                      content: const Text("Are you sure you want to delete this airplane?"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Yes"),
                          onPressed: () {
                            myAirplaneDAO.deleteAirplane(airplane);
                            loadAirplanes();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Airplane deleted successfully')),
                            );
                          },
                        ),
                        TextButton(
                          child: Text("No"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text("${index + 1}"),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${airplane.type}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 50),
                          Text(
                            "Passengers: ${airplane.maxNumberOfPassenger}, Speed: ${airplane.maxSpeed}, Distance: ${airplane.maxDistance}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Widget for displaying the details of the selected airplane.
  Widget airplaneDetails() {
    if (selectedAirplane == null) {
      return Center(
        child: Text(AppLocalizations.of(context).translate('no_airplane_selected'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context).translate('airplane_detail'), style: const TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(150.0),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('airplane_type'), style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    Text('${selectedAirplane!.type}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('max_passengers'), style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    Text('${selectedAirplane!.maxNumberOfPassenger}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('max_speed'), style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    Text('${selectedAirplane!.maxSpeed}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('max_distance'), style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    Text('${selectedAirplane!.maxDistance}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.center),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isUpdatingAirplane = true;
                      _airplaneToUpdateId = selectedAirplane!.id;
                      typeController.text = selectedAirplane!.type;
                      passengersController.text = selectedAirplane!.maxNumberOfPassenger.toString();
                      speedController.text = selectedAirplane!.maxSpeed.toString();
                      distanceController.text = selectedAirplane!.maxDistance.toString();
                    });
                  },
                  child: Text(AppLocalizations.of(context).translate('update_airplane')),
                ),
                ElevatedButton(
                  onPressed: () => _removeAirplane(selectedAirplane!),
                  child: Text(AppLocalizations.of(context).translate('delete_airplane')),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedAirplane = null;
                    });
                  },
                  child: Text(AppLocalizations.of(context).translate('return_to_list')),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  /// Removes an airplane from the database and updates the list.
  void _removeAirplane(Airplane airplane) async {
    await myAirplaneDAO.deleteAirplane(airplane);
    loadAirplanes();
    setState(() {
      selectedAirplane = null;
    });
  }

  /// Widget for the form to add or update an airplane.
  Widget addOrUpdateAirplaneForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: typeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('airplane_type_input'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passengersController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('max_passengers_input'),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: speedController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('max_speed_input'),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: distanceController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('max_distance_input'),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (isUpdatingAirplane) {
                  updateAirplane();
                } else {
                  addAirplane();
                }
              },
              child: Text(isUpdatingAirplane ? AppLocalizations.of(context).translate('update_airplane') : AppLocalizations.of(context).translate('add_airplane')),
            ),
          ],
        ),
      ),
    );
  }

  /// Updates an existing airplane in the database and updates the list.
  void updateAirplane() async {
    if (typeController.text.isNotEmpty &&
        passengersController.text.isNotEmpty &&
        speedController.text.isNotEmpty &&
        distanceController.text.isNotEmpty &&
        _airplaneToUpdateId != null) {
      final airplane = Airplane(
        _airplaneToUpdateId!,
        typeController.text,
        int.parse(passengersController.text),
        int.parse(speedController.text),
        int.parse(distanceController.text),
      );
      await myAirplaneDAO.updateAirplane(airplane);
      loadAirplanes();
      clearInputFields();
      setState(() {
        isUpdatingAirplane = false;
        selectedAirplane = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Airplane updated successfully')),
      );
    } else {
      showAlertDialog("Error", "All fields are required.");
    }
  }

  /// Widget for building the main layout of the airplane list page.
    @override
    Widget build(BuildContext context) {
      var size = MediaQuery
          .of(context)
          .size;
      var height = size.height;
      var width = size.width;

      /// Returns the responsive layout based on the current state of the application
      /// and the screen dimensions.
      Widget responsiveLayout() {
        if (!isAddingNewAirplane && !isUpdatingAirplane) {
          if ((width > height) && (width > 720)) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: airplaneList(),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: airplaneDetails(),
                  ),
                )
              ],
            );
          } else {
            if (selectedAirplane == null) {
              return airplaneList();
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: airplaneDetails(),
              );
            }
          }
        } else if (isAddingNewAirplane && !isUpdatingAirplane) {
          if ((width > height) && (width > 720)) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: airplaneList(),
                ),
                Expanded(
                  flex: 1,
                  child: addOrUpdateAirplaneForm(),
                )
              ],
            );
          } else {
            return addOrUpdateAirplaneForm();
          }
        } else if (!isAddingNewAirplane && isUpdatingAirplane) {
          if ((width > height) && (width > 720)) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: airplaneList(),
                ),
                Expanded(
                  flex: 1,
                  child: addOrUpdateAirplaneForm(),
                )
              ],
            );
          } else {
            if (selectedAirplane == null) {
              return Text(
                  AppLocalizations.of(context).translate(
                      'no_airplane_selected'));
            } else {
              return addOrUpdateAirplaneForm();
            }
          }
        } else {
          return Text("");
        }
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('airplane_list_title')),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: pressAddAirplane,
            ),
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  selectedAirplane = null;
                  isAddingNewAirplane = false;
                  isUpdatingAirplane = false;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                _showUsageDialog(context);
              },
            ),
            PopupMenuButton<Locale>(
              onSelected: (Locale locale) {
                MyApp.of(context)!.changeLanguage(locale); // 替换成您的语言切换逻辑
              },
              icon: Icon(Icons.language),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
                PopupMenuItem<Locale>(
                  value: const Locale('en', 'CA'),
                  child: Text('English'),
                ),
                PopupMenuItem<Locale>(
                  value: const Locale('zh', 'Hans'),
                  child: Text('简体中文'),
                ),
              ],
            ),
          ],
        ),
        body: responsiveLayout(),
        floatingActionButton: ((width > height) && (width > 720) ||
            (width <= height && selectedAirplane == null)) &&
            !isAddingNewAirplane &&
            !isUpdatingAirplane
            ? FloatingActionButton(
          onPressed: pressAddAirplane,
          tooltip: AppLocalizations.of(context).translate('add_airplane'),
          child: const Icon(Icons.add),
        )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

  /// Initiates the process of adding a new airplane.
  void pressAddAirplane() {
    setState(() {
      isAddingNewAirplane = true;
      isUpdatingAirplane = false;
    });
  }

  /// Displays the usage instructions for the application in a dialog.
  void _showUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('instructions')),
          content: Text(
              AppLocalizations.of(context).translate('instructions_detail')),
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
}
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../AppLocalizations.dart';
import '../Database.dart';
import '../main.dart';
import 'Airplane.dart';
import 'AirplaneDAO.dart';
import 'airplane_list_page.dart';

/// The state class for [AirplaneListPage], responsible for managing the state and UI of the airplane list page.
///
/// This class handles the initialization of the database, loading of airplanes, and managing user interactions
/// such as adding, updating, and deleting airplanes.
class AirplaneListState extends State<AirplaneListPage> {
  /// Manages encrypted shared preferences for securely storing persistent data.
  late EncryptedSharedPreferences savedData;

  /// Data access object for performing CRUD operations on the airplane database.
  late AirplaneDAO myAirplaneDAO;

  /// A list of airplanes fetched from the database.
  List<Airplane> airplanes = [];

  /// Controller for managing the scroll position of the list view.
  late ScrollController _scrollController;

  /// The currently selected airplane, if any.
  Airplane? selectedAirplane;

  /// Indicates whether a new airplane is being added.
  bool isAddingNewAirplane = false;

  /// Indicates whether an existing airplane is being updated.
  bool isUpdatingAirplane = false;

  /// Text controllers for managing input fields.
  late TextEditingController typeController;
  late TextEditingController passengersController;
  late TextEditingController speedController;
  late TextEditingController distanceController;

  /// The ID of the airplane being updated, if applicable.
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

  /// Initializes the database and loads the airplanes.
  void initDb() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    myAirplaneDAO = database.airplaneDAO;
    loadAirplanes();
  }

  /// Loads all airplanes from the database and updates the state.
  void loadAirplanes() async {
    airplanes = await myAirplaneDAO.findAllAirplanes();
    setState(() {});
  }

  /// Initializes encrypted shared preferences.
  void initEncryptedSharedPreferences() async {
    savedData = EncryptedSharedPreferences();
  }

  /// Adds a new airplane to the database if all input fields are filled.
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

  /// Clears all input fields.
  void clearInputFields() {
    typeController.clear();
    passengersController.clear();
    speedController.clear();
    distanceController.clear();
  }

  /// Displays an alert dialog with the given [title] and [message].
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

  /// Displays a SnackBar with a welcome message.
  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).translate('welcome_to_airplane_list'))
        )
    );
  }

  /// Builds the widget displaying the list of airplanes.
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
                            "${AppLocalizations.of(context).translate('passengers')}: ${airplane.maxNumberOfPassenger}, ${AppLocalizations.of(context).translate('speed')}: ${airplane.maxSpeed}, ${AppLocalizations.of(context).translate('distance')}: ${airplane.maxDistance}",
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

  /// Builds the widget displaying the details of the selected airplane.
  ///
  /// If no airplane is selected, a message is displayed instead.
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
            Text(AppLocalizations.of(context).translate('airplane_detail'), style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(150.0),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('airplane_type'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                    Text('${selectedAirplane!.type}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                  ],
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('max_passengers'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                    Text('${selectedAirplane!.maxNumberOfPassenger}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                  ],
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('max_speed'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                    Text('${selectedAirplane!.maxSpeed}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                  ],
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('max_distance'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                    Text('${selectedAirplane!.maxDistance}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
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

  /// Deletes the given [airplane] from the database and updates the state.
  void _removeAirplane(Airplane airplane) async {
    await myAirplaneDAO.deleteAirplane(airplane);
    loadAirplanes();
    setState(() {
      selectedAirplane = null;
    });
  }

  /// Builds the widget displaying the form for adding or updating an airplane.
  ///
  /// The form includes input fields for airplane type, passengers, speed, and distance, and
  /// a submit button that either adds a new airplane or updates an existing one based on the current state.
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

  /// Updates the selected airplane in the database if all input fields are filled.
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    /// Builds the responsive layout based on screen size and current state.
    ///
    /// This method determines whether to show the airplane list, the airplane details,
    /// the add/update form, or a combination of these based on the current screen size
    /// and state of the application.
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
            return Text(AppLocalizations.of(context).translate('no_airplane_selected'));
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
          PopupMenuButton<Locale>(
            onSelected: (Locale locale) {
              MyApp.of(context)!.changeLanguage(locale);
            },
            icon: Icon(Icons.language_sharp),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              PopupMenuItem<Locale>(
                value: const Locale('en', 'CA'),
                child: Text('English'),
              ),
              PopupMenuItem<Locale>(
                value: const Locale('zh', 'Hans'),
                child: Text('中文'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showUsageDialog(context);
            },
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

  /// Sets the state to add a new airplane.
  void pressAddAirplane() {
    setState(() {
      isAddingNewAirplane = true;
      isUpdatingAirplane = false;
    });
  }

  /// Displays a usage instructions dialog.
  void _showUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('instructions')),
          content: Text(AppLocalizations.of(context).translate('instructions_detail')),
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

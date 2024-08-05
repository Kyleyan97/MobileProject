import 'package:flutter/material.dart';
import 'package:final_project/AppLocalizations.dart';
import 'package:final_project/main.dart';
import 'package:final_project/FlightList/Flight.dart';
import 'package:final_project/FlightList/FlightDAO.dart';
import 'package:final_project/Database.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

/// This class represents the flight list page.
class FlightListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FlightListPageState();
  }
}

/// State class for [FlightListPage].
class _FlightListPageState extends State<FlightListPage> {
  late EncryptedSharedPreferences savedData;
  late FlightDAO myFlightDAO;
  List<Flight> flights = [];
  late ScrollController _scrollController;
  Flight? selectedFlight;
  bool isAddingNewFlight = false;
  bool isUpdatingFlight = false;
  late TextEditingController flightNumberController;
  late TextEditingController departureCityController;
  late TextEditingController destinationCityController;
  DateTime? departureTime;
  DateTime? arrivalTime;
  int? _flightToUpdateId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    flightNumberController = TextEditingController();
    departureCityController = TextEditingController();
    destinationCityController = TextEditingController();
    initDb();
    initEncryptedSharedPreferences();
    flightNumberController.addListener(_saveInputFields);
    departureCityController.addListener(_saveInputFields);
    destinationCityController.addListener(_saveInputFields);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSnackBar();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    flightNumberController.dispose();
    departureCityController.dispose();
    destinationCityController.dispose();
    super.dispose();
  }

  /// Initialize the database and load flights.
  void initDb() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    myFlightDAO = database.flightDAO;
    loadFlights();
  }

  /// Load flights from the database.
  void loadFlights() async {
    flights = await myFlightDAO.getAllFlights();
    setState(() {});
  }

  /// Initialize encrypted shared preferences and load saved data.
  void initEncryptedSharedPreferences() async {
    savedData = EncryptedSharedPreferences();
    flightNumberController.text = await savedData.getString('flightNumber') ?? '';
    departureCityController.text = await savedData.getString('departureCity') ?? '';
    destinationCityController.text = await savedData.getString('destinationCity') ?? '';

    String? depTimeString = await savedData.getString('departureTime');
    if (depTimeString != null) {
      try {
        departureTime = DateTime.parse(depTimeString);
      } catch (e) {
        print('Invalid departureTime format: $depTimeString'); // 添加日志输出
      }
    }

    String? arrTimeString = await savedData.getString('arrivalTime');
    if (arrTimeString != null) {
      try {
        arrivalTime = DateTime.parse(arrTimeString);
      } catch (e) {
        print('Invalid arrivalTime format: $arrTimeString'); // 添加日志输出
      }
    }
  }

  /// Save input fields to encrypted shared preferences.
  void _saveInputFields() {
    savedData.setString('flightNumber', flightNumberController.text);
    savedData.setString('departureCity', departureCityController.text);
    savedData.setString('destinationCity', destinationCityController.text);
    if (departureTime != null) {
      savedData.setString('departureTime', departureTime!.toIso8601String());
    }
    if (arrivalTime != null) {
      savedData.setString('arrivalTime', arrivalTime!.toIso8601String());
    }
  }

  /// Add a new flight to the database.
  void addFlight() async {
    if (flightNumberController.text.isNotEmpty &&
        departureCityController.text.isNotEmpty &&
        destinationCityController.text.isNotEmpty &&
        departureTime != null &&
        arrivalTime != null) {
      final flight = Flight(
        Flight.ID++,
        flightNumberController.text,
        departureCityController.text,
        destinationCityController.text,
        departureTime!,
        arrivalTime!,
        1,
      );
      await myFlightDAO.insertFlight(flight);
      loadFlights();
      clearInputFields();
      setState(() {
        isAddingNewFlight = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('flight_updated'))),
      );
    } else {
      showAlertDialog(
          AppLocalizations.of(context).translate('error'),
          AppLocalizations.of(context).translate('all_fields_required')
      );
    }
  }

  /// Clear input fields.
  void clearInputFields() {
    flightNumberController.clear();
    departureCityController.clear();
    destinationCityController.clear();
    departureTime = null;
    arrivalTime = null;
  }

  /// Show an alert dialog with a given title and message.
  void showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).translate('OK')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Show a snack bar with a welcome message.
  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).translate('welcome_to_flight_list'))
        )
    );
  }

  /// Build the list of flights.
  Widget flightList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scrollbar(
        controller: _scrollController,
        thickness: 8.0,
        radius: Radius.circular(20.0),
        thumbVisibility: true,
        child: flights.isEmpty
            ? Center(
          child: Text(AppLocalizations.of(context).translate('no_flight_available')),
        )
            : ListView.builder(
          controller: _scrollController,
          itemCount: flights.length,
          itemBuilder: (BuildContext context, int index) {
            var flight = flights[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedFlight = flight;
                });
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context).translate('delete_flight_title')),
                      content: Text(AppLocalizations.of(context).translate('delete_flight_confirmation')),
                      actions: <Widget>[
                        TextButton(
                          child: Text(AppLocalizations.of(context).translate('yes')),
                          onPressed: () {
                            myFlightDAO.deleteFlight(flight);
                            loadFlights();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context).translate('flight_deleted'))),
                            );
                          },
                        ),
                        TextButton(
                          child: Text(AppLocalizations.of(context).translate('No')),
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
                        ? Colors.lightBlueAccent.withOpacity(0.2)
                        : Colors.lightBlueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
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
                            "${flight.flightNumber}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 50),
                          Text(
                            "From: ${flight.departureCity} To: ${flight.destinationCity}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
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

  /// Build the details of the selected flight.
  Widget flightDetails() {
    if (selectedFlight == null) {
      return Center(
        child: Text(AppLocalizations.of(context).translate('no_flight_selected'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red)),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context).translate('flight_detail'), style: const TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(150.0),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('flight_number'), style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    Text('${selectedFlight!.flightNumber}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('departure_city'), style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    Text('${selectedFlight!.departureCity}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('destination_city'), style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    Text('${selectedFlight!.destinationCity}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('departure_time'),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${TimeOfDay.fromDateTime(selectedFlight!.departureTime).format(context)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('arrival_time'),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${TimeOfDay.fromDateTime(selectedFlight!.arrivalTime).format(context)}',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
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
                      isUpdatingFlight = true;
                      _flightToUpdateId = selectedFlight!.id;
                      flightNumberController.text = selectedFlight!.flightNumber;
                      departureCityController.text = selectedFlight!.departureCity;
                      destinationCityController.text = selectedFlight!.destinationCity;
                      departureTime = selectedFlight!.departureTime;
                      arrivalTime = selectedFlight!.arrivalTime;
                    });
                  },
                  child: Text(AppLocalizations.of(context).translate('update_flight')),
                ),
                ElevatedButton(
                  onPressed: () => _removeFlight(selectedFlight!),
                  child: Text(AppLocalizations.of(context).translate('delete_flight')),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedFlight = null;
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

  /// Remove a flight after confirmation.
  void _removeFlight(Flight flight) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('delete_flight_title')),
          content: Text(AppLocalizations.of(context).translate('delete_flight_confirmation')),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).translate('yes')),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).translate('No')),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );

    if (confirm) {
      await myFlightDAO.deleteFlight(flight);
      loadFlights();
      setState(() {
        selectedFlight = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('flight_deleted_successfully'))),
      );
    }
  }

  /// Build the form for adding or updating a flight.
  Widget addOrUpdateFlightForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: flightNumberController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('flight_number_input'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: departureCityController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('departure_city_input'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: destinationCityController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('destination_city_input'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, true), // 使用新的选择时间方法
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate('departure_time_input'),
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(
                          text: departureTime != null
                              ? TimeOfDay.fromDateTime(departureTime!).format(context)
                              : '',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, false), // 使用新的选择时间方法
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate('arrival_time_input'),
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(
                          text: arrivalTime != null
                              ? TimeOfDay.fromDateTime(arrivalTime!).format(context)
                              : '',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (isUpdatingFlight) {
                  updateFlight();
                } else {
                  addFlight();
                }
              },
              child: Text(isUpdatingFlight
                  ? AppLocalizations.of(context).translate('update_flight')
                  : AppLocalizations.of(context).translate('add_flight')),
            ),
          ],
        ),
      ),
    );
  }

  /// Select time for departure or arrival.
  void _selectTime(BuildContext context, bool isDeparture) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
    );
    if (time != null) {
      setState(() {
        if (isDeparture) {
          departureTime = DateTime(0, 1, 1, time.hour, time.minute); // 只保存时间部分
        } else {
          arrivalTime = DateTime(0, 1, 1, time.hour, time.minute); // 只保存时间部分
        }
      });
    }
  }

  /// Update a flight in the database.
  void updateFlight() async {
    if (flightNumberController.text.isNotEmpty &&
        departureCityController.text.isNotEmpty &&
        destinationCityController.text.isNotEmpty &&
        departureTime != null &&
        arrivalTime != null &&
        _flightToUpdateId != null) {

      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).translate('confirm_to_save')),
            content: Text(AppLocalizations.of(context).translate('confirm_update_content')),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context).translate('yes')),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context).translate('No')),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        },
      );

      if (confirm) {
        final flight = Flight(
          _flightToUpdateId!,
          flightNumberController.text,
          departureCityController.text,
          destinationCityController.text,
          departureTime!,
          arrivalTime!,
          1,
        );
        await myFlightDAO.updateFlight(flight);
        loadFlights();
        clearInputFields();
        setState(() {
          isUpdatingFlight = false;
          selectedFlight = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('flight_updated'))),
        );
      }
    } else {
      showAlertDialog(
        AppLocalizations.of(context).translate('error'),
        AppLocalizations.of(context).translate('all_fields_required'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    Widget responsiveLayout() {
      if (!isAddingNewFlight && !isUpdatingFlight) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: flightList(),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: flightDetails(),
                ),
              )
            ],
          );
        } else {
          if (selectedFlight == null) {
            return flightList();
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: flightDetails(),
            );
          }
        }
      } else if (isAddingNewFlight && !isUpdatingFlight) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: flightList(),
              ),
              Expanded(
                flex: 1,
                child: addOrUpdateFlightForm(),
              )
            ],
          );
        } else {
          return addOrUpdateFlightForm();
        }
      } else if (!isAddingNewFlight && isUpdatingFlight) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: flightList(),
              ),
              Expanded(
                flex: 1,
                child: addOrUpdateFlightForm(),
              )
            ],
          );
        } else {
          if (selectedFlight == null) {
            return Text(AppLocalizations.of(context).translate('no_flight_selected'));
          } else {
            return addOrUpdateFlightForm();
          }
        }
      } else {
        return Text("");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('flight_list_title')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: pressAddFlight,
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                selectedFlight = null;
                isAddingNewFlight = false;
                isUpdatingFlight = false;
              });
            },
          ),

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
          (width <= height && selectedFlight == null)) &&
          !isAddingNewFlight &&
          !isUpdatingFlight
          ? FloatingActionButton(
        onPressed: pressAddFlight,
        tooltip: AppLocalizations.of(context).translate('add_flight'),
        child: const Icon(Icons.add),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Show the form for adding a new flight or copying previous flight details.
  void pressAddFlight() async {
    print('pressAddFlight called');
    String? flightNumber = await savedData.getString('flightNumber');
    String? departureCity = await savedData.getString('departureCity');
    String? destinationCity = await savedData.getString('destinationCity');

    String? depTimeString = await savedData.getString('departureTime');
    DateTime? depTime;
    if (depTimeString != null) {
      try {
        depTime = DateTime.parse(depTimeString);
      } catch (e) {
        print('Invalid departureTime format: $depTimeString');
      }
    }

    String? arrTimeString = await savedData.getString('arrivalTime');
    DateTime? arrTime;
    if (arrTimeString != null) {
      try {
        arrTime = DateTime.parse(arrTimeString);
      } catch (e) {
        print('Invalid arrivalTime format: $arrTimeString');
      }
    }

    print('Values loaded from shared preferences');
    print('flightNumber: $flightNumber, departureCity: $departureCity, destinationCity: $destinationCity, depTime: $depTime, arrTime: $arrTime');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('copy_previous_flight')),
          content: Text(AppLocalizations.of(context).translate('do_you_want_to_copy_previous_flight')),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).translate('yes')),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  flightNumberController.text = flightNumber ?? '';
                  departureCityController.text = departureCity ?? '';
                  destinationCityController.text = destinationCity ?? '';
                  departureTime = depTime;
                  arrivalTime = arrTime;
                  isAddingNewFlight = true;
                  isUpdatingFlight = false;
                  print('Flight details copied and set');
                });
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).translate('No')),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  flightNumberController.clear();
                  departureCityController.clear();
                  destinationCityController.clear();
                  departureTime = null;
                  arrivalTime = null;
                  isAddingNewFlight = true;
                  isUpdatingFlight = false;
                  print('Input fields cleared');
                });
              },
            ),
          ],
        );
      },
    );
  }

  /// Show the usage dialog with instructions.
  void _showUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('instructions_flight')),
          content: Text(AppLocalizations.of(context).translate('instructions_detail_flight')),
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

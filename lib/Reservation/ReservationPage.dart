import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../AirplaneList/AirplaneDAO.dart';
import '../CustomerList/CustomerDAO.dart';
import '../FlightList/FlightDAO.dart';
import '../Reservation/ReservationDAO.dart';
import '../AirplaneList/Airplane.dart';
import '../Database.dart';
import '../AppLocalizations.dart';
import '../CustomerList/Customer.dart';
import '../FlightList/Flight.dart';
import '../main.dart';
import 'Reservation.dart';

/// A StatefulWidget for managing reservations.
class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

/// State class for [ReservationPage] that handles reservation data and UI.
class _ReservationPageState extends State<ReservationPage> {
  late EncryptedSharedPreferences _savedData;
  late ReservationDAO _reservationDAO;
  late CustomerDAO _customerDAO;
  late AirplaneDAO _airplaneDAO;
  late FlightDAO _flightDAO;

  List<Reservation> _reservations = [];
  List<Customer> _customers = [];
  List<Flight> _flights = [];
  List<Airplane> _airplanes = [];

  late ScrollController _scrollController;

  Reservation? _selectedReservation;
  bool _isAddingNewReservation = false;
  bool _isUpdatingReservation = false;

  late TextEditingController _notesController;

  int? _selectedCustomerId;
  int? _selectedFlightId;
  DateTime? _selectedDate;
  Reservation? _updatedReservation;
  int? _reservationToUpdateId;
  DateTime? _selectedUpdateDate;
  int? _selectedUpdateCustomerId;
  int? _selectedUpdateFlightId;
  bool _updateReservationChanged = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _notesController = TextEditingController();
    _selectedDate = DateTime.now();
    _loadData();
    _initEncryptedSharedPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSnackBar(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _notesController.dispose();
    _saveDataToSharedPreferences();
    super.dispose();
  }

  /// Initializes encrypted shared preferences for storing sensitive data.
  void _initEncryptedSharedPreferences() async {
    _savedData = EncryptedSharedPreferences();

    String? addDate = await _savedData.getString('addDate');
    String? addCustomerId = await _savedData.getString('addCustomerId');
    String? addFlightId = await _savedData.getString('addFlightId');
    String? addNotes = await _savedData.getString('addNotes');

    setState(() {
      if (addDate != null) _selectedDate = DateTime.parse(addDate);
      if (addCustomerId != null) _selectedCustomerId = int.tryParse(addCustomerId);
      if (addFlightId != null) _selectedFlightId = int.tryParse(addFlightId);
      if (addNotes != null) _notesController.text = addNotes;
    });
  }

  /// Saves current state data to shared preferences.
  void _saveDataToSharedPreferences() async {
    if (_selectedDate != null) await _savedData.setString('addDate', _selectedDate!.toIso8601String());
    if (_selectedCustomerId != null) await _savedData.setString('addCustomerId', _selectedCustomerId.toString());
    if (_selectedFlightId != null) await _savedData.setString('addFlightId', _selectedFlightId.toString());
    if (_notesController.text.isNotEmpty) await _savedData.setString('addNotes', _notesController.text);
  }

  /// Reloads reservation data from the database.
  void _loadData() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _reservationDAO = database.reservationDAO;
    _customerDAO = database.customerDAO;
    _airplaneDAO = database.airplaneDAO;
    _flightDAO = database.flightDAO;

    _customers = await _customerDAO.getAllCustomers();
    _airplanes = await _airplaneDAO.findAllAirplanes();
    _flights = await _flightDAO.getAllFlights();

    List<Reservation> allReservations = await _reservationDAO.getAllReservations();
    setState(() {
      _reservations = allReservations;
    });
  }

  /// Shows a snack bar with a welcome message.
  void _showSnackBar(BuildContext context) {
    var snackBar = SnackBar(
      content: Text(AppLocalizations.of(context).translate('welcome_to_reservation_list')),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Widget for displaying the list of reservations.
  Widget _reservationList() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Scrollbar(
        controller: _scrollController,
        thickness: 8.0,
        radius: Radius.circular(10.0),
        thumbVisibility: false,
        child: _reservations.isEmpty
            ? Center(
          child: Text(AppLocalizations.of(context).translate('empty_list')),
        )
            : ListView.builder(
          controller: _scrollController,
          itemCount: _reservations.length,
          itemBuilder: (BuildContext context, int rowNum) {
            var reservation = _reservations[rowNum];
            var customer = _customers.firstWhere(
                  (customer) => customer.id == reservation.customerId,
              orElse: () => Customer(-1, 'Unknown', 'Unknown', 'Unknown Address', DateTime(1900, 1, 1)),
            );

            var flight = _flights.firstWhere(
                  (flight) => flight.id == reservation.flightId,
              orElse: () => Flight(-1, 'Unknown', 'Unknown City', 'Unknown City', DateTime(1900, 1, 1, 0, 0), DateTime(1900, 1, 1, 0, 0), -1),
            );

            var formattedDate = reservation.reservationDate.toString().substring(0, 10);
            var formattedDepartTime = flight.departureTime.toString().substring(11, 16);
            var formattedArrivalTime = flight.arrivalTime.toString().substring(11, 16);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedReservation = _reservations[rowNum];
                });
              },
              onLongPress: () {
                _longPressAction(rowNum);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: rowNum % 2 == 0
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
                            child: Text("${rowNum + 1}"),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "$formattedDate ${customer.firstname} ${customer.lastname} ${flight.flightNumber}",
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
                            "${flight.departureCity} - ${flight.destinationCity}  $formattedDepartTime - $formattedArrivalTime",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
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

  /// Widget for displaying the details of the selected reservations.
  Widget _detailReservationPage() {
    if (_selectedReservation == null) {
      return Center(
        child: Text(AppLocalizations.of(context).translate('no_selection'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
      );
    } else {
      var selectedCustomer = _customers.firstWhere(
            (customer) => customer.id == _selectedReservation!.customerId,
        orElse: () => Customer(-1, 'Unknown', 'Unknown', 'Unknown Address', DateTime(1900, 1, 1)),
      );

      var selectedFlight = _flights.firstWhere(
            (flight) => flight.id == _selectedReservation!.flightId,
        orElse: () => Flight(-1, 'Unknown', 'Unknown City', 'Unknown City', DateTime(1900, 1, 1, 0, 0), DateTime(1900, 1, 1, 0, 0), -1),
      );

      var formattedDate = _selectedReservation!.reservationDate.toString().substring(0, 10);
      var formattedDepartTime = selectedFlight.departureTime.toString().substring(11, 16);
      var formattedArrivalTime = selectedFlight.arrivalTime.toString().substring(11, 16);
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context).translate('reservation_detail'),
                style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            Expanded(
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(120.0),
                  1: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('customer'),
                          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                      Text('${selectedCustomer.firstname} ${selectedCustomer.lastname}',
                          style: const TextStyle(color: Colors.black, fontSize: 15), textAlign: TextAlign.left),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('flight_date'),
                          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                      Text('${formattedDate}', style: const TextStyle(color: Colors.black, fontSize: 15), textAlign: TextAlign.left),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('flight_number'),
                          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                      Text('${selectedFlight.flightNumber}', style: const TextStyle(color: Colors.black, fontSize: 15), textAlign: TextAlign.left),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('departure_city'),
                          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                      Text('${selectedFlight.departureCity}', style: const TextStyle(color: Colors.black, fontSize: 15), textAlign: TextAlign.left),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('destination_city'),
                          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                      Text('${selectedFlight.destinationCity}', style: const TextStyle(color: Colors.black, fontSize: 15), textAlign: TextAlign.left),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('departure_time'),
                          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                      Text('${formattedDepartTime}', style: const TextStyle(color: Colors.black, fontSize: 15), textAlign: TextAlign.left),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('arrival_time'),
                          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                      Text('${formattedArrivalTime}', style: const TextStyle(color: Colors.black, fontSize: 15), textAlign: TextAlign.left),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateOperation();
                  },
                  child: Text(AppLocalizations.of(context).translate('update')),
                ),
                ElevatedButton(
                  onPressed: () {
                    _deleteOperation();
                  },
                  child: Text(AppLocalizations.of(context).translate('delete')),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => ReservationPage()),
                    );
                  },
                  child: Text(AppLocalizations.of(context).translate('return')),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  /// Widget for displaying the page of adding a new reservations.
  Widget _addReservationPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(AppLocalizations.of(context).translate('reservation_create_title'),
                style: const TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context).translate('prompt_reservation_date_selection'),
                  style: const TextStyle(color: Colors.blue)),
            ),
            ListTile(
              title: Text(_selectedDate != null
                  ? "${_selectedDate!.toLocal()}".split(' ')[0]
                  : AppLocalizations.of(context).translate('no_date_selected')),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate!,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context).translate('prompt_customer_selection'),
                  style: const TextStyle(color: Colors.blue)),
            ),
            DropdownButton<int>(
              isExpanded: true,
              value: _selectedCustomerId,
              hint: Text(AppLocalizations.of(context).translate('prompt_customer_selection')),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedCustomerId = newValue;
                  debugPrint('Selected Customer ID: $_selectedCustomerId');
                });
              },
              items: _customers.map((Customer customer) {
                return DropdownMenuItem<int>(
                  value: customer.id,
                  child: Text("${customer.firstname} ${customer.lastname}"),
                );
              }).toList(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context).translate('prompt_flight_selection'),
                  style: const TextStyle(color: Colors.blue)),
            ),
            DropdownButton<int>(
              isExpanded: true,
              value: _selectedFlightId,
              hint: Text(AppLocalizations.of(context).translate('prompt_flight_selection')),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedFlightId = newValue;
                });
              },
              items: _flights.map((Flight flight) {
                return DropdownMenuItem<int>(
                  value: flight.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.flightNumber + ": " + flight.departureCity + " to " + flight.destinationCity,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        flight.departureTime.toString().substring(11, 16) + " - " + flight.arrivalTime.toString().substring(11, 16),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return _flights.map<Widget>((Flight flight) {
                  if (flight.id == _selectedFlightId) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.flightNumber + ": " + flight.departureCity + " to " + flight.destinationCity,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            flight.departureTime.toString().substring(11, 16) + " - " + flight.arrivalTime.toString().substring(11, 16),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(AppLocalizations.of(context).translate('prompt_flight_selection')),
                    );
                  }
                }).toList();
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context).translate('prompt_notes_input'),
                  style: const TextStyle(color: Colors.blue)),
            ),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('prompt_notes_input'),
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            ElevatedButton(
              onPressed: () {
                bool isValid = true;
                if (_selectedCustomerId == null) {
                  _showAlertDialog(AppLocalizations.of(context).translate('prompt_customer_selection'));
                  isValid = false;
                }
                if (_selectedFlightId == null) {
                  _showAlertDialog(AppLocalizations.of(context).translate('prompt_flight_selection'));
                  isValid = false;
                }
                if (_selectedDate == null) {
                  _showAlertDialog(AppLocalizations.of(context).translate('prompt_reservation_date_selection'));
                  isValid = false;
                }
                if (!isValid) {
                  return; // If any validation failed, stop execution
                }
                _confirmSaveOperation();
              },
              child: Text(AppLocalizations.of(context).translate('save')),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget for displaying the page of updating the selected reservations.
  Widget _updateReservationPage() {
    if (_updateReservationChanged == false) {
      _reservationToUpdateId = _selectedReservation!.id;
      _selectedUpdateDate = _selectedReservation!.reservationDate;
      _selectedUpdateCustomerId = _selectedReservation!.customerId;
      _selectedUpdateFlightId = _selectedReservation!.flightId;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(AppLocalizations.of(context).translate('reservation_update_title'),
                style: const TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context).translate('prompt_reservation_date_selection'),
                  style: const TextStyle(color: Colors.blue)),
            ),
            ListTile(
              title: Text(_selectedUpdateDate != null
                  ? "${_selectedUpdateDate!.toLocal()}".split(' ')[0]
                  : AppLocalizations.of(context).translate('no_date_selected')),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedUpdateDate!,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                if (picked != null && picked != _selectedUpdateDate) {
                  setState(() {
                    _selectedUpdateDate = picked;
                  });
                }
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context).translate('prompt_customer_selection'),
                  style: const TextStyle(color: Colors.blue)),
            ),
            DropdownButton<int>(
              isExpanded: true,
              value: _selectedUpdateCustomerId,
              hint: Text(AppLocalizations.of(context).translate('prompt_customer_selection')),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedUpdateCustomerId = newValue;
                  _updateReservationChanged = true;
                });
              },
              items: [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text(AppLocalizations.of(context).translate('prompt_customer_selection')),
                ),
                ..._customers.map((Customer customer) {
                  return DropdownMenuItem<int>(
                    value: customer.id,
                    child: Text("${customer.firstname} ${customer.lastname}"),
                  );
                }).toList(),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context).translate('prompt_flight_selection'),
                  style: const TextStyle(color: Colors.blue)),
            ),
            DropdownButton<int>(
              isExpanded: true,
              value: _selectedUpdateFlightId,
              hint: Text(AppLocalizations.of(context).translate('prompt_flight_selection')),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedUpdateFlightId = newValue;
                  _updateReservationChanged = true;
                });
              },
              selectedItemBuilder: (BuildContext context) {
                return _flights.map<Widget>((Flight flight) {
                  if (flight.id == _selectedUpdateFlightId) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.flightNumber + ": " + flight.departureCity + " to " + flight.destinationCity,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            flight.departureTime.toString().substring(11, 16) + " - " + flight.arrivalTime.toString().substring(11, 16),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(AppLocalizations.of(context).translate('prompt_flight_selection')),
                    );
                  }
                }).toList();
              },
              items: _flights.map((Flight flight) {
                return DropdownMenuItem<int>(
                  value: flight.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.flightNumber + ": " + flight.departureCity + " to " + flight.destinationCity,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        flight.departureTime.toString().substring(11, 16) + " - " + flight.arrivalTime.toString().substring(11, 16),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context).translate('prompt_notes_input'),
                  style: const TextStyle(color: Colors.blue)),
            ),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('prompt_notes_input'),
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            ElevatedButton(
              onPressed: () {
                _confirmUpdateOperation();
              },
              child: Text(AppLocalizations.of(context).translate('update')),
            ),
          ],
        ),
      ),
    );
  }

  /// This widget builds the main layout for the reservation system application.
  /// It uses [MediaQuery] to determine the screen size and adjusts the layout
  /// accordingly to provide a responsive user interface.
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    /// Returns the responsive layout based on the current state of the application
    /// and the screen dimensions.
    Widget responsiveLayout() {
      if (!_isAddingNewReservation && !_isUpdatingReservation) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: _reservationList(),
              ),
              Expanded(
                flex: 1,
                child: _detailReservationPage(),
              ),
            ],
          );
        } else {
          if (_selectedReservation == null) {
            return _reservationList();
          } else {
            return _detailReservationPage();
          }
        }
      } else if (_isAddingNewReservation && !_isUpdatingReservation) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: _reservationList(),
              ),
              Expanded(
                flex: 1,
                child: _addReservationPage(),
              ),
            ],
          );
        } else {
          return _addReservationPage();
        }
      } else if (!_isAddingNewReservation && _isUpdatingReservation) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: _reservationList(),
              ),
              Expanded(
                flex: 1,
                child: _updateReservationPage(),
              ),
            ],
          );
        } else {
          if (_selectedReservation == null) {
            return Text(AppLocalizations.of(context).translate('no_selection'));
          } else {
            return _updateReservationPage();
          }
        }
      } else {
        return Text("");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('reservation_title')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: <Widget>[
          PopupMenuButton<Locale>(
            onSelected: (Locale locale) {
              MyApp.of(context)!.changeLanguage(locale);
            },
            icon: Icon(Icons.language),
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
      floatingActionButton: ((width > height) && (width > 720) || (width <= height && _selectedReservation == null)) &&
          !_isAddingNewReservation &&
          !_isUpdatingReservation
          ? FloatingActionButton(
        onPressed: _pressAddReservation,
        tooltip: AppLocalizations.of(context).translate('reservation_create_title'),
        child: const Icon(Icons.add),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Initiates the process of adding a new reservation.
  /// Sets the state to show the Add Reservation page.
  void _pressAddReservation() {
    setState(() {
      _isAddingNewReservation = true;
      _isUpdatingReservation = false;
    });
  }

  /// Handles the long press action on a reservation item.
  /// Displays a confirmation dialog to delete the selected reservation.
  ///
  /// [rowNum] is the index of the reservation in the list.
  void _longPressAction(int rowNum) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('prompt_confirm_delete')),
        content: Text(AppLocalizations.of(context).translate('delete_confirmation')),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              _toDelete(rowNum);
              Navigator.pop(context); // Close the dialog after deletion
            },
            child: const Text("Yes"),
          ),
          OutlinedButton(
            onPressed: _notToDelete,
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

  /// Deletes the reservation at the specified index.
  ///
  /// [rowNum] is the index of the reservation in the list.
  void _toDelete(int rowNum) {
    setState(() {
      _reservationDAO.deleteReservation(_reservations[rowNum]);
      _reservations.removeAt(rowNum);
    });
  }

  /// Closes the delete confirmation dialog without deleting the reservation.
  void _notToDelete() {
    Navigator.pop(context);
  }

  /// Displays the usage instructions for the application in a dialog.
  ///
  /// [context] is the BuildContext of the widget.
  void _showUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('Instructions')),
          content: Text(AppLocalizations.of(context).translate('instruction_detail')),
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

  /// Displays an alert dialog with a custom message.
  ///
  /// [message] is the content of the alert dialog.
  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('missing_information')),
          content: Text(message),
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

  /// Displays a confirmation dialog for saving a reservation.
  void _confirmSaveOperation() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('prompt_confirm_save_title')),
        content: Text(AppLocalizations.of(context).translate('prompt_confirm_save_info')),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              _saveReservation();
              Navigator.pop(context); // Close the dialog
            },
            child: Text(AppLocalizations.of(context).translate('OK')),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text(AppLocalizations.of(context).translate('No')),
          ),
        ],
      ),
    );
  }

  /// Saves a new reservation to the database and updates the state.
  void _saveReservation() {
    var notes = _notesController.text;
    var reservation = Reservation.create(
      customerId: _selectedCustomerId!,
      flightId: _selectedFlightId!,
      reservationDate: _selectedDate ?? DateTime.now(),
      notes: notes,
    );

    try {
      _reservationDAO.insertReservation(reservation).then((_) {
        setState(() {
          print("Reservation inserted successfully");
          _selectedCustomerId = null;
          _selectedFlightId = null;
          _notesController.text = "";
          _selectedReservation = reservation;
          _isAddingNewReservation = false;
          _isUpdatingReservation = false;
          _reservations.add(reservation);
          _clearDataFromSharedPreferences();
        });
      }).catchError((error) {
        print("Error inserting reservation: $error");
      });
    } catch (e) {
      print("Exception during insertion: $e");
    }
  }

  /// Initiates the process of updating an existing reservation.
  /// Sets the state to show the Update Reservation page.
  void _updateOperation() {
    setState(() {
      _isAddingNewReservation = false;
      _isUpdatingReservation = true;
    });
  }

  /// Displays a confirmation dialog for updating a reservation.
  void _confirmUpdateOperation() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('prompt_confirm_save_title')),
        content: Text(AppLocalizations.of(context).translate('prompt_confirm_save_info')),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              _updateReservation();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).translate('OK')),
          ),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _updateReservationChanged = false;
              });
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).translate('No')),
          ),
        ],
      ),
    );
  }

  /// Updates an existing reservation in the database and updates the state.
  void _updateReservation() {
    print("${_reservationToUpdateId},${_selectedCustomerId}, ${_selectedFlightId}");
    if (_reservationToUpdateId == null ||
        _selectedUpdateCustomerId == null ||
        _selectedUpdateFlightId == null ||
        _selectedUpdateDate == null) {
      String message = "";
      if (_selectedUpdateDate == null) {
        message += "Date is not selected; ";
      }
      if (_selectedUpdateCustomerId == null) {
        message += "Customer is not selected; ";
      }
      if (_selectedUpdateFlightId == null) {
        message += "Flight is not selected; ";
      }
      if (_reservationToUpdateId == null) {
        message += "Selected reservation is wrong;";
      }
      _showAlertDialog(message);
      return;
    }
    var notes = _notesController.text;
    var newReservation = Reservation(
      id: _reservationToUpdateId!,
      customerId: _selectedUpdateCustomerId!,
      flightId: _selectedUpdateFlightId!,
      reservationDate: _selectedUpdateDate!,
      notes: notes,
    );

    int index = _reservations.indexWhere((reservation) => reservation.id == _reservationToUpdateId);
    _reservationDAO.updateReservation(newReservation).then((value) {
      setState(() {
        if (index != -1) {
          _reservations[index] = newReservation;
        }
        _selectedUpdateCustomerId = null;
        _selectedUpdateFlightId = null;
        _notesController.text = "";
        _selectedReservation = newReservation;
        _isAddingNewReservation = false;
        _isUpdatingReservation = false;
        _updateReservationChanged = false;
      });
    });
  }

  /// Displays a confirmation dialog for deleting the currently selected reservation.
  void _deleteOperation() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('prompt_confirm_delete')),
        content: Text(AppLocalizations.of(context).translate('delete_confirmation')),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              _toDeleteInDetailPage();
            },
            child: Text(AppLocalizations.of(context).translate('OK')),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog after deletion
            },
            child: Text(AppLocalizations.of(context).translate('No')),
          ),
        ],
      ),
    );
  }

  /// Deletes the currently selected reservation from the database and updates the state.
  void _toDeleteInDetailPage() {
    _reservationDAO.deleteReservation(_selectedReservation!).then((_) {
      setState(() {
        _reservations.remove(_selectedReservation);
        _selectedReservation = null;
        _isAddingNewReservation = false;
        _isUpdatingReservation = false; // Update the state if needed
      });
      Navigator.pop(context);
    });
  }

  /// Clears the saved data from SharedPreferences.
  void _clearDataFromSharedPreferences() async {
    try {
      await _savedData.remove('addDate');
      await _savedData.remove('addCustomerId');
      await _savedData.remove('addFlightId');
      await _savedData.remove('addNotes');
      print('Data cleared from SharedPreferences');
    } catch (e) {
      print('Error clearing data from SharedPreferences: $e');
    }
  }
}

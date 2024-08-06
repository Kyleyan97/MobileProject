
import 'package:final_project/AirplaneList/AirplaneDAO.dart';
import 'package:final_project/CustomerList/CustomerDAO.dart';
import 'package:final_project/FlightList/FlightDAO.dart';
import 'package:final_project/Reservation/ReservationDAO.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import '../AirplaneList/Airplane.dart';
import '../Database.dart';
import '../AppLocalizations.dart';
import '../CustomerList/Customer.dart';
import '../FlightList/Flight.dart';
import '../main.dart';
import 'Reservation.dart';

/// A StatefulWidget for managing reservations.
class ReservationPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ReservationPageState();
  }
}

/// State class for [ReservationPage] that handles reservation data and UI.
class ReservationPageState extends State<ReservationPage> {
  /// EncryptedSharedPreferences instance for securely storing data.
  late EncryptedSharedPreferences savedData;

  /// Data Access Object for reservations.
  late ReservationDAO myReservationDAO;
  late CustomerDAO myCustomerDAO;
  late AirplaneDAO myAirplaneDAO;
  late FlightDAO myFlightDAO;

  /// List of reservations.
  List<Reservation> reservations = [];

  /// List of customers.
  List<Customer> customers = [];

  /// List of flights.
  List<Flight> flights = [];

  /// List of airplanes.
  List<Airplane> airplanes = [];

  /// Controller for managing scroll behavior.
  late ScrollController _scrollController;

  /// Currently selected reservation, if any.
  Reservation? selectedReservation = null;

  /// Flag to indicate if a new reservation is being added.
  bool isAddingNewReservation = false;

  /// Flag to indicate if a reservation is being updated.
  bool isUpdatingReservation = false;

  /// Controller for notes text field.
  late TextEditingController _notesController = TextEditingController();

  /// ID of the selected customer.
  int? _selectedCustomerId =  null; // 用于存储选中的客户ID

  /// ID of the selected flight.
  int? _selectedFlightId = null;

  /// Selected date for the reservation.
  DateTime? _selectedDate = DateTime.now(); // 用于存储选中的日期

  /// Reservation being updated.
  Reservation? updatedReservation;

  /// ID of the reservation being updated.
  int? _reservationToUpdateId;

  /// Date selected for the reservation update.
  DateTime? _selectedUpdateDate;

  /// ID of the customer selected for the reservation update.
  int? _selectedUpdateCustomerId;

  /// ID of the flight selected for the reservation update.
  int? _selectedUpdateFlightId;

  /// Flag to indicate if reservation data has changed during update.
  bool _updateReservationChanged = false;

  @override
  void initState(){
    super.initState();
    _scrollController = ScrollController();
    _loadData();
    initEncryptedSharedPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSnackBar(context);
    });
  }

  @override
  void dispose(){
    _scrollController.dispose();
    saveDataToSharedPreferences(); // 调用保存数据的方法
    super.dispose();
  }

  /// Initializes encrypted shared preferences for storing sensitive data.
  void initEncryptedSharedPreferences() async {
    savedData = EncryptedSharedPreferences();

    String? addDate;
    String? addCustomerId;
    String? addFlightId;
    String? addNotes;

    try {
      addDate = await savedData.getString('addDate');
    } catch (e) {
      print("addDate not found in SharedPreferences: $e");
    }

    try {
      addCustomerId = await savedData.getString('addCustomerId');
    } catch (e) {
      print("addCustomerId not found in SharedPreferences: $e");
    }

    try {
      addFlightId = await savedData.getString('addFlightId');
    } catch (e) {
      print("addFlightId not found in SharedPreferences: $e");
    }

    try {
      addNotes = await savedData.getString('addNotes');
    } catch (e) {
      print("addNotes not found in SharedPreferences: $e");
    }

    setState(() {
      if (addDate != null && addDate.isNotEmpty) {
        _selectedDate = DateTime.parse(addDate);
      }
      if (addCustomerId != null && addCustomerId.isNotEmpty) {
        _selectedCustomerId = int.tryParse(addCustomerId);
      }
      if (addFlightId != null && addFlightId.isNotEmpty) {
        _selectedFlightId = int.tryParse(addFlightId);
      }
      if (addNotes != null && addNotes.isNotEmpty) {
        _notesController.text = addNotes;
      }
    });
  }

  /// Saves current state data to shared preferences.
  void saveDataToSharedPreferences() async {
    try {
      if (_selectedDate != null) {
        await savedData.setString('addDate', _selectedDate!.toIso8601String());
      }
      if (_selectedCustomerId != null) {
        await savedData.setString('addCustomerId', _selectedCustomerId.toString());
      }
      if (_selectedFlightId != null) {
        await savedData.setString('addFlightId', _selectedFlightId.toString());
      }
      if (_notesController.value.text.isNotEmpty) {
        await savedData.setString('addNotes', _notesController.value.text);
      }
      print('Data saved to SharedPreferences');
    } catch (e) {
      print('Error saving data to SharedPreferences: $e');
    }
  }

  /// Reloads reservation data from the database.
  void _loadData() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    myReservationDAO = database.reservationDAO;
    myCustomerDAO = database.customerDAO;
    myAirplaneDAO = database.airplaneDAO;
    myFlightDAO = database.flightDAO;

    customers = await myCustomerDAO.getAllCustomers();
    airplanes = await myAirplaneDAO.findAllAirplanes();
    flights = await myFlightDAO.getAllFlights();

    List<Reservation> allReservations = await myReservationDAO.getAllReservation();
    setState(() {
      reservations.clear(); // 先清空列表
      reservations.addAll(allReservations);
    });

  }

  /// Shows a snack bar with a welcome message.
  void showSnackBar(BuildContext context) {
    var snackBar = SnackBar(
      content: Text(AppLocalizations.of(context).translate('welcome_to_reservation_list')),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  /// Loads dummy customer data.
  void _loadDummyCustomers(){
    customers = [
      Customer(
         1,
         'Guan',
        'Robin',
        '01 rue du XXX, Gatineau',
         DateTime(1990, 1, 1),
      ),
      Customer(
         2,
        'Sandy',
         'Liang',
         '02 rue du XXX, Gatineau',
       DateTime(1991, 1, 1),
      ),
      Customer(
         3,
        'Linda',
         'He',
        '03 rue du XXX, Gatineau',
         DateTime(1992, 1, 1),
      ),
    ];
  }

  /// Loads dummy flight data.
  void _loadDummyFlights(){
    flights = [
      Flight(101, 'AC001', 'Shenzhen', 'Beijing', DateTime(2024, 7, 7, 10, 30), DateTime(2024, 7, 7, 13, 30), 1),
      Flight(102, 'AC002', 'Shanghai', 'Beijing', DateTime(2024, 7, 8, 11, 00), DateTime(2024, 7, 8, 14, 00), 2),
      Flight(103, 'AC003', 'Guangzhou', 'Beijing', DateTime(2024, 7, 9, 12, 00), DateTime(2024, 7, 9, 15, 00), 3),
    ];
  }

  /// Loads dummy airplane data.
  void _loadDummyAirplanes(){
    airplanes = [
      Airplane(1, 'Boeing 737', 160, 870, 5800),
      Airplane(2, 'Airbus A320', 180, 828, 6100),
      Airplane(3, 'Boeing 777', 396, 905, 15700),
    ];
  }

  /// Widget for displaying the list of reservations.
  Widget ReservationList(){
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Scrollbar(
        controller: _scrollController,
        thickness: 8.0,
        radius: Radius.circular(10.0), // 可选: 设置滚动条的圆角
        thumbVisibility: false,
        child: reservations.isEmpty
            ? Center(
          child: Text(AppLocalizations.of(context).translate('empty_list')),
        )
            : ListView.builder(
          controller: _scrollController,
          itemCount: reservations.length,
          itemBuilder: (BuildContext context, int rowNum) {
            var reservation = reservations[rowNum];
            var customer = customers.firstWhere(
                  (customer) => customer.id == reservation.customerId,
              orElse: () => Customer(
                 -1,
                 'Unknown',
                'Unknown',
                 'Unknown Address',
                DateTime(1900, 1, 1),
              ),
            );

            var flight = flights.firstWhere(
                  (flight) => flight.id == reservation.flightId,
              orElse: () => Flight(-1, 'Unknown', 'Unknown City', 'Unknown City', DateTime(1900, 1, 1, 0, 0), DateTime(1900, 1, 1, 0, 0), -1),
            );

            var airplane = airplanes.firstWhere(
                  (airplane) => airplane.id == flight.airplaneId,
              orElse: () => Airplane(-1, 'Unknown', 0, 0, 0),
            );
            var formattedDate = reservation.reservationDate.toString()
                .substring(0, 10); // 截取前10个字符; // 格式化日期
            var formattedDepartTime = flight.departureTime.toString()
                .substring(11, 16);
            var formattedArrivalTime = flight.arrivalTime.toString()
                .substring(11, 16);

            return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedReservation = reservations[rowNum];
                  });
                },
                onLongPress: () {
                  longPressAction(rowNum);
                },
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: rowNum % 2 == 0
                            ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1)
                            : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2), // 设置背景颜色
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
                              const SizedBox(width: 5,),
                              Text(
                                "$formattedDate ${customer
                                    .firstname} ${customer.lastname} ${flight
                                    .flightNumber}",
                                style: const TextStyle(
                                  fontSize: 18, // Large font size
                                  color: Colors.black, // Black color
                                ),
                              ),
                            ],
                          ),

                          // Second line with smaller text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(width: 50,),
                              Text(
                                "${flight.departureCity} - ${flight
                                    .destinationCity}  $formattedDepartTime - $formattedArrivalTime",
                                style: const TextStyle(
                                  fontSize: 14, // Smaller font size
                                  color: Colors
                                      .grey, // Grey color for less emphasis
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    )
                )
            );
          },
        ),
      ),
    );
  }

  /// Widget for displaying the details of the selected reservations.
  Widget DetailReservationPage() {
    if (selectedReservation == null) {
      return Center(
        child: Text(AppLocalizations.of(context).translate('no_selection'),style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold,color: Colors.blue),),
      );
    } else {
      var selectedCustomer = customers.firstWhere(
            (customer) => customer.id == selectedReservation!.customerId,
        orElse: () =>Customer(
           -1,
         'Unknown',
           'Unknown',
          'Unknown Address',
           DateTime(1900, 1, 1),
        ),
      );

      var selectedFlight = flights.firstWhere(
            (flight) => flight.id == selectedReservation!.flightId,
        orElse: () => Flight(-1, 'Unknown', 'Unknown City', 'Unknown City', DateTime(1900, 1, 1, 0, 0), DateTime(1900, 1, 1, 0, 0), -1),
      );

      var selectedAirplane = airplanes.firstWhere(
            (airplane) => airplane.id == selectedFlight.airplaneId,
        orElse: () => Airplane(-1, 'Unknown', 0, 0, 0),
      );
      var formattedDate = selectedReservation!.reservationDate.toString()
          .substring(0, 10); // 截取前10个字符; // 格式化日期
      var formattedDepartTime = selectedFlight.departureTime.toString()
          .substring(11, 16);
      var formattedArrivalTime = selectedFlight.arrivalTime.toString()
          .substring(11, 16);
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context).translate('reservation_detail'),style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),),
            Expanded(
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(120.0),
                  1: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('customer'), style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),textAlign: TextAlign.left),
                      Text('${selectedCustomer.firstname} ${selectedCustomer.lastname}', style: const TextStyle(color: Colors.black, fontSize: 15),textAlign: TextAlign.left,),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('flight_date'), style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),textAlign: TextAlign.left),
                      Text('${formattedDate}', style: const TextStyle(color: Colors.black, fontSize: 15),textAlign: TextAlign.left),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('flight_number'), style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),textAlign: TextAlign.left),
                      Text('${selectedFlight.flightNumber}', style: const TextStyle(color: Colors.black, fontSize: 15),textAlign: TextAlign.left),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('departure_city'), style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),textAlign: TextAlign.left),
                      Text('${selectedFlight.departureCity}', style: const TextStyle(color: Colors.black, fontSize: 15),textAlign: TextAlign.left),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('destination_city'), style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),textAlign: TextAlign.left),
                      Text('${selectedFlight.destinationCity}', style: const TextStyle(color: Colors.black, fontSize: 15),textAlign: TextAlign.left),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('departure_time'), style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),textAlign: TextAlign.left),
                      Text('${formattedDepartTime}', style: const TextStyle(color: Colors.black, fontSize: 15),textAlign: TextAlign.left),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('arrival_time'), style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),textAlign: TextAlign.left),
                      Text('${formattedArrivalTime}', style: const TextStyle(color: Colors.black, fontSize: 15),textAlign: TextAlign.left),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(AppLocalizations.of(context).translate('airplane_type'), style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),textAlign: TextAlign.left),
                      Text('${selectedAirplane.type}', style: const TextStyle(color: Colors.black, fontSize: 15),textAlign: TextAlign.left),
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
                    updateOperation();
                  },
                  child: Text(AppLocalizations.of(context).translate('update')),
                ),
                ElevatedButton(
                  onPressed: () {
                    deleteOperation();
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
  Widget AddReservationPage(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child:
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(AppLocalizations.of(context).translate('reservation_create_title'),style: const TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold),),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context).translate('prompt_reservation_date_selection'),style: const TextStyle(color: Colors.blue)),
              ),
              ListTile(
                title: Text(_selectedDate != null ? "${_selectedDate!.toLocal()}".split(' ')[0] : AppLocalizations.of(context).translate('no_date_selected')),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate!, // Refer to step 1
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != _selectedDate)
                    setState(() {
                      _selectedDate = picked;
                    });
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context).translate('prompt_customer_selection'),style: const TextStyle(color: Colors.blue)),
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
                items: customers.map((Customer customer) {
                  return DropdownMenuItem<int>(
                    value: customer.id,
                    child: Text("${customer.firstname} ${customer.lastname}"),
                  );
                }).toList(),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context).translate('prompt_flight_selection'),style: const TextStyle(color: Colors.blue)),
              ),
              DropdownButton<int>(
                isExpanded: true,
                value: _selectedFlightId,
                hint: Text(AppLocalizations.of(context).translate('prompt_flight_selection')),
                onChanged: (int? newValue){
                  setState(() {
                    _selectedFlightId = newValue;
                  });
                },
                items: flights.map((Flight flight) {
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
                  return flights.map<Widget>((Flight flight) {
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
                child: Text(AppLocalizations.of(context).translate('prompt_notes_input'),style: const TextStyle(color: Colors.blue)),
              ),

              // Notes输入框
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate('prompt_notes_input'),
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              ElevatedButton(
                onPressed: (){
                  bool isValid = true;
                  if(_selectedCustomerId == null){
                    _showAlertDialog(AppLocalizations.of(context).translate('prompt_customer_selection'));
                    isValid = false;
                  }
                  if(_selectedFlightId == null){
                    _showAlertDialog(AppLocalizations.of(context).translate('prompt_flight_selection'));
                    isValid = false;
                  }
                  if(_selectedDate == null){
                    _showAlertDialog(AppLocalizations.of(context).translate('prompt_reservation_date_selection'));
                    isValid = false;
                  }
                  if (!isValid) {
                    return; // If any validation failed, stop execution
                  }
                  confirmSaveOperation();
                },
                child: Text(AppLocalizations.of(context).translate('save')),
              ),
            ],
          ),
      ),
    );
  }

  /// Widget for displaying the page of updating the selected reservations.
  Widget UpdateReservationPage(){
    if(_updateReservationChanged == false){
      _reservationToUpdateId = selectedReservation!.id;
      _selectedUpdateDate = selectedReservation!.reservationDate;
      _selectedUpdateCustomerId = selectedReservation!.customerId;
      _selectedUpdateFlightId = selectedReservation!.flightId;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(AppLocalizations.of(context).translate('reservation_update_title'),style: const TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold),),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context).translate('prompt_reservation_date_selection'),style: const TextStyle(color: Colors.blue)),
            ),
            ListTile(
              title: Text(_selectedUpdateDate != null ? "${_selectedUpdateDate!.toLocal()}".split(' ')[0] : AppLocalizations.of(context).translate('no_date_selected')),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedUpdateDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                if (picked != null && picked != _selectedUpdateDate)
                  setState(() {
                    _selectedUpdateDate = picked;
                  });
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context).translate('prompt_customer_selection'),style: const TextStyle(color: Colors.blue)),
            ),

            DropdownButton<int>(
              isExpanded: true,
              value: _selectedUpdateCustomerId,
              hint: Text(AppLocalizations.of(context).translate('prompt_customer_selection')),
              onChanged: (int? newValue){
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
                ...customers.map((Customer customer) {
                  return DropdownMenuItem<int>(
                    value: customer.id,
                    child: Text("${customer.firstname} ${customer.lastname}"),
                  );
                }).toList(),
              ],
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context).translate('prompt_flight_selection'),style: const TextStyle(color: Colors.blue)),
            ),
            DropdownButton<int>(
              isExpanded: true,
              value: _selectedUpdateFlightId,
              hint: Text(AppLocalizations.of(context).translate('prompt_flight_selection')),
              onChanged: (int? newValue){
                setState(() {
                  _selectedUpdateFlightId = newValue;
                  _updateReservationChanged = true;
                });
              },
              selectedItemBuilder: (BuildContext context) {
                return flights.map<Widget>((Flight flight) {
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
              items: flights.map((Flight flight) {
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
              child: Text(AppLocalizations.of(context).translate('prompt_notes_input'),style: const TextStyle(color: Colors.blue)),
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
              onPressed: (){
                confirmUpdateOperation();
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
    Widget responsiveLayout(){
      if(!isAddingNewReservation && !isUpdatingReservation) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: ReservationList(),
              ),
              Expanded(
                flex: 1,
                child: DetailReservationPage(),
              )
            ],
          );
        } else {
          if (selectedReservation == null) {
            return ReservationList();
          } else {
            return DetailReservationPage();
          }
        }
      } else if(isAddingNewReservation && !isUpdatingReservation){
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: ReservationList(),
              ),
              Expanded(
                flex: 1,
                child: AddReservationPage(),
              )
            ],
          );
        } else {
          return AddReservationPage();
        }
      } else if(!isAddingNewReservation && isUpdatingReservation){
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: ReservationList(),
              ),
              Expanded(
                flex: 1,
                child: UpdateReservationPage(),
              )
            ],
          );
        }else{
          if(selectedReservation == null){
            return Text(AppLocalizations.of(context).translate('no_selection'));
          }else{
            return UpdateReservationPage();
          }
        }

      } else{
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
      floatingActionButton:((width > height) && (width > 720)  || (width <= height && selectedReservation == null)) && !isAddingNewReservation && !isUpdatingReservation
      ?
      FloatingActionButton(
        onPressed: pressAddReservation,
        tooltip: AppLocalizations.of(context).translate('reservation_create_title'),
        child: const Icon(Icons.add),
      )
      :
      null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Center the FAB// Center the FAB
    );
  }

  /// Initiates the process of adding a new reservation.
  /// Sets the state to show the Add Reservation page.
  void pressAddReservation(){
    setState(() {
      isAddingNewReservation = true;
      isUpdatingReservation = false;
    });
  }

  /// Handles the long press action on a reservation item.
  /// Displays a confirmation dialog to delete the selected reservation.
  ///
  /// [rowNum] is the index of the reservation in the list.
  void longPressAction(int rowNum){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(AppLocalizations.of(context).translate('prompt_confirm_delete')),
          content: Text(AppLocalizations.of(context).translate('delete_confirmation')),
          actions: <Widget>[
            ElevatedButton(
              onPressed: (){
                toDelete(rowNum);
                Navigator.pop(context); // Close the dialog after deletion
              },
              child: const Text("Yes"),
            ),
            OutlinedButton(
              onPressed: notToDelete,
              child: const Text("No"),
            )
          ],
        )
    );

  }

  /// Deletes the reservation at the specified index.
  ///
  /// [rowNum] is the index of the reservation in the list.
  void toDelete (int rowNum){
    setState(() {
      myReservationDAO.deleteReservation(reservations[rowNum]);
      reservations.removeAt(rowNum);
    });
  }

  /// Closes the delete confirmation dialog without deleting the reservation.
  void notToDelete (){
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
  void confirmSaveOperation(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(AppLocalizations.of(context).translate('prompt_confirm_save_title')),
          content: Text(AppLocalizations.of(context).translate('prompt_confirm_save_info')),
          actions: <Widget>[
            ElevatedButton(
              onPressed: (){
                saveReservation();
                Navigator.pop(context); // 关闭对话框
              },
              child: Text(AppLocalizations.of(context).translate('OK')),
            ),
            OutlinedButton(
              onPressed: (){
                Navigator.pop(context); // Close the dialog after deletion
              },
              child: Text(AppLocalizations.of(context).translate('No')),
            )
          ],
        )
    );
  }

  /// Saves a new reservation to the database and updates the state.
  void saveReservation(){
    var notes = _notesController.value.text;
    var reservation = Reservation(
        Reservation.ID++,
        _selectedCustomerId!,
        _selectedFlightId!,
        _selectedDate ?? DateTime.now(),
        notes
    );

    try {
      myReservationDAO.insertReservation(reservation).then((_) {
        setState(() {
          print("Reservation inserted successfully");
          _selectedCustomerId = null;
          _selectedFlightId = null;
          _notesController.text = "";
          selectedReservation = reservation;
          isAddingNewReservation = false;
          isUpdatingReservation  = false;
          reservations.add(reservation);
          clearDataFromSharedPreferences();
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
  void updateOperation() {
    setState(() {
      isAddingNewReservation = false;
      isUpdatingReservation = true;
    });
  }

  /// Displays a confirmation dialog for updating a reservation.
  void confirmUpdateOperation(){
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('prompt_confirm_save_title')),
        content: Text(AppLocalizations.of(context).translate('prompt_confirm_save_info')),
        actions: <Widget>[
          ElevatedButton(
            onPressed: (){
              updateReservation();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).translate('OK')),
          ),
          OutlinedButton(
            onPressed: (){
              setState(() {
                _updateReservationChanged = false;
              });
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).translate('No')),
          )
        ],
      ),
    );
  }

  /// Updates an existing reservation in the database and updates the state.
  void updateReservation(){
    print("${_reservationToUpdateId},${_selectedCustomerId}, ${_selectedFlightId}");
    if (_reservationToUpdateId == null || _selectedUpdateCustomerId == null || _selectedUpdateFlightId == null || _selectedUpdateDate == null) {
      String message = "";
      if(_selectedUpdateDate == null){
        message += "Date is not selected; ";
      }
      if(_selectedUpdateCustomerId == null){
        message += "Customer is not selected; ";
      }
      if(_selectedUpdateFlightId == null){
        message += "Flight is not selected; ";
      }

      if(_reservationToUpdateId == null){
        message += "Selected reservation is wrong;";
      }
      _showAlertDialog(message);
    }
    var notes = _notesController.value.text;
    var newReservation = Reservation(
      _reservationToUpdateId!,
      _selectedUpdateCustomerId!,
      _selectedUpdateFlightId!,
      _selectedUpdateDate!,
      notes,
    );

    int index = reservations.indexWhere((reservation) => reservation.id == _reservationToUpdateId);
    myReservationDAO.updateReservation(newReservation).then((value){

      setState(() {
        if (index != -1) {
          reservations[index] = newReservation;
        }
        _selectedUpdateCustomerId = null;
        _selectedUpdateFlightId = null;
        _notesController.text = "";
        selectedReservation = newReservation;
        isAddingNewReservation = false;
        isUpdatingReservation  = false;
        _updateReservationChanged = false;

      });
    });
  }

  /// Displays a confirmation dialog for deleting the currently selected reservation.
  void deleteOperation(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(AppLocalizations.of(context).translate('prompt_confirm_delete')),
          content: Text(AppLocalizations.of(context).translate('delete_confirmation')),
          actions: <Widget>[
            ElevatedButton(
              onPressed: (){
                toDeleteInDetailPage();
              },
              child: Text(AppLocalizations.of(context).translate('OK')),
            ),
            OutlinedButton(
              onPressed: (){
                Navigator.pop(context); // Close the dialog after deletion
              },
              child: Text(AppLocalizations.of(context).translate('No')),
            ),
          ],
        )
    );
  }

  /// Deletes the currently selected reservation from the database and updates the state.
  void toDeleteInDetailPage(){
    myReservationDAO.deleteReservation(selectedReservation!).then((_) {
      setState(() {
        reservations.remove(selectedReservation);
        selectedReservation = null;
        isAddingNewReservation = false;
        isUpdatingReservation  = false;// Update the state if needed
      });
      Navigator.pop(context);
    });
  }

  /// Clears the saved data from SharedPreferences.
  void clearDataFromSharedPreferences() async {
    try {
      await savedData.remove('addDate');
      await savedData.remove('addCustomerId');
      await savedData.remove('addFlightId');
      await savedData.remove('addNotes');
      print('Data cleared from SharedPreferences');
    } catch (e) {
      print('Error clearing data from SharedPreferences: $e');
    }
  }
}
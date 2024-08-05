
// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'AirplaneList/Airplane.dart';
import 'AirplaneList/AirplaneDAO.dart';
import 'CustomerList/Customer.dart';
import 'CustomerList/CustomerDAO.dart';
import 'DateTimeConverter.dart';
import 'FlightList/Flight.dart';
import 'FlightList/FlightDAO.dart';
import 'Reservation/Reservation.dart';
import 'Reservation/ReservationDAO.dart';

part 'AppDatabase.g.dart'; // the generated code will be there

/// A database that holds the entities of the application.
///
/// This class uses Floor for database operations and includes entities such as
/// Customer, Airplane, Flight, and Reservation. It provides access to DAOs for
/// interacting with these entities.
@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [Customer, Airplane, Flight, Reservation])
abstract class AppDatabase extends FloorDatabase {
  /// A getter for the [CustomerDAO].
  ///
  /// This DAO provides methods for performing CRUD operations on [Customer] entities.
  CustomerDAO get customerDAO;

  /// A getter for the [AirplaneDAO].
  ///
  /// This DAO provides methods for performing CRUD operations on [Airplane] entities.
  AirplaneDAO get airplaneDAO;

  /// A getter for the [FlightDAO].
  ///
  /// This DAO provides methods for performing CRUD operations on [Flight] entities.
  FlightDAO get flightDAO;

  /// A getter for the [ReservationDAO].
  ///
  /// This DAO provides methods for performing CRUD operations on [Reservation] entities.
  ReservationDAO get reservationDAO;
}
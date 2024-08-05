import 'package:floor/floor.dart';

import '../DateTimeConverter.dart';

/// Represents a flight entity in the database.
@entity
class Flight {
  /// Static variable to keep track of the current highest ID.
  static int ID = 1;

  /// Primary key of the flight.
  @primaryKey
  final int id;

  /// Flight number.
  final String flightNumber;

  /// Departure city of the flight.
  final String departureCity;

  /// Destination city of the flight.
  final String destinationCity;

  /// Departure time of the flight, converted using [DateTimeConverter].
  @TypeConverters([DateTimeConverter])
  final DateTime departureTime;

  /// Arrival time of the flight, converted using [DateTimeConverter].
  @TypeConverters([DateTimeConverter])
  final DateTime arrivalTime;

  /// ID of the airplane associated with the flight.
  final int airplaneId;

  /// Constructor for creating a [Flight] instance.
  ///
  /// The constructor also updates the static [ID] variable to ensure unique IDs.
  ///
  /// - [id]: The ID of the flight.
  /// - [flightNumber]: The flight number.
  /// - [departureCity]: The departure city of the flight.
  /// - [destinationCity]: The destination city of the flight.
  /// - [departureTime]: The departure time of the flight.
  /// - [arrivalTime]: The arrival time of the flight.
  /// - [airplaneId]: The ID of the airplane associated with the flight.
  Flight(this.id, this.flightNumber, this.departureCity, this.destinationCity, this.departureTime,this.arrivalTime,this.airplaneId){
    if(id >= ID){
      ID = id + 1;
    }
  }
}
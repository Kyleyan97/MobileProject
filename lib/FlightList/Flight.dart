import 'package:final_project/DateTimeConverter.dart';
import 'package:floor/floor.dart';
import '../DateTimeConverter.dart';

/// Represents a database Flight entity.
@entity
class Flight {

  /// A static field of current ID.
  static int currentId = 1;

  /// Flight entity primary key.
  @primaryKey
  final int id;

  ///flight number, departure city, destination city, departure time, arrival time and airplane Id.

  final String flightNumber;
  final String departureCity;
  final String destinationCity;

  @TypeConverters([DateTimeConverter])
  final DateTime departureTime;

  @TypeConverters([DateTimeConverter])
  final DateTime arrivalTime;

  final int airplaneId;

  /// Constructs a Flight entity with the given parameters.
  /// The constructor also updates the [currentId] if the [id] is greater or equal to it.
  Flight
      (this.id,
      this.flightNumber,
      this.departureCity,
      this.destinationCity,
      this.departureTime,
      this.arrivalTime,
      this.airplaneId){
    if(id >= currentId){
      currentId += id;
    }
  }
}
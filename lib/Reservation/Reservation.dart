

import 'package:floor/floor.dart';

import '../DateTimeConverter.dart';

/// Represents a reservation entity in the database.
@entity
class Reservation {
  /// Static variable to keep track of the last used ID.
  static int ID = 1;

  /// The unique identifier for the reservation.
  @primaryKey
  int id;

  /// The ID of the customer that has the reservation.
  int customerId;

  /// The ID of the flight that has been reserved.
  int flightId;

  /// The date and time of the reservation.
  ///
  /// This uses a custom [DateTimeConverter] to store date and time in the database.
  @TypeConverters([DateTimeConverter])
  DateTime reservationDate;

  /// Additional notes or information about the reservation.
  String notes;

  /// Updates the reservation with new details.
  ///
  /// This method allows updating the reservation's customer ID, flight ID, reservation date, and notes.
  /*
  void updateReservation(int customerId, int flightId, DateTime reservationDate, String notes) {
    this.customerId = customerId;
    this.flightId = flightId;
    this.reservationDate = reservationDate;
    this.notes = notes;
  }

   */

  /// Constructor for creating a new [Reservation] instance.
  ///
  /// Automatically increments the static [ID] if the provided [id] is equal to or greater than the current [ID].
  /// This ensures that each [Reservation] has a unique identifier.
  Reservation(this.id, this.customerId, this.flightId, this.reservationDate, this.notes){
    if(id >= ID){
      ID = id + 1;
    }
  }
}
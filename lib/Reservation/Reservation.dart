import 'package:floor/floor.dart';

import '../DateTimeConverter.dart';

/// Represents a reservation entity in the database.
@entity
class Reservation {
  /// Static variable to keep track of the last used ID.
  static int _lastId = 1;

  /// The unique identifier for the reservation.
  @primaryKey
  final int id;

  /// The ID of the customer that has the reservation.
  final int customerId;

  /// The ID of the flight that has been reserved.
  final int flightId;

  /// The date and time of the reservation.
  ///
  /// This uses a custom [DateTimeConverter] to store date and time in the database.
  @TypeConverters([DateTimeConverter])
  final DateTime reservationDate;

  /// Additional notes or information about the reservation.
  final String notes;

  /// Constructor for creating a new [Reservation] instance.
  ///
  /// Automatically increments the static [ID] if the provided [id] is equal to or greater than the current [ID].
  /// This ensures that each [Reservation] has a unique identifier.
  Reservation({
    required this.id,
    required this.customerId,
    required this.flightId,
    required this.reservationDate,
    required this.notes,
  }) {
    if (id >= _lastId) {
      _lastId = id + 1;
    }
  }

  /// Factory constructor to create a new [Reservation] instance with a unique ID.
  factory Reservation.create({
    required int customerId,
    required int flightId,
    required DateTime reservationDate,
    required String notes,
  }) {
    return Reservation(
      id: _lastId++,
      customerId: customerId,
      flightId: flightId,
      reservationDate: reservationDate,
      notes: notes,
    );
  }
}

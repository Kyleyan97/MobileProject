import 'package:floor/floor.dart';

import 'Reservation.dart';

/// A Data Access Object (DAO) for managing CRUD operations for [Reservation] entities.
@dao
abstract class ReservationDAO {
  /// Retrieves all reservations from the database.
  ///
  /// Returns a list of [Reservation] objects.
  @Query('SELECT * FROM Reservation')
  Future<List<Reservation>> getAllReservations();

  /// Finds a reservation by its [id].
  ///
  /// Returns a single [Reservation] object if found, otherwise null.
  @Query('SELECT * FROM Reservation WHERE id = :id')
  Future<Reservation?> findReservationById(int id);

  /// Inserts a new [Reservation] into the database.
  ///
  /// Takes a [Reservation] object as a parameter.
  @insert
  Future<void> insertReservation(Reservation reservation);

  /// Updates an existing [Reservation] in the database.
  ///
  /// Takes a [Reservation] object as a parameter.
  @update
  Future<void> updateReservation(Reservation reservation);

  /// Deletes a [Reservation] from the database.
  ///
  /// Takes a [Reservation] object as a parameter.
  /// Returns the number of rows affected.
  @delete
  Future<int> deleteReservation(Reservation reservation);
}

import 'package:floor/floor.dart';
import 'Flight.dart';

/// A Data Access Object (DAO) for managing CRUD operations for [Flight] entities.
@dao
abstract class FlightDAO {
  /// Retrieves all flights from the database.
  ///
  /// Returns a list of [Flight] objects.
  @Query('SELECT * FROM Flight')
  Future<List<Flight>> getAllFlights();

  /// Finds a flight by its [id].
  ///
  /// Returns a single [Flight] object if found, otherwise null.
  @Query('SELECT * FROM Flight WHERE id = :id')
  Future<Flight?> findFlightById(int id);

  /// Inserts a new [Flight] into the database.
  ///
  /// Takes a [Flight] object as a parameter.
  @insert
  Future<void> insertFlight(Flight flight);

  /// Updates an existing [Flight] in the database.
  ///
  /// Takes a [Flight] object as a parameter.
  @update
  Future<void> updateFlight(Flight flight);

  /// Deletes a [Flight] from the database.
  ///
  /// Takes a [Flight] object as a parameter.
  /// Returns the number of rows affected.
  @delete
  Future<int> deleteFlight(Flight flight);
}
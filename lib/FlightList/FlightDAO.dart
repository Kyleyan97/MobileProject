import 'package:floor/floor.dart';
import 'Flight.dart';

/// DAO for accessing and managing [Flight] entities in the database.
@dao
abstract class FlightDAO {
  /// Fetches all [Flight] records from the database.
  ///
  /// Returns a [Future] containing a list of all flights.
  @Query('SELECT * FROM Flight')
  Future<List<Flight>> getAllFlights();

  /// Retrieves a [Flight] by its unique identifier.
  ///
  /// Parameters:
  /// - [flightId]: The unique identifier of the flight to be retrieved.
  ///
  /// Returns a [Future] containing the flight with the given id, or null if not found.
  @Query('SELECT * FROM Flight WHERE id = :flightId')
  Future<Flight?> findFlightById(int flightId);

  /// Adds a new [Flight] record to the database.
  ///
  /// Parameters:
  /// - [newFlight]: The flight object to be inserted.
  ///
  /// Returns a [Future] indicating the completion of the operation.
  @insert
  Future<void> insertFlight(Flight newFlight);

  /// Modifies an existing [Flight] record in the database.
  ///
  /// Parameters:
  /// - [updatedFlight]: The flight object containing updated data.
  ///
  /// Returns a [Future] indicating the completion of the operation.
  @update
  Future<void> updateFlight(Flight updatedFlight);

  /// Removes a [Flight] record from the database.
  ///
  /// Parameters:
  /// - [flightToRemove]: The flight object to be deleted.
  ///
  /// Returns a [Future] containing the number of rows deleted.
  @delete
  Future<int> deleteFlight(Flight flightToRemove);
}
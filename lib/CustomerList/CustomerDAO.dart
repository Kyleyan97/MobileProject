import 'package:floor/floor.dart';
import 'Customer.dart';

/// A Data Access Object (DAO) for managing CRUD operations for [Customer] entities.
@dao
abstract class CustomerDAO {
  /// Retrieves all customers from the database.
  /// Returns a list of [Customer] objects.
  @Query('SELECT * FROM Customer')
  Future<List<Customer>> getAllCustomers();

  /// Finds a customer by its [id].
  /// Returns a single [Customer] object if found, otherwise null.
  @Query('SELECT * FROM Customer WHERE id = :id')
  Future<Customer?> findCustomer(int id);

  /// Inserts a new [Customer] into the database.
  /// Takes a [Customer] object as a parameter.
  @insert
  Future<void> insertCustomer(Customer customer);

  /// Updates an existing [Customer] in the database.
  /// Takes a [Customer] object as a parameter.
  @update
  Future<void> updateCustomer(Customer customer);

  /// Deletes a [Customer] from the database。
  /// Takes a [Customer] object as a parameter.
  /// Returns the number of rows affected.
  @delete
  Future<int> deleteCustomer(Customer customer);
}

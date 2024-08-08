import 'package:final_project/DateTimeConverter.dart';
import 'package:floor/floor.dart';

/// Represents a customer with personal information.
///
/// This class defines a customer entity with attributes such as their name, address,
/// and birthday. It includes a static `ID` counter that ensures each customer gets a unique
/// identifier when created.
///
/// The [DateTimeConverter] is used to convert the [birthday] field to and from
/// the database format.
///
/// Attributes:
/// - `id`: The unique identifier for the customer, used as the primary key.
/// - `lastname`: The last name of the customer.
/// - `firstname`: The first name of the customer.
/// - `address`: The address of the customer.
/// - `birthday`: The birthdate of the customer.
///

@entity
class Customer {
  /// A static counter to generate unique IDs for customers.
  /// This ensures that each new customer gets a unique identifier.

  static int ID = 1;
  /// The unique identifier for the customer. This field is the primary key.
  @primaryKey
  final int id;

  /// The last name of the customer.
  final String lastname;

  /// The first name of the customer.
  final String firstname;

  /// The address of the customer.
  final String address;

  /// The birthdate of the customer.
  @TypeConverters([DateTimeConverter])
  final DateTime birthday;

  /// Creates a new instance of the [Customer] class.
  ///
  /// The [id] is used as a unique identifier for the customer and must be provided.
  /// The [lastname], [firstname], [address], and [birthday] are also required.
  ///
  /// If the provided [id] is greater than or equal to the current static `ID`,
  /// the static `ID` is updated to ensure the next customer gets a unique ID.
  Customer(this.id, this.lastname, this.firstname, this.address, this.birthday) {
    if (id >= ID) {
      ID = id + 1;
    }
  }
}

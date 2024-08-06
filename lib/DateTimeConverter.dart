import 'package:floor/floor.dart';

/// A [TypeConverter] for converting [DateTime] objects to and from ISO8601 [String] representations.
///
/// This converter is used to store [DateTime] objects in the database as [String]s and retrieve them back as [DateTime] objects.
class DateTimeConverter extends TypeConverter<DateTime, String> {
  /// Decodes a [String] from the database to a [DateTime] object.
  ///
  /// The [databaseValue] is expected to be in ISO8601 format.
  /// Returns a [DateTime] object.
  @override
  DateTime decode(String databaseValue) {
    return DateTime.parse(databaseValue);
  }

  /// Encodes a [DateTime] object to a [String] in ISO8601 format for storing in the database.
  ///
  /// The [value] is the [DateTime] object to be encoded.
  /// Returns a [String] representation of the [DateTime] object.
  @override
  String encode(DateTime value) {
    return value.toIso8601String();
  }

  @override
  DateTime fromSql(String fromDb) {
    // Convert from SQLite string to DateTime
    return DateTime.parse(fromDb);
  }

  @override
  String toSql(DateTime value) {
    // Convert from DateTime to SQLite string
    return value.toIso8601String();
  }


}
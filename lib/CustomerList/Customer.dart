import 'package:floor/floor.dart';

import '../DateTimeConverter.dart';


@entity
class Customer {
  static int ID = 1;

  @primaryKey
  final int id;
  final String lastname;
  final String firstname;
  final String address;

  @TypeConverters([DateTimeConverter])
  final DateTime birthday;

  Customer(this.id, this.lastname, this.firstname, this.address, this.birthday){
    if(id >= ID){
      ID = id + 1;
    }
  }
}
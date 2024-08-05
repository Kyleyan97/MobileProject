import 'package:floor/floor.dart';

@entity
class Airplane {
  static int ID = 1;

  @primaryKey
  final int id;
  final String type;
  final int maxNumberOfPassenger;
  final int maxSpeed;
  final int maxDistance;

  Airplane(this.id, this.type, this.maxNumberOfPassenger, this.maxSpeed, this.maxDistance){
    if(id >= ID){
      ID = id + 1;
    }
  }
}
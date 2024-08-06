import 'package:floor/floor.dart';
import 'Airplane.dart';
///airplane related database operation
@dao
abstract class AirplaneDAO {

  @Query('SELECT * FROM Airplane')
  Future<List<Airplane>> findAllAirplanes();

  @Query('SELECT * FROM Airplane WHERE id = :id')
  Future<Airplane?> findAirplane(int id);

  @insert
  Future<void> insertAirplane (Airplane airplane);

  @update
  Future<void> updateAirplane (Airplane airplane);

  @delete
  Future<void> deleteAirplane (Airplane airplane);
}
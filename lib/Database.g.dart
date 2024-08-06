// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CustomerDAO? _customerDAOInstance;

  AirplaneDAO? _airplaneDAOInstance;

  FlightDAO? _flightDAOInstance;

  ReservationDAO? _reservationDAOInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Customer` (`id` INTEGER NOT NULL, `lastname` TEXT NOT NULL, `firstname` TEXT NOT NULL, `address` TEXT NOT NULL, `birthday` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Airplane` (`id` INTEGER NOT NULL, `type` TEXT NOT NULL, `maxNumberOfPassenger` INTEGER NOT NULL, `maxSpeed` INTEGER NOT NULL, `maxDistance` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Flight` (`id` INTEGER NOT NULL, `flightNumber` TEXT NOT NULL, `departureCity` TEXT NOT NULL, `destinationCity` TEXT NOT NULL, `departureTime` TEXT NOT NULL, `arrivalTime` TEXT NOT NULL, `airplaneId` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Reservation` (`id` INTEGER NOT NULL, `customerId` INTEGER NOT NULL, `flightId` INTEGER NOT NULL, `reservationDate` TEXT NOT NULL, `notes` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CustomerDAO get customerDAO {
    return _customerDAOInstance ??= _$CustomerDAO(database, changeListener);
  }

  @override
  AirplaneDAO get airplaneDAO {
    return _airplaneDAOInstance ??= _$AirplaneDAO(database, changeListener);
  }

  @override
  FlightDAO get flightDAO {
    return _flightDAOInstance ??= _$FlightDAO(database, changeListener);
  }

  @override
  ReservationDAO get reservationDAO {
    return _reservationDAOInstance ??=
        _$ReservationDAO(database, changeListener);
  }
}

class _$CustomerDAO extends CustomerDAO {
  _$CustomerDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _customerInsertionAdapter = InsertionAdapter(
            database,
            'Customer',
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'lastname': item.lastname,
                  'firstname': item.firstname,
                  'address': item.address,
                  'birthday': _dateTimeConverter.encode(item.birthday)
                }),
        _customerUpdateAdapter = UpdateAdapter(
            database,
            'Customer',
            ['id'],
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'lastname': item.lastname,
                  'firstname': item.firstname,
                  'address': item.address,
                  'birthday': _dateTimeConverter.encode(item.birthday)
                }),
        _customerDeletionAdapter = DeletionAdapter(
            database,
            'Customer',
            ['id'],
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'lastname': item.lastname,
                  'firstname': item.firstname,
                  'address': item.address,
                  'birthday': _dateTimeConverter.encode(item.birthday)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Customer> _customerInsertionAdapter;

  final UpdateAdapter<Customer> _customerUpdateAdapter;

  final DeletionAdapter<Customer> _customerDeletionAdapter;

  @override
  Future<List<Customer>> getAllCustomers() async {
    return _queryAdapter.queryList('SELECT * FROM Customer',
        mapper: (Map<String, Object?> row) => Customer(
            row['id'] as int,
            row['lastname'] as String,
            row['firstname'] as String,
            row['address'] as String,
            _dateTimeConverter.decode(row['birthday'] as String)));
  }

  @override
  Future<Customer?> findCustomer(int id) async {
    return _queryAdapter.query('SELECT * FROM Customer WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Customer(
            row['id'] as int,
            row['lastname'] as String,
            row['firstname'] as String,
            row['address'] as String,
            _dateTimeConverter.decode(row['birthday'] as String)),
        arguments: [id]);
  }

  @override
  Future<void> insertCustomer(Customer customer) async {
    await _customerInsertionAdapter.insert(customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await _customerUpdateAdapter.update(customer, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteCustomer(Customer customer) {
    return _customerDeletionAdapter.deleteAndReturnChangedRows(customer);
  }
}

class _$AirplaneDAO extends AirplaneDAO {
  _$AirplaneDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _airplaneInsertionAdapter = InsertionAdapter(
            database,
            'Airplane',
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'maxNumberOfPassenger': item.maxNumberOfPassenger,
                  'maxSpeed': item.maxSpeed,
                  'maxDistance': item.maxDistance
                }),
        _airplaneUpdateAdapter = UpdateAdapter(
            database,
            'Airplane',
            ['id'],
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'maxNumberOfPassenger': item.maxNumberOfPassenger,
                  'maxSpeed': item.maxSpeed,
                  'maxDistance': item.maxDistance
                }),
        _airplaneDeletionAdapter = DeletionAdapter(
            database,
            'Airplane',
            ['id'],
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'maxNumberOfPassenger': item.maxNumberOfPassenger,
                  'maxSpeed': item.maxSpeed,
                  'maxDistance': item.maxDistance
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Airplane> _airplaneInsertionAdapter;

  final UpdateAdapter<Airplane> _airplaneUpdateAdapter;

  final DeletionAdapter<Airplane> _airplaneDeletionAdapter;

  @override
  Future<List<Airplane>> findAllAirplanes() async {
    return _queryAdapter.queryList('SELECT * FROM Airplane',
        mapper: (Map<String, Object?> row) => Airplane(
            row['id'] as int,
            row['type'] as String,
            row['maxNumberOfPassenger'] as int,
            row['maxSpeed'] as int,
            row['maxDistance'] as int));
  }

  @override
  Future<Airplane?> findAirplane(int id) async {
    return _queryAdapter.query('SELECT * FROM Airplane WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Airplane(
            row['id'] as int,
            row['type'] as String,
            row['maxNumberOfPassenger'] as int,
            row['maxSpeed'] as int,
            row['maxDistance'] as int),
        arguments: [id]);
  }

  @override
  Future<void> insertAirplane(Airplane airplane) async {
    await _airplaneInsertionAdapter.insert(airplane, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAirplane(Airplane airplane) async {
    await _airplaneUpdateAdapter.update(airplane, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAirplane(Airplane airplane) async {
    await _airplaneDeletionAdapter.delete(airplane);
  }
}

class _$FlightDAO extends FlightDAO {
  _$FlightDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _flightInsertionAdapter = InsertionAdapter(
            database,
            'Flight',
            (Flight item) => <String, Object?>{
                  'id': item.id,
                  'flightNumber': item.flightNumber,
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity,
                  'departureTime':
                      _dateTimeConverter.encode(item.departureTime),
                  'arrivalTime': _dateTimeConverter.encode(item.arrivalTime),
                  'airplaneId': item.airplaneId
                }),
        _flightUpdateAdapter = UpdateAdapter(
            database,
            'Flight',
            ['id'],
            (Flight item) => <String, Object?>{
                  'id': item.id,
                  'flightNumber': item.flightNumber,
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity,
                  'departureTime':
                      _dateTimeConverter.encode(item.departureTime),
                  'arrivalTime': _dateTimeConverter.encode(item.arrivalTime),
                  'airplaneId': item.airplaneId
                }),
        _flightDeletionAdapter = DeletionAdapter(
            database,
            'Flight',
            ['id'],
            (Flight item) => <String, Object?>{
                  'id': item.id,
                  'flightNumber': item.flightNumber,
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity,
                  'departureTime':
                      _dateTimeConverter.encode(item.departureTime),
                  'arrivalTime': _dateTimeConverter.encode(item.arrivalTime),
                  'airplaneId': item.airplaneId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Flight> _flightInsertionAdapter;

  final UpdateAdapter<Flight> _flightUpdateAdapter;

  final DeletionAdapter<Flight> _flightDeletionAdapter;

  @override
  Future<List<Flight>> getAllFlights() async {
    return _queryAdapter.queryList('SELECT * FROM Flight',
        mapper: (Map<String, Object?> row) => Flight(
            row['id'] as int,
            row['flightNumber'] as String,
            row['departureCity'] as String,
            row['destinationCity'] as String,
            _dateTimeConverter.decode(row['departureTime'] as String),
            _dateTimeConverter.decode(row['arrivalTime'] as String),
            row['airplaneId'] as int));
  }

  @override
  Future<Flight?> findFlightById(int flightId) async {
    return _queryAdapter.query('SELECT * FROM Flight WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Flight(
            row['id'] as int,
            row['flightNumber'] as String,
            row['departureCity'] as String,
            row['destinationCity'] as String,
            _dateTimeConverter.decode(row['departureTime'] as String),
            _dateTimeConverter.decode(row['arrivalTime'] as String),
            row['airplaneId'] as int),
        arguments: [flightId]);
  }

  @override
  Future<void> insertFlight(Flight newFlight) async {
    await _flightInsertionAdapter.insert(newFlight, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateFlight(Flight updatedFlight) async {
    await _flightUpdateAdapter.update(updatedFlight, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteFlight(Flight flightToRemove) {
    return _flightDeletionAdapter.deleteAndReturnChangedRows(flightToRemove);
  }
}

class _$ReservationDAO extends ReservationDAO {
  _$ReservationDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _reservationInsertionAdapter = InsertionAdapter(
            database,
            'Reservation',
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'reservationDate':
                      _dateTimeConverter.encode(item.reservationDate),
                  'notes': item.notes
                }),
        _reservationUpdateAdapter = UpdateAdapter(
            database,
            'Reservation',
            ['id'],
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'reservationDate':
                      _dateTimeConverter.encode(item.reservationDate),
                  'notes': item.notes
                }),
        _reservationDeletionAdapter = DeletionAdapter(
            database,
            'Reservation',
            ['id'],
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'reservationDate':
                      _dateTimeConverter.encode(item.reservationDate),
                  'notes': item.notes
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Reservation> _reservationInsertionAdapter;

  final UpdateAdapter<Reservation> _reservationUpdateAdapter;

  final DeletionAdapter<Reservation> _reservationDeletionAdapter;

  @override
  Future<List<Reservation>> getAllReservations() async {
    return _queryAdapter.queryList('SELECT * FROM Reservation',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as int,
            customerId: row['customerId'] as int,
            flightId: row['flightId'] as int,
            reservationDate:
                _dateTimeConverter.decode(row['reservationDate'] as String),
            notes: row['notes'] as String));
  }

  @override
  Future<Reservation?> findReservationById(int id) async {
    return _queryAdapter.query('SELECT * FROM Reservation WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as int,
            customerId: row['customerId'] as int,
            flightId: row['flightId'] as int,
            reservationDate:
                _dateTimeConverter.decode(row['reservationDate'] as String),
            notes: row['notes'] as String),
        arguments: [id]);
  }

  @override
  Future<void> insertReservation(Reservation reservation) async {
    await _reservationInsertionAdapter.insert(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateReservation(Reservation reservation) async {
    await _reservationUpdateAdapter.update(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteReservation(Reservation reservation) {
    return _reservationDeletionAdapter.deleteAndReturnChangedRows(reservation);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();

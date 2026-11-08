import '../models/fuel_entry.dart';
import 'app_database.dart';

class FuelRepository {
  FuelRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> createFuelEntry(FuelEntry entry) {
    return _database.createFuelEntry(entry);
  }

  Future<List<FuelEntry>> getFuelEntries({int? vehicleId}) {
    return _database.getFuelEntries(vehicleId: vehicleId);
  }

  Future<FuelEntry?> getFuelEntryById(int id) {
    return _database.getFuelEntryById(id);
  }

  Future<int> updateFuelEntry(FuelEntry entry) {
    return _database.updateFuelEntry(entry);
  }

  Future<int> deleteFuelEntry(int id) {
    return _database.deleteFuelEntry(id);
  }
}

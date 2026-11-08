 
import '../models/vehicle.dart';
import 'app_database.dart';

class VehicleRepository {
  VehicleRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> createVehicle(Vehicle vehicle) {
    return _database.createVehicle(vehicle);
  }

  Future<List<Vehicle>> getAllVehicles() {
    return _database.getAllVehicles();
  }

  Future<Vehicle?> getVehicleById(int id) {
    return _database.getVehicleById(id);
  }

  Future<int> updateVehicle(Vehicle vehicle) {
    return _database.updateVehicle(vehicle);
  }

  Future<int> deleteVehicle(int id) {
    return _database.deleteVehicle(id);
  }
} 
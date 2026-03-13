import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/vehicle_repository.dart';
import '../models/vehicle_model.dart';

@LazySingleton(as: VehicleRepository)
class VehicleRepositoryImpl implements VehicleRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  VehicleRepositoryImpl(this._firestore, this._firebaseAuth);

  @override
  Future<void> addVehicle(VehicleModel vehicle) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception("User not authenticated");

    final vehicleWithUserId = VehicleModel(
      id: vehicle.id,
      name: vehicle.name,
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      userId: userId,
    );

    var box = Hive.isBoxOpen('vehicles')
        ? Hive.box<VehicleModel>('vehicles')
        : await Hive.openBox<VehicleModel>('vehicles');

    await box.put(vehicleWithUserId.id, vehicleWithUserId);

    await _firestore
        .collection('vehicles')
        .doc(vehicleWithUserId.id)
        .set(vehicleWithUserId.toJson());
  }

  @override
  Future<void> updateVehicle(VehicleModel vehicle) async {
    var box = Hive.isBoxOpen('vehicles')
        ? Hive.box<VehicleModel>('vehicles')
        : await Hive.openBox<VehicleModel>('vehicles');

    await box.put(vehicle.id, vehicle);

    await _firestore.collection('vehicles').doc(vehicle.id).update(vehicle.toJson());
  }

  @override
  Future<void> deleteVehicle(String id) async {
    var box = Hive.isBoxOpen('vehicles')
        ? Hive.box<VehicleModel>('vehicles')
        : await Hive.openBox<VehicleModel>('vehicles');

    await box.delete(id);

    await _firestore.collection('vehicles').doc(id).delete();
  }

  @override
  Stream<List<VehicleModel>> getVehiclesStream() {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('vehicles')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => VehicleModel.fromJson(doc.data())).toList();
    });
  }
}

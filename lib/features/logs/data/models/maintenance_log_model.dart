import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:json_annotation/json_annotation.dart';

part 'maintenance_log_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable(explicitToJson: true)
class MaintenanceLogModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime date;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double cost;

  @HiveField(4)
  final String note;

  @HiveField(5)
  final String? photoPath;

  @HiveField(7)
  final int? odometer;

  @HiveField(8)
  final String userId;

  @HiveField(9)
  final String? vehicleId;

  @HiveField(10)
  final String? currency;

  MaintenanceLogModel({
    required this.id,
    required this.date,
    required this.category,
    required this.cost,
    required this.note,
    required this.userId,
    this.photoPath,
    this.odometer,
    this.vehicleId,
    this.currency,
  });

  factory MaintenanceLogModel.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$MaintenanceLogModelToJson(this);

  static DateTime _fromJson(Timestamp timestamp) => timestamp.toDate();

  static Timestamp _toJson(DateTime date) => Timestamp.fromDate(date);
}

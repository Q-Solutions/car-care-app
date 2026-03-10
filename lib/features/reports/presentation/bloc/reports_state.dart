import 'package:equatable/equatable.dart';
import '../../../logs/data/models/fuel_log_model.dart';
import '../../../logs/data/models/maintenance_log_model.dart';

enum ReportsStatus { initial, loading, loaded, error }

class ReportsState extends Equatable {
  final ReportsStatus status;
  final List<FuelLogModel> fuelLogs;
  final List<MaintenanceLogModel> maintenanceLogs;
  final String? errorMessage;

  const ReportsState({
    this.status = ReportsStatus.initial,
    this.fuelLogs = const [],
    this.maintenanceLogs = const [],
    this.errorMessage,
  });

  ReportsState copyWith({
    ReportsStatus? status,
    List<FuelLogModel>? fuelLogs,
    List<MaintenanceLogModel>? maintenanceLogs,
    String? errorMessage,
  }) {
    return ReportsState(
      status: status ?? this.status,
      fuelLogs: fuelLogs ?? this.fuelLogs,
      maintenanceLogs: maintenanceLogs ?? this.maintenanceLogs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, fuelLogs, maintenanceLogs, errorMessage];
}

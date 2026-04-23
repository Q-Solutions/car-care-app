import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../logs/domain/repositories/log_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

@injectable
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final LogRepository _logRepository;

  ReportsBloc(this._logRepository) : super(const ReportsState()) {
    on<LoadReports>(_onLoadReports);
  }

  Future<void> _onLoadReports(LoadReports event, Emitter<ReportsState> emit) async {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final fuelLogs = await _logRepository.getAllFuelLogs();
      final maintenanceLogs = await _logRepository.getMaintenanceLogs();
      emit(state.copyWith(
        status: ReportsStatus.loaded,
        fuelLogs: fuelLogs,
        maintenanceLogs: maintenanceLogs,
      ));
    } catch (e) {
      emit(state.copyWith(status: ReportsStatus.error, errorMessage: e.toString()));
    }
  }
}

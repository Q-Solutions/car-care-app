import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:carlog/features/vehicles/data/models/vehicle_model.dart';
import 'package:carlog/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:carlog/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

void main() {
  late VehicleBloc vehicleBloc;
  late MockVehicleRepository mockVehicleRepository;

  setUp(() {
    mockVehicleRepository = MockVehicleRepository();
    vehicleBloc = VehicleBloc(mockVehicleRepository);
  });

  tearDown(() {
    vehicleBloc.close();
  });

  final tVehicles = [
    VehicleModel(id: '1', name: 'Car 1', make: 'Toyota', model: 'Corolla', year: 2020),
    VehicleModel(id: '2', name: 'Car 2', make: 'Honda', model: 'Civic', year: 2021),
  ];

  group('VehicleBloc', () {
    test('initial state is correct', () {
      expect(vehicleBloc.state, const VehicleState());
    });

    blocTest<VehicleBloc, VehicleState>(
      'subscribes to vehicle stream when LoadVehicles is added',
      build: () {
        when(() => mockVehicleRepository.getVehiclesStream())
            .thenAnswer((_) => Stream.value(tVehicles));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(LoadVehicles()),
      expect: () => [
        const VehicleState(status: VehicleStatus.loading),
        VehicleState(
          status: VehicleStatus.loaded,
          vehicles: tVehicles,
          selectedVehicle: tVehicles.first,
        ),
      ],
      verify: (_) {
        verify(() => mockVehicleRepository.getVehiclesStream()).called(1);
      },
    );

    blocTest<VehicleBloc, VehicleState>(
      'updates vehicles and selected vehicle when VehiclesUpdated is added',
      build: () => vehicleBloc,
      act: (bloc) => bloc.add(VehiclesUpdated(tVehicles)),
      expect: () => [
        VehicleState(
          status: VehicleStatus.loaded,
          vehicles: tVehicles,
          selectedVehicle: tVehicles.first,
        ),
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'selects a specific vehicle when SelectVehicle is added',
      build: () => vehicleBloc,
      act: (bloc) {
        bloc.add(VehiclesUpdated(tVehicles));
        bloc.add(SelectVehicle(tVehicles[1]));
      },
      skip: 1,
      expect: () => [
        VehicleState(
          status: VehicleStatus.loaded,
          vehicles: tVehicles,
          selectedVehicle: tVehicles[1],
        ),
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [error] when DeleteVehicle fails',
      build: () {
        when(() => mockVehicleRepository.deleteVehicle(any()))
            .thenThrow(Exception('Delete failed'));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(DeleteVehicle('1')),
      expect: () => [
        const VehicleState(status: VehicleStatus.loading),
        const VehicleState(status: VehicleStatus.error),
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'calls deleteVehicle on repository when DeleteVehicle is added',
      build: () {
        when(() => mockVehicleRepository.deleteVehicle(any()))
            .thenAnswer((_) async => {});
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(DeleteVehicle('1')),
      expect: () => [
        const VehicleState(status: VehicleStatus.loading),
        const VehicleState(status: VehicleStatus.loaded),
      ],
      verify: (_) {
        verify(() => mockVehicleRepository.deleteVehicle('1')).called(1);
      },
    );
  });
}

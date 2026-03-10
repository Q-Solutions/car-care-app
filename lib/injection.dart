import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import 'features/logs/domain/repositories/log_repository.dart';
import 'features/logs/presentation/bloc/expense_log_bloc.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies() {
  // Register external dependencies before init
  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }
  if (!getIt.isRegistered<GoogleSignIn>()) {
    getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  }

  getIt.init();

  // Dependencies that are missing the @injectable annotation
  if (!getIt.isRegistered<ExpenseLogBloc>()) {
    getIt.registerFactory(() => ExpenseLogBloc(getIt<LogRepository>()));
  }
}

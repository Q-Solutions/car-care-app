import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies({String? environment}) {
  // Default to prod environment if not specified
  final env = environment ?? 'prod';
  getIt.init(environment: env);

  // Dependencies that are missing the @injectable annotation
}

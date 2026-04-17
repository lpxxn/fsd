// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'services.dart' as _i453;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt $initGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i453.ClickCounter>(() => _i453.ClickCounter());
    gh.factory<_i453.Greeter>(
      () => _i453.CasualGreeter(),
      instanceName: 'casual',
    );
    gh.factory<_i453.Greeter>(
      () => _i453.PoliteGreeter(),
      instanceName: 'polite',
    );
    gh.lazySingleton<_i453.HelloBot>(
      () => _i453.HelloBot(
        gh<_i453.Greeter>(instanceName: 'polite'),
        gh<_i453.ClickCounter>(),
      ),
    );
    return this;
  }
}

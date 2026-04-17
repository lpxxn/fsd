// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_09_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 第 9 章 codegen：本文件即是对第 3 / 4 / 7 章手写 Provider 的 codegen 版本。
/// 构建前请运行：
///   dart run build_runner build --delete-conflicting-outputs
// ---- 对照第 3 章 CounterNotifier ----

@ProviderFor(CounterCg)
final counterCgProvider = CounterCgProvider._();

/// 第 9 章 codegen：本文件即是对第 3 / 4 / 7 章手写 Provider 的 codegen 版本。
/// 构建前请运行：
///   dart run build_runner build --delete-conflicting-outputs
// ---- 对照第 3 章 CounterNotifier ----
final class CounterCgProvider extends $NotifierProvider<CounterCg, int> {
  /// 第 9 章 codegen：本文件即是对第 3 / 4 / 7 章手写 Provider 的 codegen 版本。
  /// 构建前请运行：
  ///   dart run build_runner build --delete-conflicting-outputs
  // ---- 对照第 3 章 CounterNotifier ----
  CounterCgProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'counterCgProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$counterCgHash();

  @$internal
  @override
  CounterCg create() => CounterCg();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$counterCgHash() => r'b1244d272aa0ab6aa84107e27d23eff7a9a235d6';

/// 第 9 章 codegen：本文件即是对第 3 / 4 / 7 章手写 Provider 的 codegen 版本。
/// 构建前请运行：
///   dart run build_runner build --delete-conflicting-outputs
// ---- 对照第 3 章 CounterNotifier ----

abstract class _$CounterCg extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(quoteCg)
final quoteCgProvider = QuoteCgProvider._();

final class QuoteCgProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  QuoteCgProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quoteCgProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quoteCgHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return quoteCg(ref);
  }
}

String _$quoteCgHash() => r'41d09c49a0d47ea8c83daf7411cff797f9825d61';

@ProviderFor(weatherCg)
final weatherCgProvider = WeatherCgFamily._();

final class WeatherCgProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  WeatherCgProvider._({
    required WeatherCgFamily super.from,
    required ({String city, String unit}) super.argument,
  }) : super(
         retry: null,
         name: r'weatherCgProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weatherCgHash();

  @override
  String toString() {
    return r'weatherCgProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as ({String city, String unit});
    return weatherCg(ref, city: argument.city, unit: argument.unit);
  }

  @override
  bool operator ==(Object other) {
    return other is WeatherCgProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weatherCgHash() => r'94cac0ace1d491ac67456412f39a8a0e25933979';

final class WeatherCgFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<String>,
          ({String city, String unit})
        > {
  WeatherCgFamily._()
    : super(
        retry: null,
        name: r'weatherCgProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WeatherCgProvider call({required String city, required String unit}) =>
      WeatherCgProvider._(argument: (city: city, unit: unit), from: this);

  @override
  String toString() => r'weatherCgProvider';
}

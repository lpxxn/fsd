// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 同步, 无参数 — 生成一个 `Provider<String>`。

@ProviderFor(greeting)
final greetingProvider = GreetingProvider._();

/// 同步, 无参数 — 生成一个 `Provider<String>`。

final class GreetingProvider extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// 同步, 无参数 — 生成一个 `Provider<String>`。
  GreetingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'greetingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$greetingHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return greeting(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$greetingHash() => r'804205a24c9fe93b26e8b6c463e27f635177d766';

/// 带参数 (family) — 生成 `xxxProvider(key)`。

@ProviderFor(doubled)
final doubledProvider = DoubledFamily._();

/// 带参数 (family) — 生成 `xxxProvider(key)`。

final class DoubledProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// 带参数 (family) — 生成 `xxxProvider(key)`。
  DoubledProvider._({
    required DoubledFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'doubledProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$doubledHash();

  @override
  String toString() {
    return r'doubledProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as int;
    return doubled(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DoubledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$doubledHash() => r'fe024e7932d38d972a4805ed623737a484b0bbf2';

/// 带参数 (family) — 生成 `xxxProvider(key)`。

final class DoubledFamily extends $Family
    with $FunctionalFamilyOverride<int, int> {
  DoubledFamily._()
    : super(
        retry: null,
        name: r'doubledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 带参数 (family) — 生成 `xxxProvider(key)`。

  DoubledProvider call(int value) =>
      DoubledProvider._(argument: value, from: this);

  @override
  String toString() => r'doubledProvider';
}

/// 异步 (Future) — 生成 `FutureProvider<int>`。

@ProviderFor(randomNumber)
final randomNumberProvider = RandomNumberProvider._();

/// 异步 (Future) — 生成 `FutureProvider<int>`。

final class RandomNumberProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// 异步 (Future) — 生成 `FutureProvider<int>`。
  RandomNumberProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'randomNumberProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$randomNumberHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return randomNumber(ref);
  }
}

String _$randomNumberHash() => r'e80aa67b1b12ab36f50140ad68618255e49f8781';

/// Notifier 类 — 生成 `NotifierProvider<CounterNotifier, int>`。

@ProviderFor(Counter)
final counterProvider = CounterProvider._();

/// Notifier 类 — 生成 `NotifierProvider<CounterNotifier, int>`。
final class CounterProvider extends $NotifierProvider<Counter, int> {
  /// Notifier 类 — 生成 `NotifierProvider<CounterNotifier, int>`。
  CounterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'counterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$counterHash();

  @$internal
  @override
  Counter create() => Counter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$counterHash() => r'e8eb012fd27833cc64562f0bc36d2c7e87249a48';

/// Notifier 类 — 生成 `NotifierProvider<CounterNotifier, int>`。

abstract class _$Counter extends $Notifier<int> {
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

/// keepAlive — 生成的 Provider 在没订阅时也不销毁 (对应 .autoDispose 反义)。

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// keepAlive — 生成的 Provider 在没订阅时也不销毁 (对应 .autoDispose 反义)。

final class AppVersionProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// keepAlive — 生成的 Provider 在没订阅时也不销毁 (对应 .autoDispose 反义)。
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return appVersion(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$appVersionHash() => r'ccf9bfcf8a69edc6fa496772d7dfca1dcb1c44b6';

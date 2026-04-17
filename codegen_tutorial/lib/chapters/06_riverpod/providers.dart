import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// 同步, 无参数 — 生成一个 `Provider<String>`。
@riverpod
String greeting(Ref ref) => 'Hello, @riverpod!';

/// 带参数 (family) — 生成 `xxxProvider(key)`。
@riverpod
int doubled(Ref ref, int value) => value * 2;

/// 异步 (Future) — 生成 `FutureProvider<int>`。
@riverpod
Future<int> randomNumber(Ref ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return DateTime.now().millisecondsSinceEpoch % 1000;
}

/// Notifier 类 — 生成 `NotifierProvider<CounterNotifier, int>`。
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

/// keepAlive — 生成的 Provider 在没订阅时也不销毁 (对应 .autoDispose 反义)。
@Riverpod(keepAlive: true)
String appVersion(Ref ref) => '1.0.0';

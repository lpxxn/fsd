# 第 6 章 riverpod_generator: @riverpod 生成了什么

> 本章和 `riverpod_tutorial/` 第 9 章是配套的: 那边讲"如何用", 这边专注"生成的代码里到底有什么"。

## 一张对照表

| 手写 | 生成 (加 `@riverpod`) |
|------|----------------------|
| `final greetingProvider = Provider<String>((ref) => 'Hello');` | `@riverpod String greeting(Ref ref) => 'Hello';` |
| `final doubledProvider = Provider.family<int, int>((ref, v) => v * 2);` | `@riverpod int doubled(Ref ref, int value) => value * 2;` |
| `final randomProvider = FutureProvider<int>((ref) async => ...);` | `@riverpod Future<int> randomNumber(Ref ref) async => ...;` |
| `final counterNotifierProvider = NotifierProvider<CounterNotifier, int>(CounterNotifier.new);` | `@riverpod class Counter extends _$Counter { @override int build() => 0; }` |

规则总结:

1. **看返回类型**: `Future<T>` → FutureProvider, `Stream<T>` → StreamProvider, 同步 → Provider。
2. **看函数/类**: 函数 → 普通 Provider; 类继承 `_$Xxx` → Notifier / AsyncNotifier。
3. **看参数**: 第一个是 `Ref` (固定), 其余参数 → 自动加 `family`。
4. **看 @Riverpod(keepAlive: true)**: 不加就是 autoDispose。

## 看看生成文件里具体有什么

跑 `dart run build_runner build` 后, `providers.g.dart` 会出现。挑几段关键的看:

### 同步 provider

```dart
// providers.dart
@riverpod
String greeting(Ref ref) => 'Hello, @riverpod!';
```

```dart
// providers.g.dart (节选)
final greetingProvider = AutoDisposeProvider<String>.internal(
  greeting,
  name: r'greetingProvider',
  dependencies: null,
  allTransitiveDependencies: null,
  debugGetCreateSourceHash: kReleaseMode ? null : _$greetingHash,
);

typedef GreetingRef = AutoDisposeProviderRef<String>;
```

**每个生成的 Provider 都带一个 hash**: 这样在"热重载改了 Provider 定义"时, Riverpod 能发现 hash 变了, 自动把旧状态丢掉。这是手写 Provider 绝对不会考虑的细节, codegen 帮你免费处理了。

### 带参数的 family

```dart
// providers.dart
@riverpod
int doubled(Ref ref, int value) => value * 2;
```

```dart
// providers.g.dart (节选)
final doubledProvider = DoubledFamily(_SystemHash.combine(0, r'doubledProvider'.hashCode));

class DoubledFamily extends Family<int> {
  DoubledFamily(int hash) : super(...);

  DoubledProvider call(int value) {
    return DoubledProvider._(value);
  }
  ...
}
```

注意使用方式从 `ref.watch(doubledProvider(5))` 变成 `ref.watch(doubledProvider(5))` — 是的, 完全一样。好处是 IDE 能自动补全参数名和类型, 改参数时编译器会揪出所有用点。

### Notifier

```dart
// providers.dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  void increment() => state++;
}
```

```dart
// providers.g.dart (节选)
final counterProvider = AutoDisposeNotifierProvider<Counter, int>.internal(
  Counter.new,
  name: r'counterProvider',
  ...
);

typedef _$Counter = AutoDisposeNotifier<int>;
```

神奇之处: `_$Counter` 是动态生成的 mixin/base class, 提供 `state` getter/setter, 还有 `ref` / `state.updateShouldNotify` 等基础设施。你继承它, 就什么都有了。

### keepAlive

```dart
@Riverpod(keepAlive: true)
String appVersion(Ref ref) => '1.0.0';
```

生成的类名就没有 `AutoDispose` 前缀:

```dart
final appVersionProvider = Provider<String>.internal(appVersion, ...);
```

## `build.yaml` 选项 (可选)

```yaml
targets:
  $default:
    builders:
      riverpod_generator:
        options:
          provider_name_suffix: "Provider"
          provider_family_name_suffix: "Provider"
```

改完后, 例如可以让 `greeting()` 的 Provider 叫 `greetingPod` 而不是 `greetingProvider`。本工程用默认。

## 踩坑

1. **别手滑把 `Ref` 参数去掉**: 不是 Dart 规则, 是 riverpod_generator 的要求, 它要靠它识别。
2. **Notifier 类里的字段不能是 non-final instance field**: state 才是状态容器, 想放额外数据要放私有字段并在 `build()` 里初始化。
3. **改 autoDispose 与否时, 整个 Provider 类型变了**, 使用点可能需要跟着修, codegen 会立刻让你感知到。
4. **`riverpod_lint` / `custom_lint` 目前和 Riverpod 3.x 有兼容问题**, 本工程不启用, 等生态跟进。

## 练习

1. 在 `providers.dart` 新增一个 `@riverpod Stream<int> ticks(Ref ref)` 返回 `Stream.periodic(const Duration(seconds: 1), (i) => i)`, 看生成的 `providers.g.dart` 里多了什么。
2. 把 `counter` 的 `@riverpod` 改成 `@Riverpod(keepAlive: true)`, 对比生成代码前后的差异。
3. 对照 `riverpod_tutorial/` 第 9 章, 理解"手动 NotifierProvider" 和 "@riverpod class" 的等价关系。

# 第 9 章 代码生成 `@riverpod`

## 为什么要 codegen

手写 Provider 要自己选：
- `Provider` / `FutureProvider` / `StreamProvider` / `NotifierProvider` / `AsyncNotifierProvider` / `StreamNotifierProvider`
- `.family` / `.autoDispose` / 两者组合...

写错了泛型或忘了加 `.autoDispose.family` 都得重写。

**`@riverpod` 让编译器帮你选**：根据函数/类的签名推断出应该用哪种 Provider。

## 基本流程

1. 在你的 Dart 文件顶部加：`import 'package:riverpod_annotation/riverpod_annotation.dart';`
2. 加 `part 'xxx.g.dart';`
3. 用 `@riverpod` 标注函数或类
4. 跑 `dart run build_runner build --delete-conflicting-outputs` 生成 `xxx.g.dart`
5. 用生成的 Provider 变量

开发期推荐 watch 模式：`dart run build_runner watch --delete-conflicting-outputs`

## 函数写法：映射到 xxxProvider（或 FutureProvider）

```dart
// counter.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter.g.dart';

@riverpod
String greeting(Ref ref) => 'Hello!';
// → 生成 greetingProvider : Provider<String>

@riverpod
Future<User> user(Ref ref, {required String id}) async {
  final http = ref.watch(httpClientProvider);
  return http.getUser(id);
}
// → 生成 userProvider : FutureProvider.family<User, ({String id})>
// 调用: ref.watch(userProvider(id: 'abc'))

@riverpod
Stream<int> tick(Ref ref) =>
    Stream.periodic(const Duration(seconds: 1), (i) => i);
// → 生成 tickProvider : StreamProvider<int>
```

**规则**：
- 返回普通类型 → `Provider`
- 返回 `Future<T>` → `FutureProvider`
- 返回 `Stream<T>` → `StreamProvider`
- 有额外参数（非 `Ref`） → 自动变成 `.family`，参数自动组装成 Record

**默认全是 `autoDispose`**！如果不想 autoDispose：

```dart
@Riverpod(keepAlive: true)
String appConfig(Ref ref) => 'prod';
```

## 类写法：映射到 NotifierProvider / AsyncNotifierProvider

### 同步可变

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}
// → 生成 counterProvider : NotifierProvider<Counter, int>
```

对照手写版（第 3 章）：

```dart
// 手写
class CounterNotifier extends Notifier<int> {
  @override int build() => 0;
  void increment() => state++;
}
final counterProvider =
    NotifierProvider<CounterNotifier, int>(CounterNotifier.new);
```

差别仅仅是：
- `extends Notifier<int>` → `extends _$Counter`（泛型信息编译期生成）
- 不需要手写那一行 `final xxxProvider = NotifierProvider<..>(..)`

### 异步可变

```dart
@riverpod
class Todos extends _$Todos {
  @override
  Future<List<Todo>> build() async => await _api.fetch();

  Future<void> add(String title) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final t = await _api.create(title);
      return [...?state.value, t];
    });
  }
}
// → 生成 todosProvider : AsyncNotifierProvider<Todos, List<Todo>>
```

### Stream + 可变

```dart
@riverpod
class Chat extends _$Chat {
  @override
  Stream<List<Message>> build() async* { ... }

  void sendLocal(Message m) {
    state = AsyncData([...?state.value, m]);
  }
}
// → 生成 chatProvider : StreamNotifierProvider<Chat, List<Message>>
```

### 带参数（family）

```dart
@riverpod
class Post extends _$Post {
  @override
  Future<PostModel> build(String id) async => await _api.getPost(id);

  Future<void> edit(String newTitle) async {
    state = await AsyncValue.guard(() async {
      await _api.update(id: arg, title: newTitle); // arg 是 String
      return state.value!.copyWith(title: newTitle);
    });
  }
}
// → 生成 postProvider(id: String) : AsyncNotifierProviderFamily<Post, PostModel, String>
// 调用: ref.watch(postProvider('p-1'))
```

**关键**：codegen 把 `build` 的参数（除 `ref` 外）识别成 family 的参数，在类内通过 `arg` 访问（或多参数时通过 Record 访问）。

## 对照表

| 手写 | codegen |
|-----|---------|
| `final xProvider = Provider<T>((ref) => ...)` | `@riverpod T x(Ref ref) => ...` |
| `Provider.autoDispose` | `@riverpod`（默认就是 autoDispose） |
| `Provider` (keepAlive) | `@Riverpod(keepAlive: true)` |
| `FutureProvider<T>((ref) async => ...)` | `@riverpod Future<T> x(Ref ref) async => ...` |
| `StreamProvider<T>((ref) => ...)` | `@riverpod Stream<T> x(Ref ref) => ...` |
| `NotifierProvider<X, T>(X.new)` | `@riverpod class X extends _$X { @override T build() => ... }` |
| `AsyncNotifierProvider<X, T>(X.new)` | `@riverpod class X extends _$X { @override Future<T> build() => ... }` |
| `StreamNotifierProvider<X, T>(X.new)` | `@riverpod class X extends _$X { @override Stream<T> build() => ... }` |
| `Provider.family<T, A>((ref, a) => ...)` | `@riverpod T x(Ref ref, A a) => ...` |
| 多参数 family + Record | 函数参数列表（自动 Record 化） |

## 何时还坚持手写

- 教学/原理讲解（本教程前 8 章）
- 特别简单的一次性 Provider（写一行 `Provider<String>((ref) => 'x')` 很快，也没什么生成收益）
- 团队里 build_runner 不是强制的项目

其他场景**都应该用 codegen**：字面少、类型安全、stateful hot reload 更稳定。

## build.yaml 配置示例

```yaml
targets:
  $default:
    builders:
      riverpod_generator:
        options:
          provider_name_suffix: "Provider"          # 默认
          provider_family_name_suffix: "Provider"
          provider_name_strip_pattern: "Notifier$"  # CounterNotifier → counterProvider
```

## 常见坑

1. **忘了 `part 'xxx.g.dart';`**：生成文件导不进来。
2. **生成文件报错**：跑 `dart run build_runner build --delete-conflicting-outputs`，它会强制覆盖旧生成。
3. **`@riverpod` 的函数不能有位置参数之前的命名参数以外的复杂签名**：保持签名简单——`Ref ref`（必须第一个），后面加普通参数或命名参数。
4. **调用 family**：`ref.watch(userProvider(id: 'abc'))`——注意是命名参数时加 `id:` 前缀，和函数签名一致。

## 本章 Demo

本页是 **codegen 版的计数器 + 天气查询**，和第 3、7 章的手写版对照着看，确认生成的 API 和手写完全等价。

## 练习

1. 把第 3 章的 `LoginForm` 用 `@riverpod class` 重写一遍，跑一次 build_runner。
2. 把第 5 章的 `TodosNotifier` 用 codegen 重写，然后对比 diff：你会发现大部分业务代码完全一样，只是外层壳变短了。
3. 写一个 `@riverpod Future<String> translate(Ref ref, {required String text, required String lang})`，跑一次生成，看看生成的 `translateProvider(text: ..., lang: ...)` 调用方式。

下一章：**怎么给这些 Provider 写测试** → [第 10 章](10_testing_override.md)。

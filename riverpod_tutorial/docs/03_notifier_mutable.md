# 第 3 章 Notifier 可变状态

前面的 `Provider` 是**只读**的：工厂函数返回一个值，就定死了。
要让状态能被修改、被用户操作改变，就用 **`Notifier`**。

## 为什么不直接 `setState`

```dart
class _CounterState extends State<CounterPage> {
  int _count = 0;
  @override
  Widget build(...) => ...;
}
```

`setState` 的问题：
- 状态和 UI 绑死，**跨页面共享必须靠 callback 传参或 global 变量**
- 无法在业务逻辑和 UI 之间做清晰的测试边界
- 无法复用（一个计数逻辑在多个页面就得写多遍）

Riverpod 的 `Notifier` 把"状态 + 修改状态的方法"从 UI 里剥离，变成一个可注入、可测试的类。

## 最小 Notifier

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;           // 初始状态

  void increment() => state++;
  void reset() => state = 0;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);
```

拆解：

- `Notifier<int>`：表示这是一个"状态类型为 `int`"的 Notifier
- `build()`：返回初始状态（首次被 `watch` 时调用一次）
- `state`：内置字段，读它就是当前状态，**赋值它就会通知所有订阅者**
- `NotifierProvider<NotifierClass, StateType>(...)`：告诉 Riverpod "用这个 Notifier 提供这个状态"
- `CounterNotifier.new`：就是 `() => CounterNotifier()` 的简写（tear-off）

## 在 UI 里用

```dart
class CounterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Column(children: [
      Text('$count'),
      ElevatedButton(
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        child: const Text('+1'),
      ),
    ]);
  }
}
```

重点：
- `ref.watch(counterProvider)` → 拿到当前的 `int`（状态值）
- `ref.read(counterProvider.notifier)` → 拿到 `CounterNotifier` 实例（调方法）

## 复杂一点的状态：表单

```dart
class LoginForm {
  const LoginForm({this.email = '', this.password = '', this.submitting = false});
  final String email;
  final String password;
  final bool submitting;

  LoginForm copyWith({String? email, String? password, bool? submitting}) =>
      LoginForm(
        email: email ?? this.email,
        password: password ?? this.password,
        submitting: submitting ?? this.submitting,
      );
}

class LoginFormNotifier extends Notifier<LoginForm> {
  @override
  LoginForm build() => const LoginForm();

  void setEmail(String v) => state = state.copyWith(email: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  Future<void> submit() async {
    state = state.copyWith(submitting: true);
    try {
      await _api.login(state.email, state.password);
    } finally {
      state = state.copyWith(submitting: false);
    }
  }
}
```

**关键规则**：**`state` 必须被整体替换，不能原地修改**：

```dart
state.email = 'x';         // ❌ 改了内部字段, 但引用没变, UI 不会重建
state = state.copyWith(...);  // ✅ 新对象, 通知订阅者
```

如果状态是 `List<T>`，想加一项：

```dart
state = [...state, newItem];         // ✅
state.add(newItem);                   // ❌ 同一个 List, 不触发重建
```

## 对比：state = 新值 vs state.replace(...)

v3 的 `Notifier.state` 的 setter 已经做了"值相等就不通知"（通过 `==`）。如果你想强制通知：

```dart
state = newValue;           // 通常够用; 若 new == old 不会通知
// 强制通知:
ref.notifyListeners();      // 极少用到, 大多数场景不建议
```

## 错误处理与副作用

Notifier 里照样可以 `try/catch`：

```dart
Future<void> loadProfile() async {
  try {
    state = await _api.profile();
  } catch (e) {
    _log('profile 失败: $e');
    rethrow; // 或者交给外层 listen 处理
  }
}
```

**建议**：`Notifier<T>` 只处理同步状态或者"副作用执行过程 + 最终值"。如果状态本质就是异步（比如"一个 Future 的结果"），用下一章的 `FutureProvider` / 第 5 章的 `AsyncNotifier`，**不要** 把 `Future<T>` 硬塞到 `Notifier<T>` 里当状态。

## Notifier 和 StateNotifier 的关系

如果你在网上看到 `StateNotifier` / `StateNotifierProvider`，那是 Riverpod 1.x/2.x 的老 API。v3 里：
- **`Notifier`** = 官方推荐
- `StateNotifier` 仍可用但已 legacy
- `ChangeNotifier` 也能配 `ChangeNotifierProvider` 用，但不推荐

## 常见坑

1. **忘了 `.new`**：`NotifierProvider<X, Y>(X())` ❌ → `NotifierProvider<X, Y>(X.new)` ✅
2. **直接改 state 内部字段**：上面讲过，要新对象
3. **`build()` 里做副作用**：这里只做"初始化返回值"，不做 print 日志、不调 API（API 请求用 `AsyncNotifier`）
4. **在 `initState` 里 `ref.watch`**：用 `ref.read`

## 对照 codegen（剧透）

第 9 章会把这段写成：

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  void increment() => state++;
}
```

看起来简短一些，但**核心概念完全一致**：`build` 返回初始状态、改 `state` 通知订阅者。

## 练习

1. 给本章 Demo 加一个"减 1"按钮和"重置"按钮。
2. 把 `int` 状态改成一个 `{count, lastChange: DateTime}` 的对象，每次 increment 同时更新 `lastChange`。
3. 故意 `state.someList.add(x)` 而不是 `state = [...state.someList, x]`，观察 UI 是否响应。

下一章进入异步：[第 4 章 FutureProvider 与 AsyncValue](04_future_async_value.md)。

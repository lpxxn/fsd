# 第 5 章 AsyncNotifier：异步可变状态

## 问题引入

`FutureProvider` 只能"请求一次、读结果"。但现实里我们总要：
- **增删改**（CRUD）—— 给 Todo 列表添加一条
- **局部刷新** —— 只刷新某一项
- **乐观更新** —— UI 先改，请求失败再回滚

这些场景用 `FutureProvider` 写起来很别扭。`AsyncNotifier` 就是为此而生：**"异步初始化 + 可变方法"** 的组合。

## 最小 AsyncNotifier

```dart
class TodosNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    // 首次被 watch 时加载
    return await _api.fetchTodos();
  }

  Future<void> add(String title) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final created = await _api.createTodo(title);
      final list = state.value ?? [];
      return [...list, created];
    });
  }
}

final todosProvider =
    AsyncNotifierProvider<TodosNotifier, List<Todo>>(TodosNotifier.new);
```

核心点：
- 继承 `AsyncNotifier<T>`（不是 `Notifier<T>`）
- `build` 返回 `Future<T>`
- `state` 的类型是 `AsyncValue<T>`，不是 `T`
- **`AsyncValue.guard(() async => ...)`** 是关键工具：自动捕获异常、包成 `AsyncError`

## AsyncValue.guard 详解

```dart
state = await AsyncValue.guard(() async {
  // 这里的任何异常都会变成 AsyncError, 不会抛到外面
  return await doStuff();
});
```

等价于：

```dart
try {
  final value = await doStuff();
  state = AsyncData(value);
} catch (e, st) {
  state = AsyncError(e, st);
}
```

但更简洁、更统一、不会忘捕获栈。**90% 的 AsyncNotifier 方法里都该这么写**。

## 乐观更新（optimistic update）

乐观更新 = 假设请求会成功，UI 立即反映新状态，请求失败再回滚。用户体验更好。

```dart
Future<void> toggleTodo(String id) async {
  final oldList = state.value ?? [];
  final newList = oldList.map((t) {
    return t.id == id ? t.copyWith(done: !t.done) : t;
  }).toList();

  // 1. 立即更新 UI
  state = AsyncData(newList);

  try {
    await _api.updateTodo(id, done: !oldList.firstWhere((t) => t.id == id).done);
  } catch (e, st) {
    // 2. 失败回滚
    state = AsyncData(oldList);
    // 可以把错误通过 SnackBar 或 listen 暴露出去
    rethrow;
  }
}
```

**模式记住**：
1. 备份旧值
2. 更新 state
3. `try` 请求 → 失败 → 回滚旧值

## 刷新和失效

```dart
// 在方法内触发整体重新加载
Future<void> refresh() async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(build);
}
```

或者外面：

```dart
// 失效 → 下次 watch 时再跑 build
ref.invalidate(todosProvider);

// 立即重跑 build, 拿到新的 AsyncValue
final v = ref.refresh(todosProvider);

// 立即重跑 + await 里层 Future
final list = await ref.refresh(todosProvider.future);
```

## `ref.invalidate` vs `ref.refresh` 的差别

| | `invalidate` | `refresh` |
|--|-------------|----------|
| 立即触发重跑 | 否（标记为脏，下次 watch 才跑） | 是 |
| 返回值 | void | AsyncValue 或 Future |
| 有订阅者时 | 会立即重跑（等同 refresh） | 同 |
| 没订阅者时 | 仅标脏，下次才跑 | 立即跑 |

实际业务里两者很多时候可互换；**"想立即拿到新结果 await" 就用 `refresh`**。

## 常见陷阱

### 1. 忘了 `AsyncLoading` 的回写

```dart
Future<void> load() async {
  // ❌ 没写 loading, UI 不知道正在请求
  state = AsyncData(await _api.fetch());
}

Future<void> load2() async {
  state = const AsyncLoading();               // ✅
  state = await AsyncValue.guard(_api.fetch);
}
```

### 2. 忘了 `?? []` 兜底

```dart
final list = state.value!; // ❌ value 为 null (loading 中) 会抛
final list = state.value ?? []; // ✅
```

### 3. 在 `build` 里写 mutable 方法

`build()` 只负责"获取初始状态"。**不要在 build 里调用增删改方法**——会死循环。方法要定义成类的实例方法，从 UI 通过 `notifier.xxx()` 触发。

## 对照 codegen 版本

第 9 章会写成：

```dart
@riverpod
class Todos extends _$Todos {
  @override
  Future<List<Todo>> build() => _api.fetchTodos();

  Future<void> add(String title) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final t = await _api.createTodo(title);
      return [...?state.value, t];
    });
  }
}
```

改动：`AsyncNotifier<T>` → `_$Todos`（codegen 生成的基类），其他几乎不变。

## 练习

1. 本章 Demo 做一个假的 Todo 列表（内存中），支持"添加 / 切换完成 / 删除"，全部带延迟 500ms。
2. 给"切换完成"实现**乐观更新**：点一下立即变色，延迟后 50% 概率失败回滚。
3. 加一个"全部刷新"按钮。

下一章：**实时流数据** → [第 6 章 StreamProvider](06_stream_provider.md)。

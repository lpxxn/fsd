# 第 6 章 StreamProvider

## 和 FutureProvider 的关系

| | 处理的异步 | 产出 |
|--|-----------|------|
| `FutureProvider<T>` | 一次性 Future | `AsyncValue<T>`，**只变一次** |
| `StreamProvider<T>` | 持续 Stream | `AsyncValue<T>`，**随事件不断变** |

两者产出的都是 `AsyncValue<T>`，UI 侧的代码几乎一样。区别只在于"数据来源是 Future 还是 Stream"。

## 最小 StreamProvider

```dart
final tickProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i);
});

class ClockPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tick = ref.watch(tickProvider);
    return Center(child: Text(tick.value?.toString() ?? '...'));
  }
}
```

就这么多。`ConsumerWidget` 每次 Stream 发出新值都自动重建。

## AsyncValue 的语义略有不同

Stream 可能发多次值、多次错误。`AsyncValue` 在这种场景下：
- 第一个事件来之前：`AsyncLoading`
- 发了个值：`AsyncData(value)`
- 发了个错误：`AsyncError(e, st)`（Stream 没结束，下一个值还能把它变回 AsyncData）

**关键**：`AsyncError` 不代表 Stream 结束，只是当前快照的状态。

## StreamNotifier：可变的 Stream 状态

`StreamNotifier` 是 `AsyncNotifier` 对应的 Stream 版本——当你需要：
- 初始化阶段订阅一个外部 Stream
- 还想暴露可调用的方法修改状态

```dart
class ChatNotifier extends StreamNotifier<List<Message>> {
  @override
  Stream<List<Message>> build() async* {
    final channel = WebSocketChannel.connect(...);
    ref.onDispose(() => channel.sink.close());   // 资源清理

    final buffer = <Message>[];
    await for (final msg in channel.stream) {
      buffer.add(Message.fromJson(jsonDecode(msg)));
      yield buffer.toList();
    }
  }

  void sendLocal(Message m) {
    // 本地直接追加到 state (不走 WS)
    final cur = state.value ?? [];
    state = AsyncData([...cur, m]);
  }
}

final chatProvider =
    StreamNotifierProvider<ChatNotifier, List<Message>>(ChatNotifier.new);
```

## 清理订阅：`ref.onDispose`

上面代码里 `ref.onDispose(() => channel.sink.close())` 非常重要。**Provider 被销毁时（或 autoDispose 的场景），Riverpod 会调用所有 onDispose 回调**。

这是防止泄漏的标准姿势。后面第 8 章会更系统地讲。

## 对比手写 `StreamBuilder`

原生 `StreamBuilder` 写法：

```dart
StreamBuilder<int>(
  stream: _controller.stream,
  builder: (context, snapshot) {
    if (snapshot.hasError) return Text(snapshot.error.toString());
    if (!snapshot.hasData) return const CircularProgressIndicator();
    return Text('${snapshot.data}');
  },
);
```

痛点：
- Stream 是哪来的？你得自己在 `State` 里存
- Stream 要 cancel？你得自己在 `dispose` 里写
- 多个页面订阅同一个 Stream？你得自己做单例

用 `StreamProvider`：
- Stream 创建/订阅/取消全交给 Provider
- 跨页面共享只要 `ref.watch(chatProvider)` 即可
- autoDispose 结合 `ref.onDispose` 自动释放资源

## 把 Future 和 Stream 变成 AsyncNotifier

有时候业务是一个 Future，但你想"监听变化"。可以把 `AsyncNotifier` 的 `build` 里用 `ref.watch` 订阅另一个 Stream：

```dart
class CurrentUserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    // 监听 token Stream, 每次变了就重新 build
    final token = await ref.watch(tokenStreamProvider.future);
    return _api.fetchUser(token);
  }
}
```

**关键**：`ref.watch` 在 `AsyncNotifier.build` 里也能用。依赖变化时 `build` 自动重跑。这就是响应式数据流的核心。

## 常见坑

1. **Stream 忘了关**：用 `ref.onDispose` 或 `StreamController.close()`
2. **用 Stream 只是想 "await 第一个值"**：其实 `FutureProvider` 更适合
3. **广播 Stream vs 单订阅 Stream**：`StreamProvider` 内部只订阅一次，并把事件 fanout 给所有 watcher，所以你传入的 Stream 可以是单订阅的

## 练习

1. 用 `Stream.periodic` 写一个秒表 Provider，每 100ms 发一次当前毫秒，UI 实时显示。
2. 加一个暂停按钮：暂停时 Provider 不再发事件。（提示：在 Notifier 里用 `StreamController` 控制）
3. 把秒表 Provider 改成 `StreamNotifierProvider`，加一个 "reset" 方法。

下一章：**Provider 之间怎么互相依赖 + 带参数** → [第 7 章](07_dependency_and_family.md)。

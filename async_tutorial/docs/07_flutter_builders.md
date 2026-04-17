# 第 7 章 Flutter 集成：FutureBuilder / StreamBuilder

## 为什么不直接 `setState`

最朴素的做法：

```dart
Future<void> _load() async {
  setState(() => _loading = true);
  try {
    _data = await fetch();
  } catch (e) {
    _error = e;
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}
```

能用，但你要手动管 3 个状态：loading / data / error，写多了很烦。

Flutter 提供了 `FutureBuilder` 和 `StreamBuilder` 把这件事做了。

## FutureBuilder

```dart
FutureBuilder<User>(
  future: _userFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('错误: ${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return const Text('无数据');
    }
    return Text('你好, ${snapshot.data!.name}');
  },
);
```

**snapshot.connectionState** 的取值：
| 值 | 含义 |
|----|------|
| `none` | `future == null`（没设置） |
| `waiting` | Future 还没完成 |
| `active` | 对 Future 来说不怎么用（Stream 中有意义） |
| `done` | Future 已经完成（成功或失败） |

### 最常见的陷阱：在 build 里创建 Future

```dart
// ❌ 反例：每次 build 都会新建一个 Future，重复请求
@override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: fetch(),  // 每次 rebuild 都会调用一次！
    builder: ...,
  );
}
```

**正确做法**：把 Future 提升到 `State` 里，只创建一次。

```dart
class _MyState extends State<MyWidget> {
  late Future<User> _future;

  @override
  void initState() {
    super.initState();
    _future = fetch();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _future, // 这里用缓存的 Future
      builder: ...,
    );
  }
}
```

## StreamBuilder

```dart
StreamBuilder<int>(
  stream: _ticker,
  initialData: 0,
  builder: (context, snapshot) {
    return Text('tick: ${snapshot.data}');
  },
);
```

对 Stream 而言 `ConnectionState` 更有用：
| 值 | 含义 |
|----|------|
| `none` | 无 stream |
| `waiting` | 已订阅，等待第一个事件 |
| `active` | 已经收到过至少一个事件，继续订阅中 |
| `done` | Stream 已 done |

### 常见陷阱：StreamBuilder 的 stream 不能每次 build 新建

```dart
// ❌ 每次 build 都会新建 Stream，StreamBuilder 会 dispose 旧的、订阅新的，浪费
StreamBuilder(
  stream: someStream().where((e) => ...), // ← 每次都是新对象！
);

// ✅ 提前生成并缓存
late final _stream = someStream().where((e) => ...);
StreamBuilder(stream: _stream, ...);
```

`StreamBuilder` 内部用 `oldWidget.stream != widget.stream` 判断是否要重新订阅。所以**要保持 stream 对象稳定**。

## 跨 await 要用 `mounted` 检查

```dart
Future<void> _save() async {
  setState(() => _busy = true);
  await api.save();
  if (!mounted) return;              // ← await 之后 widget 可能已被销毁
  setState(() => _busy = false);
}
```

不加这个判断，遇到快速离开页面时会报：`setState called after dispose`。

此外，**`BuildContext` 跨 `await` 使用要小心**：

```dart
Future<void> _go() async {
  await doSomething();
  // ❌ 这里的 context 可能已经不对应任何 widget 了
  Navigator.of(context).pop();
}
```

Flutter 有 lint `use_build_context_synchronously` 会警告这种写法。标准解法：

```dart
Future<void> _go() async {
  await doSomething();
  if (!context.mounted) return;      // Flutter 3.7+
  Navigator.of(context).pop();
}
```

## 不用 builder 的替代：`ValueListenableBuilder` / 状态管理

对于复杂业务，`FutureBuilder` 会显得笨重，更常用的方案：
- **ValueListenableBuilder** + `ValueNotifier`
- **Provider / Riverpod / Bloc** 等状态管理库
- 自己写一个 "loading/data/error" 的 sealed class + `setState`

`FutureBuilder` / `StreamBuilder` 更适合"一次性、没有复杂状态"的场景。

## 小结

- `FutureBuilder` 处理"一次性异步值"；`StreamBuilder` 处理"持续事件流"
- **Future / Stream 对象要缓存**，不能在每次 build 里新建
- 跨 `await` 之后要检查 `mounted` / `context.mounted`
- 复杂业务考虑状态管理库

## 练习题

1. 写一个 `FutureBuilder` 加载用户，用同一个页面切换 3 种状态：loading、success、error。
2. 写一个 `StreamBuilder` 展示一个每秒 +1 的计数器，给 `initialData: 0`。
3. 故意在 `build` 里 `future: fetch()` 新建 Future，然后在父级 `setState`，观察打印出的 "请求次数" 会不会变多。

下一章是全书核心 → [第 8 章 事件循环原理](08_event_loop.md)。

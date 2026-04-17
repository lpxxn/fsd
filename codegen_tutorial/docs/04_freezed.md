# 第 4 章 freezed: 不可变 data class 神器

## 目标

- 理解 freezed 为什么被 Flutter 社区奉为标配。
- 会写三种典型形态: 普通 data class、带方法的 data class、sealed / union。
- 和 `json_serializable` 配合: 一次生成 copyWith + fromJson/toJson。

## freezed 3.x 语法 (重要变更)

freezed 从 2.x 到 3.x 语法有调整, 核心要点:

```dart
@freezed
abstract class Todo with _$Todo {             // 1. abstract + with _$Xxx
  const factory Todo({                         // 2. 私有的 factory 构造函数
    required String id,
    required String title,
    @Default(false) bool done,
  }) = _Todo;                                  // 3. 指向生成的实现类 _Todo

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
```

生成后, 自动带:

- `copyWith({id?, title?, done?})` — 不可变拷贝
- `==` / `hashCode` — 按字段比较
- `toString()` — `Todo(id: "1", title: "buy milk", done: false)`
- `fromJson` / `toJson` — 组合 json_serializable 使用

## 形态 1: 纯数据类

```dart
@freezed
abstract class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    @Default(false) bool done,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}

// 使用:
final t1 = Todo(id: '1', title: 'buy milk');
final t2 = t1.copyWith(done: true);    // 新对象, t1 不变
print(t1 == Todo(id: '1', title: 'buy milk'));   // true, 值相等
```

## 形态 2: 带实例方法/getter

一旦要加 getter 或方法, **必须加一个私有构造函数** `const CartItem._();`, 告诉 freezed "我要扩展这个类":

```dart
@freezed
abstract class CartItem with _$CartItem {
  const CartItem._();   // <-- 关键, 不能省

  const factory CartItem({
    required String sku,
    required double unitPrice,
    @Default(1) int quantity,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  double get total => unitPrice * quantity;
}
```

## 形态 3: sealed / union (最强)

Dart 3 引入 `sealed class`, 编译器会强制你 `switch` 处理所有子类型, 用来表达"一个类型有几种可能状态"时超好用。

```dart
@freezed
sealed class LoadState<T> with _$LoadState<T> {
  const factory LoadState.idle()        = LoadIdle<T>;
  const factory LoadState.loading()     = LoadLoading<T>;
  const factory LoadState.success(T data) = LoadSuccess<T>;
  const factory LoadState.failure(Object error) = LoadFailure<T>;
}

// 穷尽 switch, 少一个分支编译器就会报错:
String describe(LoadState<int> s) => switch (s) {
  LoadIdle()       => '未开始',
  LoadLoading()    => '加载中…',
  LoadSuccess(:final data)   => '成功: $data',
  LoadFailure(:final error)  => '失败: $error',
};
```

**对比 freezed 2.x**: 以前要用 `state.when(idle: ..., loading: ..., success: ..., failure: ...)`。
3.x 推荐直接用 Dart 3 的 pattern matching + sealed class, when/map 不再优先推荐 (仍然可选生成)。

## 生成了什么? 关键产物一瞥

`models.freezed.dart` (精选片段):

```dart
abstract mixin class _$Todo {
  String get id;
  String get title;
  bool get done;
  Todo copyWith({String id, String title, bool done});
  Map<String, dynamic> toJson();
}

final class _Todo extends _$TodoImpl implements Todo {
  const _Todo({required this.id, required this.title, this.done = false});
  final String id;
  final String title;
  final bool done;

  @override
  Todo copyWith({Object? id = freezed, Object? title = freezed, Object? done = freezed}) {
    return _Todo(
      id: identical(id, freezed) ? this.id : id as String,
      title: identical(title, freezed) ? this.title : title as String,
      done: identical(done, freezed) ? this.done : done as bool,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other)
      || (other.runtimeType == runtimeType && other is _Todo
          && other.id == id && other.title == title && other.done == done);

  @override
  int get hashCode => Object.hash(runtimeType, id, title, done);

  @override
  String toString() => 'Todo(id: $id, title: $title, done: $done)';
}
```

一条 `@freezed` 注解, 换来三五十行样板代码。这就是它的价值。

## 和 json_serializable 的合作

写 `@freezed` + `factory Xxx.fromJson` 时, 只要加 `import 'package:freezed_annotation/freezed_annotation.dart';`, freezed 会自动把 json_serializable 需要的 `@JsonSerializable()` 传下去, 最终生成两份文件:

```text
models.freezed.dart     # freezed 写的: copyWith, ==, hashCode, toString
models.g.dart           # json_serializable 写的: fromJson, toJson
```

**必须同时写两个 part 指令**:

```dart
part 'models.freezed.dart';
part 'models.g.dart';
```

## 常见坑

1. **忘了 `with _$Xxx`** → "Missing implementations for these methods..."。
2. **想加 getter 但忘了私有构造函数 `const Xxx._();`** → "The class '_Xxx' has getters but no getters were generated"。
3. **字段改了名忘了重跑 build_runner** → IDE 提示找不到 `copyWith` 里的新字段。
4. **sealed class 里忘加 `<T>`** → 泛型 union 报 `The type 'T' is not defined`。
5. **pub 版本要对齐**: `freezed_annotation` (runtime) 和 `freezed` (dev) 大版本要匹配, 本工程都是 ^3.0。

## 练习

1. 给 `CartItem` 加一个 getter `displayPrice`: `'¥$total'`, 观察 `.freezed.dart` 里并不会增加什么, getter 留在源文件里。
2. 把 `LoadState` 的 success/failure 改名或加新分支, 编译器会在哪里报错? 体会 sealed class 的穷尽检查。
3. 手动写一个等价于 `@freezed` 产物的 `Todo` class, 数一下你写了多少行 (答案: 一般 30+ 行)。对比 freezed 源码的 6 行, 理解价值。

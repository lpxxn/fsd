# 第 5 章 built_value 对照 (短章, 不跑 Demo)

## 为什么单独讲 built_value

在 freezed 流行前, `built_value` 是 Dart 社区最常见的不可变 data class 方案, 由 Google Dart 团队推出。
今天大多数新项目都选 freezed, 但你接手老代码很可能看到 built_value, 也可能听到面试问 "它和 freezed 啥区别"。这章做一次对照, 认知上不犯怵即可。

## 典型 built_value class

```dart
abstract class Todo implements Built<Todo, TodoBuilder> {
  String get id;
  String get title;

  @BuiltValueField(wireName: 'is_done')
  bool get done;

  Todo._();
  factory Todo([void Function(TodoBuilder) updates]) = _$Todo;

  static Serializer<Todo> get serializer => _$todoSerializer;
}
```

跑 `build_runner` 会生成 `todo.g.dart`, 里面有 `_$Todo` (真正的实现) 和 `TodoBuilder`。

## Builder 模式

**built_value 的哲学**: immutability 必须走一个 "mutable builder"。

```dart
final t1 = Todo((b) => b
  ..id = '1'
  ..title = 'buy milk'
  ..done = false);

// "copyWith" 等价写法: rebuild
final t2 = t1.rebuild((b) => b..done = true);
```

而 freezed 直接给你写好了 `copyWith`, 更像 Kotlin data class。

## 序列化: BuiltValueSerializers

built_value 搭配 `built_collection` (`BuiltList` / `BuiltMap`) 和一个中央 `Serializers` 注册表:

```dart
@SerializersFor([Todo, User, Article])
final Serializers serializers = _$serializers;

// fromJson 时得过一道注册表
final jsonMap = serializers.serializeWith(Todo.serializer, todo);
final todo = serializers.deserializeWith(Todo.serializer, jsonMap);
```

freezed 搭配的 json_serializable 直接走 `Todo.fromJson(json)`, 更贴近手写的感觉。

## 对比表

| 维度 | freezed | built_value |
|------|---------|-------------|
| 语法 | `@freezed abstract class Todo with _$Todo { const factory Todo(...) = _Todo; }` | `abstract class Todo implements Built<Todo, TodoBuilder> { ... }` |
| 拷贝 | `todo.copyWith(done: true)` | `todo.rebuild((b) => b..done = true)` |
| 默认值 | `@Default(false)` | `static void _initializeBuilder(TodoBuilder b) => b..done = false;` |
| sealed / union | 一等公民 (`@freezed sealed class`) | 不直接支持, 社区靠 built_value_generator 的 union 扩展 |
| JSON | 搭配 json_serializable, 直接 `Todo.fromJson` | 中央 `Serializers` 注册表 |
| 不可变容器 | 用普通 `List<T>` / `Map<K,V>` | 用 `BuiltList<T>` / `BuiltMap<K,V>` |
| 学习曲线 | 低, 和 Kotlin/Java record 相似 | 较高, builder 模式要适应 |
| 生态 | 新项目主流, 和 riverpod/bloc 都融合好 | 老项目常见, fluentd/Flutter 官方 tooling 部分仍用 |

## 什么时候选 built_value

- 你接手的就是 built_value 老项目, 不要为了迁移而迁移。
- 强团队约束 "不允许 mutation 任何 list/map", 需要 `BuiltList`/`BuiltMap` 的 structural immutability。
- 你喜欢 Java/Guava 风格的 Builder 模式。

## 什么时候选 freezed

- 新项目, 想尽量贴近 "Dart 3 语言原生的体验 (sealed class, pattern matching)"。
- 和 Riverpod / Bloc / retrofit / drift 搭配 —— 社区例子几乎都是 freezed + json_serializable。
- 想少写样板, copyWith 能一行搞定。

## 练习

1. 在脑中 (不用真写) 把 freezed 版 `Todo` 翻译成 built_value 版, 看看哪些地方写起来更啰嗦。
2. 回到公司项目, 搜一下是不是有 `built_value` 的痕迹。有就读读生成的 `.g.dart`, 和 freezed 的 `.freezed.dart` 对比文件结构。
3. 思考: 为什么 Dart 3 引入 sealed / pattern matching 后, freezed 的地位被进一步巩固了?

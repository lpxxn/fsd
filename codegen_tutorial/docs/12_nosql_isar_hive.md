# 第 12 章 NoSQL: isar / hive / objectbox 对照 (短章, 不跑 Demo)

## 为什么单独讲

drift 是关系型 ORM (本质 SQLite); 很多业务其实只需要一个 key/value 或 document 风格的本地库。
Flutter 生态最常见的三个轻量级 NoSQL:

- **hive**: 最简单, 纯 Dart, 很小很快, 历史最久。
- **isar**: 相对较新, 带索引, 单个文件, 异步友好, 支持复杂查询。
- **objectbox**: 同样声明式, 自带同步, 生产级特性多。

它们都有 **codegen**, 本章只做对照, 不跑 Demo。

## hive 的 codegen 用法

```dart
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  User({required this.name, required this.age});

  @HiveField(0) final String name;
  @HiveField(1) final int age;
}
```

跑 `build_runner`, 生成 `user.g.dart` 里的 `UserAdapter` (负责把 User 序列化到 binary)。
注册 + 使用:

```dart
await Hive.initFlutter();
Hive.registerAdapter(UserAdapter());
final box = await Hive.openBox<User>('users');
await box.add(User(name: 'Alice', age: 30));
final alice = box.getAt(0);
```

**特点**: 任意字段只靠 `@HiveField(index)` 的整数索引映射, 字段顺序与索引一一对应, 增字段要往后加, 不能动已有索引。

## isar 的 codegen 用法

```dart
import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  late int age;
}
```

`@collection` 标记 Isar 集合, `@Index()` 标索引。codegen 生成序列化代码 + 类型安全的 Query API:

```dart
final user = await isar.users.filter().nameEqualTo('Alice').findFirst();
```

## objectbox 的 codegen 用法

```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class User {
  @Id() int id = 0;
  String name = '';
  int age = 0;
}
```

codegen 生成 `objectbox-model.json` 元数据文件 + `objectbox.g.dart` 里的 binding, 通过 `store.box<User>().put(...)` 用。
特点: 二进制对齐存储, 读写极快, 有内置对象图同步 (sync) 能力。

## 选型对照表

| 维度 | hive | isar | objectbox | drift |
|------|------|------|-----------|-------|
| 范式 | K/V + 简单对象 | 文档 + 索引 | Entity + 关系 | 关系型 (SQLite) |
| 查询 | 全 box 遍历 | 类型安全 filter API | QueryBuilder | SQL DSL + 原生 SQL |
| 学习成本 | 很低 | 中 | 中 | 中高 |
| 关系/联表 | 自己处理 | 支持 link | 支持 | SQL JOIN |
| 性能 (简单 KV) | 够 | 快 | 非常快 | 一般 |
| Web 支持 | 是 | 差, 靠 wasm | 部分 | 需 drift_wasm |
| 迁移 | 加字段注意 index | 自动 | migration 脚本 | schemaVersion + migration |

## 何时选谁

- **纯缓存 / 简单偏好**: hive 足够, 不要杀鸡用牛刀。
- **结构化业务对象, 需要索引/查询**: isar 体验最好。
- **离线优先 + 对象图同步 (类似 Firebase Realtime)**: objectbox。
- **报表 / SQL 分析 / 复杂联表**: drift。

## 相似点

三家都用同一套 "注解 + build_runner + source_gen" 思路:

1. 你在类上打注解 (`@HiveType`/`@collection`/`@Entity`)。
2. build_runner 扫注解, 调各自的 generator 生成 `*.g.dart` (有时还有额外的二进制元文件)。
3. 你只 **消费** 生成的类 (Adapter / QueryBuilder / Binding), 不用关心序列化细节。

这套模式和前面所有章节完全一致 —— 学通一家, 其他家的文档就能飞快读懂。

## 练习

1. 在网上找一个 "hive vs isar" 的 benchmark, 看 write 1000 条对象的耗时。理解数量级。
2. 在本工程里别装这三家 (pubspec 已经够重了); 在脑海里把 `UserRepository.fetchName(1)` 这种简单场景, 三家分别会怎么实现。
3. 思考: 如果你主项目是 "本地业务离线优先 + 云端同步", 你倾向选谁?

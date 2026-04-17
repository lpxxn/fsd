# 第 11 章 drift: SQLite ORM, 类型安全 query

## 目标

- 用 Dart 类 + `@DriftDatabase` 声明数据库表和数据库类。
- 让 `drift_dev` (也是 build_runner 驱动的 generator) 生成 DAO 风格的类型安全 API。
- 理解和 "手拼 SQL 字符串" 的方案相比, drift 省了什么。

## 最小例子

```dart
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get body => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  Future<List<Note>> allNotes() => (select(notes)..orderBy([
    (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
  ])).get();

  Future<int> addNote(String title, String body) =>
      into(notes).insert(NotesCompanion.insert(title: title, body: Value(body)));
}
```

跑 `dart run build_runner build --delete-conflicting-outputs` 后, `database.g.dart` 里会出现:

- `Note`: 你 insert / select 会拿到的 immutable 数据对象 (带 `copyWith`)
- `$NotesTable`: drift 给 `Notes` 这个声明类生成的 "表元数据" 类
- `NotesCompanion`: insert/update 时的"部分字段"对象 (不填的字段用 `Value.absent()` 跳过)
- `_$AppDatabase`: 我们继承的基类, 自动暴露 `notes` getter、`select / update / delete / into`

## 核心 API 一览

```dart
// SELECT *
db.select(db.notes).get();

// SELECT WHERE
(db.select(db.notes)..where((t) => t.title.like('%dart%'))).get();

// 多字段 ORDER BY
(db.select(db.notes)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]))
    .get();

// INSERT
db.into(db.notes).insert(NotesCompanion.insert(title: 'hi', body: Value('b')));

// UPDATE
db.update(db.notes).replace(note.copyWith(title: 'new'));
(db.update(db.notes)..where((t) => t.id.equals(1)))
    .write(NotesCompanion(title: Value('new')));

// DELETE
(db.delete(db.notes)..where((t) => t.id.equals(1))).go();

// 观察流, 返回 Stream<List<Note>>
db.select(db.notes).watch();
```

全部 **强类型**。`t.title.like('%dart%')` 里面那个 `t.title` 是 `GeneratedColumn<String>`, 编译器知道它只能和字符串比较。

## schema 升级

改了表结构, 就提升 `schemaVersion`:

```dart
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.addColumn(notes, notes.body);
    }
  },
);
```

drift 提供 `StepByStepMigration` 等辅助工具, 可以自动根据 schema 差异生成升级脚本。

## Web 降级

drift 默认走 `sqlite3` 本地库, **Flutter Web 不能直接用**。
- 生产要 Web 支持: 用 `drift_wasm` + 提前放一份 `sqlite3.wasm` 到 assets。
- 本教程 Demo 用 `NativeDatabase.memory()`, 只在原生 (iOS / Android / macOS / Windows / Linux) 上能真正跑。Web 上这行会抛异常, 我们在 Demo 页用 `kIsWeb` 提前拦截, 给用户一个友好提示。

## 对比手拼 SQL

| 方面 | 手拼 SQL | drift |
|------|---------|-------|
| 类型安全 | 字符串, 改字段名靠 grep | 改字段 → 编译全行提示 |
| 反序列化 | 手写 `Map<String, dynamic>` → Note | 自动 |
| 迁移 | 自己判 + 写 SQL | `MigrationStrategy` 模板化 |
| 观察 | 手写 `StreamController` | `watch()` 原生支持 |
| 成本 | 低, 但出错概率高 | 要学 API, 但长期收益大 |

## 踩坑

1. **改字段记得重跑 build_runner**, 否则 `Note` / `NotesCompanion` 不同步。
2. **insert/update 传 `Companion`, 不是原始 Data 类**。所有字段都要用 `Value(...)` 包。
3. **`currentDateAndTime` 是 drift 里的默认值辅助, 别写成 `DateTime.now()`**。
4. **加 index / foreign key**: 用 `@DataClassName('Note')` 等注解定制产物, 见 drift 官方文档。
5. **drift_dev 和 drift 主包版本要对齐**。本工程均为 ^2.20。

## 在本工程的 Demo

`lib/chapters/chapter_11_page.dart`:

- 在 initState 里 new 一个 in-memory AppDatabase, 插三条示例笔记。
- 用 `db.select(db.notes).watch()` 订阅变化, 列表自动更新。
- 点 "+" 加一条, 点条目上的删除图标走 delete。
- Web 平台上直接显示不支持提示。

## 练习

1. 给 `Notes` 加一个 `BoolColumn get done` 字段, `schemaVersion` +1, 在 `MigrationStrategy` 里写 `addColumn`。
2. 写一个查询: "最近 7 天创建的, 按时间降序"。
3. 把 `watch()` 流和 Riverpod 的 `@riverpod Stream<List<Note>>` 对接, 实现响应式 UI。

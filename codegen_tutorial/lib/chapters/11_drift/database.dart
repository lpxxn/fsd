import 'package:drift/drift.dart';

import 'executor_stub.dart'
    if (dart.library.ffi) 'executor_native.dart'
    if (dart.library.html) 'executor_web.dart';

part 'database.g.dart';

/// 一张最简单的 "notes" 表。
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get body => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 用 `@DriftDatabase(tables: [...])` 声明, build_runner 会生成 `_$AppDatabase`:
///   - 自动产出 Note / NotesCompanion / $NotesTable 类
///   - 提供 `select(notes) / into(notes).insert(...) / update(notes)...` 等类型安全 API
@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openExecutor());

  @override
  int get schemaVersion => 1;

  Future<List<Note>> allNotes() => (select(notes)..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
      ])).get();

  Future<int> addNote(String title, String body) =>
      into(notes).insert(NotesCompanion.insert(title: title, body: Value(body)));

  Future<int> removeNote(int id) =>
      (delete(notes)..where((t) => t.id.equals(id))).go();
}

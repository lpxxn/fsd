import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';
import '11_drift/database.dart';

/// 第 11 章 Demo: 用 drift 做一个超简 notes 列表, in-memory SQLite。
class Chapter11Page extends StatefulWidget {
  const Chapter11Page({super.key});

  @override
  State<Chapter11Page> createState() => _Chapter11PageState();
}

class _Chapter11PageState extends State<Chapter11Page> {
  AppDatabase? _db;
  final _title = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      final db = AppDatabase();
      _db = db;
      _seed(db);
    }
  }

  Future<void> _seed(AppDatabase db) async {
    final count = (await db.allNotes()).length;
    if (count == 0) {
      await db.addNote('Welcome', 'This is a drift demo.');
      await db.addNote('Second', 'All strongly typed.');
    }
  }

  @override
  void dispose() {
    _db?.close();
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const ChapterScaffold(
        title: '11 · drift',
        intro: 'drift 默认走原生 SQLite, Web 上需要 drift_wasm 搭配 sqlite3.wasm。'
            '本 Demo 为简洁起见只在原生平台跑。',
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              '请在 iOS / Android / macOS / Windows / Linux 上运行本章。\n\n'
              'Flutter Web 需要 drift_wasm 配置, 见文档「Web 降级」一节。',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final db = _db!;
    return ChapterScaffold(
      title: '11 · drift',
      intro: '下方是 drift 跑的类型安全 SQL 查询结果, 用 watch() 订阅流, '
          '增删都会自动刷新。代码里 `db.select(db.notes)` 都是编译期类型检查过的。',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: '新笔记标题',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  final t = _title.text.trim();
                  if (t.isEmpty) return;
                  await db.addNote(t, '');
                  _title.clear();
                },
                child: const Text('添加'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: db.select(db.notes).watch(),
              builder: (context, snap) {
                final notes = snap.data ?? const [];
                if (notes.isEmpty) {
                  return const Center(child: Text('还没有笔记'));
                }
                return ListView.separated(
                  itemCount: notes.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final n = notes[i];
                    return ListTile(
                      title: Text(n.title),
                      subtitle: Text('${n.createdAt.toLocal()}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => db.removeNote(n.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

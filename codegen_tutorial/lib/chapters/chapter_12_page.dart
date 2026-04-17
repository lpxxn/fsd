import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 12 章 Demo: 三家 NoSQL 的注解写法并排对比, 不跑代码。
class Chapter12Page extends StatelessWidget {
  const Chapter12Page({super.key});

  static const _hive = '''
@HiveType(typeId: 0)
class User {
  @HiveField(0) final String name;
  @HiveField(1) final int age;
}

Hive.registerAdapter(UserAdapter());
final box = await Hive.openBox<User>('users');
box.add(User(name: 'A', age: 30));
''';

  static const _isar = '''
@collection
class User {
  Id id = Isar.autoIncrement;
  @Index() late String name;
  late int age;
}

await isar.users
  .filter()
  .nameEqualTo('Alice')
  .findFirst();
''';

  static const _objectbox = '''
@Entity()
class User {
  @Id() int id = 0;
  String name = '';
  int age = 0;
}

store.box<User>().put(User()..name='A'..age=30);
''';

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '12 · NoSQL: hive / isar / objectbox',
      intro: '三家都用 build_runner + 注解 生成序列化 + 查询 API。差异主要在范式和性能, '
          '不是代码生成机制本身。',
      child: Row(
        children: [
          Expanded(child: _Box(title: 'hive', code: _hive, color: Colors.yellow.shade50)),
          const SizedBox(width: 8),
          Expanded(child: _Box(title: 'isar', code: _isar, color: Colors.purple.shade50)),
          const SizedBox(width: 8),
          Expanded(child: _Box(title: 'objectbox', code: _objectbox, color: Colors.teal.shade50)),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.title, required this.code, required this.color});
  final String title;
  final String code;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                code,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

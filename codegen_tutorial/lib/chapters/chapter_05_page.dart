import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 5 章 Demo: 文字对照, 不跑代码。
class Chapter05Page extends StatelessWidget {
  const Chapter05Page({super.key});

  static const _freezed = '''
@freezed
abstract class Todo with _\$Todo {
  const factory Todo({
    required String id,
    required String title,
    @Default(false) bool done,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) =>
      _\$TodoFromJson(json);
}

final t2 = t1.copyWith(done: true);
''';

  static const _builtValue = '''
abstract class Todo implements Built<Todo, TodoBuilder> {
  String get id;
  String get title;
  bool get done;

  Todo._();
  factory Todo([void Function(TodoBuilder) updates]) = _\$Todo;

  static Serializer<Todo> get serializer => _\$todoSerializer;
}

final t2 = t1.rebuild((b) => b..done = true);
''';

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '05 · built_value vs freezed',
      intro: '并排对比同一个 Todo 在两个库里的写法。新项目几乎都选 freezed, '
          '但接手老代码时你可能看到 built_value, 需要认知上不犯怵。',
      child: Row(
        children: [
          Expanded(
            child: _Box(
              title: 'freezed (推荐, 主流)',
              code: _freezed,
              color: Colors.green.shade50,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Box(
              title: 'built_value (老项目)',
              code: _builtValue,
              color: Colors.blue.shade50,
            ),
          ),
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
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

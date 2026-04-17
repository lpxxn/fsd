import 'package:flutter/material.dart';

import 'chapters/chapter_01_page.dart';
import 'chapters/chapter_02_page.dart';
import 'chapters/chapter_03_page.dart';
import 'chapters/chapter_04_page.dart';
import 'chapters/chapter_05_page.dart';
import 'chapters/chapter_06_page.dart';
import 'chapters/chapter_07_page.dart';
import 'chapters/chapter_08_page.dart';
import 'chapters/chapter_09_page.dart';
import 'chapters/chapter_10_page.dart';
import 'chapters/chapter_11_page.dart';

void main() {
  runApp(const AsyncTutorialApp());
}

class AsyncTutorialApp extends StatelessWidget {
  const AsyncTutorialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 异步教程',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const ChapterIndexPage(),
    );
  }
}

class Chapter {
  const Chapter({
    required this.number,
    required this.title,
    required this.summary,
    required this.builder,
  });
  final String number;
  final String title;
  final String summary;
  final WidgetBuilder builder;
}

final List<Chapter> chapters = [
  Chapter(
    number: '01',
    title: '同步 vs 异步',
    summary: '为什么需要异步：卡顿 vs 流畅的直观对比',
    builder: (_) => const Chapter01Page(),
  ),
  Chapter(
    number: '02',
    title: 'Future 基础',
    summary: 'Future 的创建与 .then / .catchError / .whenComplete',
    builder: (_) => const Chapter02Page(),
  ),
  Chapter(
    number: '03',
    title: 'async / await',
    summary: '把 Future 链改成顺序代码，try/catch 处理错误',
    builder: (_) => const Chapter03Page(),
  ),
  Chapter(
    number: '04',
    title: '并行组合',
    summary: 'Future.wait / Future.any / 串行 vs 并行耗时对比',
    builder: (_) => const Chapter04Page(),
  ),
  Chapter(
    number: '05',
    title: 'Stream 基础',
    summary: '单订阅 vs 广播 Stream，listen / await for',
    builder: (_) => const Chapter05Page(),
  ),
  Chapter(
    number: '06',
    title: 'Stream 进阶',
    summary: 'StreamController、map/where/asyncMap、背压',
    builder: (_) => const Chapter06Page(),
  ),
  Chapter(
    number: '07',
    title: 'Flutter 集成',
    summary: 'FutureBuilder 与 StreamBuilder 正确用法',
    builder: (_) => const Chapter07Page(),
  ),
  Chapter(
    number: '08',
    title: '事件循环原理（核心）',
    summary: '微任务队列 vs 事件队列的调度顺序',
    builder: (_) => const Chapter08Page(),
  ),
  Chapter(
    number: '09',
    title: 'Zone 与全局错误',
    summary: 'runZonedGuarded 捕获未处理异常',
    builder: (_) => const Chapter09Page(),
  ),
  Chapter(
    number: '10',
    title: 'Isolate 真并发',
    summary: 'compute / Isolate.run 解决 CPU 密集任务',
    builder: (_) => const Chapter10Page(),
  ),
  Chapter(
    number: '11',
    title: '常见陷阱',
    summary: '忘了 await、await in loop、mounted 检查',
    builder: (_) => const Chapter11Page(),
  ),
];

class ChapterIndexPage extends StatelessWidget {
  const ChapterIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 异步编程教程'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: chapters.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final c = chapters[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: ListTile(
              leading: CircleAvatar(child: Text(c.number)),
              title: Text(
                '第 ${c.number} 章  ${c.title}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(c.summary),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: c.builder),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

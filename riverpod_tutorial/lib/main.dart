import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import 'chapters/chapter_12_page.dart';
import 'chapters/chapter_13_page.dart';

void main() {
  // ProviderScope 是所有 Provider 的根容器，必须包在整棵 Widget 树外层。
  runApp(const ProviderScope(child: RiverpodTutorialApp()));
}

class RiverpodTutorialApp extends StatelessWidget {
  const RiverpodTutorialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod 3 深入教程',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
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
    title: '第一个 Provider',
    summary: 'Provider<T> + ConsumerWidget + ref.watch',
    builder: (_) => const Chapter01Page(),
  ),
  Chapter(
    number: '02',
    title: 'ref 三件套',
    summary: 'ref.watch vs ref.read vs ref.listen',
    builder: (_) => const Chapter02Page(),
  ),
  Chapter(
    number: '03',
    title: 'Notifier 可变状态',
    summary: 'Notifier + NotifierProvider，手写版计数器',
    builder: (_) => const Chapter03Page(),
  ),
  Chapter(
    number: '04',
    title: 'FutureProvider & AsyncValue',
    summary: '异步数据三态：loading/data/error',
    builder: (_) => const Chapter04Page(),
  ),
  Chapter(
    number: '05',
    title: 'AsyncNotifier',
    summary: '异步可变状态 + 乐观更新 + 刷新',
    builder: (_) => const Chapter05Page(),
  ),
  Chapter(
    number: '06',
    title: 'StreamProvider',
    summary: '把 Stream 变成 AsyncValue',
    builder: (_) => const Chapter06Page(),
  ),
  Chapter(
    number: '07',
    title: '依赖组合与 family',
    summary: 'Provider 互 watch、family 带参数',
    builder: (_) => const Chapter07Page(),
  ),
  Chapter(
    number: '08',
    title: 'autoDispose 与生命周期',
    summary: 'onDispose / keepAlive / cancel 时机',
    builder: (_) => const Chapter08Page(),
  ),
  Chapter(
    number: '09',
    title: '代码生成 @riverpod',
    summary: '函数版 + 类版对照手写写法',
    builder: (_) => const Chapter09Page(),
  ),
  Chapter(
    number: '10',
    title: '测试与 override',
    summary: 'ProviderContainer / overrides / Mock',
    builder: (_) => const Chapter10Page(),
  ),
  Chapter(
    number: '11',
    title: '内部原理',
    summary: 'Scope / Element / 依赖图重建机制',
    builder: (_) => const Chapter11Page(),
  ),
  Chapter(
    number: '12',
    title: '架构分层',
    summary: 'data / application / presentation',
    builder: (_) => const Chapter12Page(),
  ),
  Chapter(
    number: '13',
    title: '综合实战：Todo App',
    summary: '登录 + CRUD + 分页 + 缓存',
    builder: (_) => const Chapter13Page(),
  ),
];

class ChapterIndexPage extends StatelessWidget {
  const ChapterIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod 3 深入教程'),
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

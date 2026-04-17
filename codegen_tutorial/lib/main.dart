import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chapters/chapter_00_page.dart';
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
import 'chapters/chapter_14_page.dart';
import 'chapters/chapter_15_page.dart';

void main() {
  runApp(const ProviderScope(child: CodegenTutorialApp()));
}

class CodegenTutorialApp extends StatelessWidget {
  const CodegenTutorialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 代码生成教程',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ChapterIndexPage(),
    );
  }
}

class ChapterEntry {
  const ChapterEntry(this.title, this.summary, this.builder);
  final String title;
  final String summary;
  final WidgetBuilder builder;
}

class ChapterIndexPage extends StatelessWidget {
  const ChapterIndexPage({super.key});

  static final List<ChapterEntry> chapters = [
    ChapterEntry(
      '00 · 总览',
      '为什么需要 codegen · 工具链全景 · build_runner build/watch 差异',
      (_) => const Chapter00Page(),
    ),
    ChapterEntry(
      '01 · build_runner 内部原理',
      'Builder / BuildStep / source_gen / analyzer / part 指令',
      (_) => const Chapter01Page(),
    ),
    ChapterEntry(
      '02 · 写自己的 Generator',
      '用 my_generator + @ToStringGen 自动生成 toString()',
      (_) => const Chapter02Page(),
    ),
    ChapterEntry(
      '03 · json_serializable',
      '@JsonSerializable · fromJson/toJson · 嵌套 · 泛型 · 枚举',
      (_) => const Chapter03Page(),
    ),
    ChapterEntry(
      '04 · freezed',
      '不可变 data class · copyWith · sealed / union · when/map',
      (_) => const Chapter04Page(),
    ),
    ChapterEntry(
      '05 · built_value 对照',
      '和 freezed 的思路对比 · 何时选谁',
      (_) => const Chapter05Page(),
    ),
    ChapterEntry(
      '06 · riverpod_generator 精讲',
      '@riverpod 生成了什么 · 对照手写 Provider',
      (_) => const Chapter06Page(),
    ),
    ChapterEntry(
      '07 · injectable + get_it',
      '@injectable/@singleton · configureDependencies · env',
      (_) => const Chapter07Page(),
    ),
    ChapterEntry(
      '08 · mockito / mocktail',
      '@GenerateMocks vs "无 codegen" 方案',
      (_) => const Chapter08Page(),
    ),
    ChapterEntry(
      '09 · retrofit',
      '@RestApi · @GET/@POST · 生成的 _ApiImpl',
      (_) => const Chapter09Page(),
    ),
    ChapterEntry(
      '10 · auto_route',
      '类型安全路由 · @AutoRouterConfig · 参数传递',
      (_) => const Chapter10Page(),
    ),
    ChapterEntry(
      '11 · drift (SQLite ORM)',
      '@DriftDatabase · 类型安全 query · web 降级',
      (_) => const Chapter11Page(),
    ),
    ChapterEntry(
      '12 · NoSQL 对照 (isar / hive)',
      '@collection / @HiveType 各自的 codegen',
      (_) => const Chapter12Page(),
    ),
    ChapterEntry(
      '13 · l10n / gen_l10n',
      'ARB → AppLocalizations · zh/en 切换',
      (_) => const Chapter13Page(),
    ),
    ChapterEntry(
      '14 · flutter_gen 资源',
      'Assets.images.xxx · 字符串路径变强类型',
      (_) => const Chapter14Page(),
    ),
    ChapterEntry(
      '15 · Dart Macros (实验)',
      '@JsonCodable · 现状 / 限制 / 未来趋势',
      (_) => const Chapter15Page(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 代码生成教程'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: chapters.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final c = chapters[i];
          return Card(
            child: ListTile(
              title: Text(c.title),
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

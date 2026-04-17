import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 8 章 Demo: 文字对照 + 打开测试文件入口。
///
/// mockito / mocktail 都是测试时用, app 运行时没啥可演示。
/// 我们在 test/ 下放了两份等价的测试, 这里只做导航和说明。
class Chapter08Page extends StatelessWidget {
  const Chapter08Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '08 · mockito vs mocktail',
      intro: '两个流派对照。跑 `flutter test` 就能看到两份测试都通过。'
          'mockito 靠 @GenerateMocks 生成 Mock 类; mocktail 直接继承 Mock 不需要 codegen。',
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: DefaultTextStyle(
          style: TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '// test/mockito_generate_test.dart (需要 build_runner)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '@GenerateMocks([UserRepository])\n'
                'final repo = MockUserRepository();       // 自动生成\n'
                'when(repo.fetchName(1)).thenAnswer((_) async => "Alice");',
              ),
              SizedBox(height: 16),
              Text(
                '// test/mocktail_no_codegen_test.dart (无 codegen)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'class MockUserRepo extends Mock implements UserRepository {}\n\n'
                'final repo = MockUserRepo();\n'
                'when(() => repo.fetchName(1)).thenAnswer((_) async => "Bob");',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

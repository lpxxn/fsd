import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../common/chapter_scaffold.dart';
import '../l10n/generated/app_localizations.dart';

/// 第 13 章 Demo: 切换 zh / en 两个 locale, 实时展示生成的 AppLocalizations。
class Chapter13Page extends StatefulWidget {
  const Chapter13Page({super.key});

  @override
  State<Chapter13Page> createState() => _Chapter13PageState();
}

class _Chapter13PageState extends State<Chapter13Page> {
  Locale _locale = const Locale('zh');
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '13 · l10n / gen_l10n',
      intro: 'ARB 文件 → flutter gen-l10n → AppLocalizations。'
          '切换 locale 按钮会让下方字符串重新从生成类中取值, 包括 plural 规则。',
      child: Localizations.override(
        context: context,
        locale: _locale,
        delegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: Builder(builder: (context) {
          final l = AppLocalizations.of(context);
          if (l == null) {
            return const Center(child: Text('AppLocalizations not found'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('中文'),
                    selected: _locale.languageCode == 'zh',
                    onSelected: (_) => setState(() => _locale = const Locale('zh')),
                  ),
                  ChoiceChip(
                    label: const Text('English'),
                    selected: _locale.languageCode == 'en',
                    onSelected: (_) => setState(() => _locale = const Locale('en')),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('appTitle: ${l.appTitle}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('greeting("Alice"): ${l.greeting('Alice')}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('count = '),
                  Text('$_count', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  IconButton(onPressed: () => setState(() => _count = (_count - 1).clamp(0, 999)), icon: const Icon(Icons.remove)),
                  IconButton(onPressed: () => setState(() => _count++), icon: const Icon(Icons.add)),
                ],
              ),
              Text('unreadCount($_count) = ${l.unreadCount(_count)}', style: const TextStyle(fontSize: 16)),
            ],
          );
        }),
      ),
    );
  }
}

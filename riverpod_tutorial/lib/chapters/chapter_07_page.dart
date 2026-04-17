import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/chapter_scaffold.dart';

/// 第 7 章：Provider 依赖组合 + family 带参数。

// ----- 1) 语言切换演示依赖传播 -----
class LangNotifier extends Notifier<String> {
  @override
  String build() => 'zh';
  void set(String v) => state = v;
}

final langProvider = NotifierProvider<LangNotifier, String>(LangNotifier.new);

final greetingByLangProvider = Provider<String>((ref) {
  final lang = ref.watch(langProvider); // 依赖 langProvider
  return switch (lang) {
    'en' => 'Hello, Riverpod!',
    'jp' => 'こんにちは、Riverpod!',
    _ => '你好，Riverpod！',
  };
});

// ----- 2) family + Record 多参数: 查询城市天气 -----
typedef WeatherArgs = ({String city, String unit});

final weatherProvider =
    FutureProvider.family<String, WeatherArgs>((ref, args) async {
  await Future.delayed(const Duration(milliseconds: 600));
  final temp = (10 + args.city.hashCode % 20).abs();
  final converted = args.unit == 'F' ? temp * 9 / 5 + 32 : temp.toDouble();
  return '${args.city}: ${converted.toStringAsFixed(1)} °${args.unit}';
});

class Chapter07Page extends ConsumerStatefulWidget {
  const Chapter07Page({super.key});

  @override
  ConsumerState<Chapter07Page> createState() => _Chapter07PageState();
}

class _Chapter07PageState extends ConsumerState<Chapter07Page> {
  String _city = '北京';
  String _unit = 'C';

  @override
  Widget build(BuildContext context) {
    final greeting = ref.watch(greetingByLangProvider);
    final weather = ref.watch(weatherProvider((city: _city, unit: _unit)));

    return ChapterScaffold(
      title: '07 · 依赖 & family',
      intro: '上半部分: greetingByLang watch langProvider, 语言切换会自动传播。'
          '下半部分: FutureProvider.family 用 Record 传多参数。',
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('langProvider → greetingByLangProvider',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(greeting, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['zh', 'en', 'jp'].map((l) {
                      final selected = ref.watch(langProvider) == l;
                      return ChoiceChip(
                        label: Text(l),
                        selected: selected,
                        onSelected: (_) =>
                            ref.read(langProvider.notifier).set(l),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('weatherProvider.family(city, unit)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('城市: '),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _city,
                        items: ['北京', '上海', '广州', 'Tokyo', 'NYC']
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _city = v!),
                      ),
                      const SizedBox(width: 16),
                      const Text('单位: '),
                      ToggleButtons(
                        isSelected: [_unit == 'C', _unit == 'F'],
                        onPressed: (i) =>
                            setState(() => _unit = i == 0 ? 'C' : 'F'),
                        children: const [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('°C')),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('°F')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  switch (weather) {
                    AsyncData(:final value) => Text(
                        value,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    AsyncError(:final error) =>
                      Text('$error', style: const TextStyle(color: Colors.red)),
                    _ => const CircularProgressIndicator(),
                  },
                  const SizedBox(height: 8),
                  const Text(
                    '注意: 切换城市/单位后再切回来, 是秒出的 —— '
                    '因为 (city, unit) 参数一样, 命中了 family 的缓存。',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

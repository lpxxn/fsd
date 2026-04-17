import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/chapter_scaffold.dart';

/// 第 12 章 Demo：三层架构的最小演示。
/// data 层: SettingsRepository (抽象 + 假实现)
/// application 层: ThemeController (AsyncNotifier)
/// presentation 层: 本页 UI

// ---- data 层 ----
abstract class SettingsRepository {
  Future<int> loadColorSeed();
  Future<void> saveColorSeed(int seed);
}

class InMemorySettingsRepository implements SettingsRepository {
  int _seed = Colors.teal.toARGB32();

  @override
  Future<int> loadColorSeed() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _seed;
  }

  @override
  Future<void> saveColorSeed(int seed) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _seed = seed;
  }
}

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => InMemorySettingsRepository());

// ---- application 层 ----
class ThemeController extends AsyncNotifier<Color> {
  late SettingsRepository _repo;

  @override
  Future<Color> build() async {
    _repo = ref.watch(settingsRepositoryProvider);
    final seed = await _repo.loadColorSeed();
    return Color(seed);
  }

  Future<void> setColor(Color c) async {
    state = AsyncData(c);
    await _repo.saveColorSeed(c.toARGB32());
  }
}

final themeControllerProvider =
    AsyncNotifierProvider<ThemeController, Color>(ThemeController.new);

// ---- presentation 层 ----
class Chapter12Page extends ConsumerWidget {
  const Chapter12Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    return ChapterScaffold(
      title: '12 · 架构分层',
      intro: 'UI 只 watch themeControllerProvider, 不感知 settingsRepository。'
          '换成 FakeRepository 做测试时, 这段 UI 代码一行也不用改。',
      child: switch (theme) {
        AsyncData(:final value) => _ThemeDemo(color: value),
        AsyncError(:final error) => Text('出错: $error'),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _ThemeDemo extends ConsumerWidget {
  const _ThemeDemo({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = [Colors.teal, Colors.indigo, Colors.pink, Colors.orange, Colors.green];
    return Column(
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            '当前主题色: #${color.toARGB32().toRadixString(16).toUpperCase()}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: palette.map((c) {
            return GestureDetector(
              onTap: () =>
                  ref.read(themeControllerProvider.notifier).setColor(c),
              child: CircleAvatar(backgroundColor: c, radius: 20),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text('分层:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const _LayerRow('presentation', 'Chapter12Page (当前 UI)'),
        const _LayerRow('application', 'ThemeController (AsyncNotifier)'),
        const _LayerRow('data', 'SettingsRepository (InMemory 实现)'),
      ],
    );
  }
}

class _LayerRow extends StatelessWidget {
  const _LayerRow(this.layer, this.name);
  final String layer;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.grey.shade200,
          child: Text(layer,
              style: const TextStyle(
                  fontFamily: 'monospace', fontSize: 12)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}

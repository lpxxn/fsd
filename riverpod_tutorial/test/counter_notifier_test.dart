import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_tutorial/chapters/chapter_03_page.dart';

void main() {
  group('CounterNotifier', () {
    test('初始值是 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(counterProvider), 0);
    });

    test('increment 三次后为 3', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(counterProvider.notifier);
      notifier.increment();
      notifier.increment();
      notifier.increment();

      expect(container.read(counterProvider), 3);
    });

    test('reset 把状态归零', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(counterProvider.notifier);
      notifier.increment();
      notifier.increment();
      notifier.reset();

      expect(container.read(counterProvider), 0);
    });

    test('decrement 变负', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(counterProvider.notifier).decrement();
      expect(container.read(counterProvider), -1);
    });
  });
}

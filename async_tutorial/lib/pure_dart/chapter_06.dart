// 运行: dart run lib/pure_dart/chapter_06.dart

import 'dart:async';

Stream<int> countDown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(const Duration(milliseconds: 200));
    yield i;
  }
}

Future<void> controllerDemo() async {
  print('== StreamController (必须 close) ==');
  final ctrl = StreamController<int>();
  final done = ctrl.stream.listen(
    (v) => print('  data=$v'),
    onError: (e) => print('  err=$e'),
    onDone: () => print('  done'),
  );
  ctrl.add(1);
  ctrl.add(2);
  ctrl.addError('oops');
  ctrl.add(3);
  await ctrl.close();
  await done.asFuture();
}

Future<void> asyncStarDemo() async {
  print('\n== async* + yield ==');
  await for (final v in countDown(3)) {
    print('  $v');
  }
}

Future<void> transformDemo() async {
  print('\n== where / map / asyncMap ==');
  await Stream.fromIterable([1, 2, 3, 4, 5])
      .where((e) => e.isOdd)
      .map((e) => e * 10)
      .asyncMap((e) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return e + 1;
      })
      .forEach((e) => print('  $e'));
}

Future<void> main() async {
  await controllerDemo();
  await asyncStarDemo();
  await transformDemo();
}

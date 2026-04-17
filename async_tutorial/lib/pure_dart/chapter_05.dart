// 运行: dart run lib/pure_dart/chapter_05.dart

import 'dart:async';

Stream<int> nums() async* {
  for (var i = 1; i <= 3; i++) {
    await Future.delayed(const Duration(milliseconds: 300));
    yield i;
  }
}

Future<void> listenDemo() async {
  print('== listen ==');
  final sub = nums().listen(
    (v) => print('  收到 $v'),
    onDone: () => print('  done'),
  );
  await Future.delayed(const Duration(seconds: 2));
  await sub.cancel();
}

Future<void> awaitForDemo() async {
  print('\n== await for ==');
  await for (final v in nums()) {
    print('  收到 $v');
    if (v == 2) {
      print('  提前 break');
      break;
    }
  }
  print('  结束');
}

Future<void> broadcastDemo() async {
  print('\n== broadcast ==');
  final ctrl = StreamController<int>.broadcast();
  ctrl.stream.listen((v) => print('  A: $v'));
  ctrl.stream.listen((v) => print('  B: $v'));
  for (var i = 1; i <= 3; i++) {
    ctrl.add(i);
    await Future.delayed(const Duration(milliseconds: 100));
  }
  await ctrl.close();
}

Future<void> singleTwiceDemo() async {
  print('\n== 单订阅第二次 listen 会抛 ==');
  final s = Stream.fromIterable([1, 2, 3]);
  s.listen((v) => print('  first $v'));
  try {
    s.listen((v) => print('  second $v'));
  } catch (e) {
    print('  抛了: $e');
  }
  await Future.delayed(const Duration(milliseconds: 50));
}

Future<void> main() async {
  await listenDemo();
  await awaitForDemo();
  await broadcastDemo();
  await singleTwiceDemo();
}

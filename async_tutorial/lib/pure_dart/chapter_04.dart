// 运行: dart run lib/pure_dart/chapter_04.dart

import 'dart:async';

Future<int> fakeFetch(String name, int ms, {bool fail = false}) async {
  await Future.delayed(Duration(milliseconds: ms));
  if (fail) throw Exception('$name failed');
  return ms;
}

Future<void> serialDemo() async {
  print('== 串行 ==');
  final sw = Stopwatch()..start();
  final a = await fakeFetch('A', 500);
  final b = await fakeFetch('B', 500);
  final c = await fakeFetch('C', 500);
  sw.stop();
  print('  结果=[$a, $b, $c], 耗时=${sw.elapsedMilliseconds}ms');
}

Future<void> parallelDemo() async {
  print('\n== 并行 Future.wait ==');
  final sw = Stopwatch()..start();
  final list = await Future.wait([
    fakeFetch('A', 500),
    fakeFetch('B', 500),
    fakeFetch('C', 500),
  ]);
  sw.stop();
  print('  结果=$list, 耗时=${sw.elapsedMilliseconds}ms');
}

Future<void> anyDemo() async {
  print('\n== Future.any ==');
  final sw = Stopwatch()..start();
  final first = await Future.any([
    fakeFetch('慢', 800),
    fakeFetch('快', 200),
    fakeFetch('中', 500),
  ]);
  sw.stop();
  print('  最快的结果=$first, 耗时=${sw.elapsedMilliseconds}ms');
}

Future<void> eagerErrorDemo() async {
  print('\n== Future.wait + eagerError ==');
  try {
    await Future.wait([
      fakeFetch('ok1', 200),
      fakeFetch('bad', 100, fail: true),
      fakeFetch('ok2', 500),
    ], eagerError: true);
  } catch (e) {
    print('  eagerError=true 立即抛: $e');
  }
}

Future<void> main() async {
  await serialDemo();
  await parallelDemo();
  await anyDemo();
  await eagerErrorDemo();
}

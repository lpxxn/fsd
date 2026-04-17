// 运行: dart run lib/pure_dart/chapter_11.dart

import 'dart:async';

Future<int> fetch(int i) =>
    Future.delayed(const Duration(milliseconds: 200), () => i);

Future<void> serial() async {
  final sw = Stopwatch()..start();
  for (var i = 0; i < 5; i++) {
    await fetch(i);
  }
  print('  串行 5x200ms  耗时=${sw.elapsedMilliseconds}ms');
}

Future<void> parallel() async {
  final sw = Stopwatch()..start();
  await Future.wait(List.generate(5, fetch));
  print('  并行 Future.wait  耗时=${sw.elapsedMilliseconds}ms');
}

Future<void> forgetAwait() async {
  print('\n== 忘了 await ==');
  fetch(42).then((v) => print('  回调打印 $v'));
  print('  函数返回前这一行先跑');
  await Future.delayed(const Duration(milliseconds: 300));
}

Future<void> futureValueAsync() async {
  print('\n== Future.value.then 仍异步 ==');
  var x = 0;
  Future.value(1).then((_) => x = 99);
  print('  立即读 x=$x  (不是 99)');
  await Future.value(null);
  print('  过一个微任务后 x=$x');
}

Future<void> main() async {
  print('== for + await (串行) vs Future.wait (并行) ==');
  await serial();
  await parallel();
  await forgetAwait();
  await futureValueAsync();
}

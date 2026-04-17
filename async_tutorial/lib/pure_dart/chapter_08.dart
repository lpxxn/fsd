// 运行: dart run lib/pure_dart/chapter_08.dart
//
// 观察微任务、事件、同步代码的执行顺序。
// 预期输出 (注意 8 在 2 之前):
//   1 sync
//   8 sync
//   2 micro-a
//   6 micro-b
//   3 event-a
//   4 then-after-event-a
//   5 micro-inside-then
//   7 event-b

import 'dart:async';

void main() {
  print('1 sync');
  scheduleMicrotask(() => print('2 micro-a'));

  Future(() => print('3 event-a')).then((_) {
    print('4 then-after-event-a');
    scheduleMicrotask(() => print('5 micro-inside-then'));
  });

  Future.microtask(() => print('6 micro-b'));
  Future(() => print('7 event-b'));

  print('8 sync');
}

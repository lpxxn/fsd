// 运行: dart run lib/pure_dart/chapter_09.dart

import 'dart:async';

void main() {
  runZonedGuarded(() {
    print('== 未处理的异步异常会被 zone 捕获 ==');
    Future(() => throw StateError('boom 1'));
    Future.delayed(
        const Duration(milliseconds: 100), () => throw StateError('boom 2'));

    print('\n== 自定义 print ==');
    runZoned(() {
      print('hello');
    }, zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => parent.print(zone, '[zone-log] $line'),
    ));

    print('\n== zoneValues 沿异步传递 ==');
    runZoned(() async {
      await Future.delayed(const Duration(milliseconds: 50));
      print('traceId=${Zone.current['traceId']}');
    }, zoneValues: {'traceId': 'abc-123'});
  }, (error, stack) {
    print('[全局兜底] $error');
  });
}

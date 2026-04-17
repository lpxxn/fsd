import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

/// 全局容器。第 7 章所有注入都经由它。
final getIt = GetIt.instance;

/// build_runner 会扫整个工程的 @injectable/@singleton/@lazySingleton,
/// 生成 `di.config.dart` 里的 `$initGetIt(getIt)` extension 函数。
@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  getIt.$initGetIt();
}

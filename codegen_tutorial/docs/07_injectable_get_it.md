# 第 7 章 injectable + get_it

## 目标

- 理解 `get_it` (service locator) 和 `injectable` (注解 + codegen) 的分工。
- 会写三类注解: `@injectable`、`@singleton`、`@lazySingleton`。
- 会用 `@Named` / `as:` 解决"一个抽象多个实现"的选择。

## 两个名字的分工

- **`get_it`**: 纯运行时的全局容器, 支持 `registerFactory` / `registerSingleton` / `registerLazySingleton`。
- **`injectable`**: 编译期扫注解, 生成一段 `$initGetIt()` 函数, 帮你把那堆 register 调用写好。

如果你项目里只有三五个服务, 手写 `get_it.registerSingleton(ApiClient())` 就够了。
超过十几个依赖, injectable 帮你消灭样板、保持一致性。

## 最小例子

```dart
// services.dart
@singleton
class ClickCounter { ... }

@lazySingleton
class HelloBot {
  HelloBot(this._greeter, this._counter);
  ...
}

// di.dart
final getIt = GetIt.instance;

@InjectableInit(initializerName: r'$initGetIt', asExtension: true)
Future<void> configureDependencies() async {
  getIt.$initGetIt();
}
```

跑 `build_runner`:

```dart
// di.config.dart  (生成, 节选)
extension GetItInjectableX on GetIt {
  GetIt $initGetIt({String? environment, EnvironmentFilter? environmentFilter}) {
    final gh = GetItHelper(this, environment, environmentFilter);
    gh.singleton<ClickCounter>(ClickCounter());
    gh.factory<Greeter>(() => PoliteGreeter(), instanceName: 'polite');
    gh.factory<Greeter>(() => CasualGreeter(), instanceName: 'casual');
    gh.lazySingleton<HelloBot>(() => HelloBot(gh<Greeter>(instanceName: 'polite'), gh<ClickCounter>()));
    return this;
  }
}
```

然后主程序启动前调一次:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

// 用的时候:
final bot = getIt<HelloBot>();
bot.sayHiTo('Alice');
```

## 三种注册类型

| 注解 | 行为 | 场景 |
|------|------|------|
| `@injectable` / `@Injectable()` | **工厂**: 每次 `get<T>()` 都造新实例 | UseCase, ViewModel |
| `@singleton` | **饿汉单例**: `configureDependencies()` 里就 new, 全局一份 | Logger, Config, DB 连接 |
| `@lazySingleton` | **懒汉单例**: 第一次被取才 new, 之后复用 | 较重的服务 (比如 HTTP client) |

## 抽象 + 多实现: `as:` 和 `@Named`

```dart
abstract class Greeter { ... }

@Named('polite')
@Injectable(as: Greeter)
class PoliteGreeter implements Greeter { ... }

@Named('casual')
@Injectable(as: Greeter)
class CasualGreeter implements Greeter { ... }

// 在要注入的地方:
@lazySingleton
class HelloBot {
  HelloBot(@Named('polite') this._greeter, this._counter);
}
```

`as: Greeter` 告诉 injectable "我要按 Greeter 接口暴露, 而不是按具体类"。
`@Named('xxx')` 区分多个实现。get_it 底层对应 `instanceName`。

## 环境 (Environment)

```dart
@Environment('dev')
@Injectable(as: ApiClient)
class FakeApiClient implements ApiClient { ... }

@Environment('prod')
@Injectable(as: ApiClient)
class RealApiClient implements ApiClient { ... }
```

然后:

```dart
await configureDependencies(environment: 'dev');   // 只注册 dev 标签的
```

适合 demo / staging / prod 多套依赖切换, 配合 dart-define 用。

## injectable vs Riverpod: 选哪个?

| 维度 | injectable + get_it | Riverpod |
|------|-------------------|----------|
| 定位 | 依赖注入容器 | 状态管理 + 依赖 |
| 生命周期 | 手动/环境 切分 | Provider 依赖图自动管理, autoDispose |
| Widget 绑定 | 无, 要手动 getIt<X>() | ConsumerWidget / ref.watch, 自动 rebuild |
| 学习成本 | 低, 和其他语言 DI 一致 | 中, 独特概念多 |
| 常见搭档 | bloc, flutter_modular, 纯业务层 | Riverpod 单吃或和 freezed 合 |

实务里两者也能共存: injectable 管 "工具层" (Logger, ApiClient, DbClient), Riverpod 管 "UI/状态层", Provider 的工厂函数里 `ref.read(getIt<ApiClient>())` 取资源。

## 踩坑

1. **忘了 `part 'di.config.dart';` 式 import**: injectable 用的是 **import**, 不是 part。记得加 `import 'di.config.dart';`。
2. **异步初始化**: 某些服务要 `await SomeDb.init()`, 可以给注入类加 `@preResolve` 注解, injectable 会把 init 放到 async 阶段。
3. **循环依赖**: `A(B)` + `B(A)` 会在 `configureDependencies()` 报错, 和普通 DI 一样, 要打破环。
4. **单例不要持有 BuildContext**。
5. **版本兼容**: `injectable_generator` 要和 `build_runner` 版本匹配, 本工程 ^2.6 / ^2.4。

## 练习

1. 加一个 `@singleton class Logger { void log(String msg) => print(msg); }`, 注入到 `HelloBot`, 让每次 `sayHiTo` 前打一行日志。
2. 把 `PoliteGreeter` / `CasualGreeter` 改成 `@Environment('dev')` / `@Environment('prod')`, 然后在 `configureDependencies(environment: 'dev')` 里体验切换。
3. 对比 Riverpod 的 `ref.watch(greeterProvider)` 和 `getIt<Greeter>()`, 思考 "我什么时候该用 Provider, 什么时候该用 getIt"。

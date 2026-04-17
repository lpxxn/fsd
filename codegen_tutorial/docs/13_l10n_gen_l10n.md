# 第 13 章 Flutter 官方 l10n: ARB → AppLocalizations

## 目标

- 用 Flutter 官方的 `gen_l10n` 工具 (本质也是 codegen), 把 ARB 资源文件变成一个 `AppLocalizations` 类。
- 理解占位符 (`{name}`) 和复数 (`plural`) 的处理。
- 对比社区的 `slang` 方案。

## 配置 `l10n.yaml`

工程根放一个 `l10n.yaml`:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/l10n/generated
```

## 准备 ARB 文件

`lib/l10n/app_en.arb` (模板 + 带元信息):

```json
{
  "@@locale": "en",
  "appTitle": "Codegen Tutorial",
  "@appTitle": { "description": "App title shown on the Demo page." },

  "greeting": "Hello, {name}!",
  "@greeting": {
    "placeholders": { "name": { "type": "String", "example": "Alice" } }
  },

  "unreadCount": "{count, plural, =0{No unread messages} =1{1 unread message} other{{count} unread messages}}",
  "@unreadCount": { "placeholders": { "count": { "type": "int" } } }
}
```

`lib/l10n/app_zh.arb` (中文对应):

```json
{
  "@@locale": "zh",
  "appTitle": "代码生成教程",
  "greeting": "你好, {name}!",
  "unreadCount": "{count, plural, =0{没有未读消息} =1{有 1 条未读消息} other{有 {count} 条未读消息}}"
}
```

注意:

- **只在 template 文件 (`app_en.arb`) 里写 `@key` 元信息**, 其他语言只给翻译。
- `plural` 标准语法: `{count, plural, =0{零} =1{一} other{多}}`。

## 跑生成

```bash
flutter gen-l10n
```

它会在 `lib/l10n/generated/` 里生成 3 个文件:

```text
app_localizations.dart          # 抽象基类 + delegate + lookupAppLocalizations
app_localizations_en.dart       # AppLocalizationsEn implements AppLocalizations
app_localizations_zh.dart       # AppLocalizationsZh implements AppLocalizations
```

关键片段:

```dart
abstract class AppLocalizations {
  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String get appTitle;
  String greeting(String name);
  String unreadCount(int count);
}
```

生成的 `AppLocalizationsZh` 用 `intl` 包的 `MessageFormat` 处理 plural, 你完全不用自己写。

## 在 main.dart 里接入

```dart
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/generated/app_localizations.dart';

MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  locale: const Locale('zh'),
  home: ...
);
```

使用:

```dart
final l = AppLocalizations.of(context)!;
Text(l.greeting('Alice'));        // "Hello, Alice!" / "你好, Alice!"
Text(l.unreadCount(5));           // "5 unread messages" / "有 5 条未读消息"
```

## 对比社区方案 slang

`slang` (第三方包) 用的是另一种 codegen 思路: 写 JSON / YAML 文件, 生成一个 `t.home.title` 这种 "嵌套 path" 风格的类。优点:

- 嵌套分类, 代码里 `t.home.greeting(name: 'Alice')` 比 `appLocalizations.greeting('Alice')` 更有组织感。
- 编辑 YAML 比 ARB 顺眼。

缺点:

- 非 Flutter 官方方案。
- 如果团队要接入翻译服务商 (Lokalise / Crowdin) 生态, 他们基本都原生支持 ARB, 对 slang 格式要绕一下。

新项目中选哪个, 取决于团队偏好。本教程用官方 `gen_l10n`。

## 踩坑

1. **`pubspec.yaml` 里必须 `generate: true`** (已配置)。
2. **改 ARB 后忘了 `flutter gen-l10n`** (或 hot restart) → 找不到新 key。
3. **Locale fallback**: 用户设备是 `zh-HK` 但你只提供了 `zh`, Flutter 会按 `languageCode` 回退。
4. **不要手改生成文件**。
5. **`synthetic-package` 已被 Flutter 弃用**, 用 `output-dir` 指定显式路径。

## 在本工程的 Demo

第 13 章 Demo 页给个切换按钮 (zh / en), 实时显示 `greeting('Alice')` 和 `unreadCount(n)`。
用 `Localizations.override` 改当前 locale 而不用重启 app。

## 练习

1. 加一份 `app_ja.arb` 日文版本, 跑 `flutter gen-l10n` 看生成文件变化。
2. 加一个 `welcomeMessage(String name, int days)` 带两个占位符的 key。
3. 读 `lib/l10n/generated/app_localizations_zh.dart` 里 `unreadCount` 的 plural 实现, 想想它背后用的是 `Intl.plural`。

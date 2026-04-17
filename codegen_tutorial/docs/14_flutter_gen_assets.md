# 第 14 章 flutter_gen: 资源强类型访问

## 目标

- 消灭 `Image.asset('assets/images/logo.png')` 这种字符串路径。
- 用 `flutter_gen` 把 `pubspec.yaml` 里声明的所有资源 **编译期** 变成强类型 `Assets.images.logo`。
- 增删图片自动同步, 改路径少一个地方就编译错误。

## 三个步骤

### 1. 在 `pubspec.yaml` 加资源路径 + flutter_gen 配置

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/data/

flutter_gen:
  output: lib/gen/
  line_length: 100
  integrations:
    flutter_svg: false
```

### 2. 放资源

```text
assets/
  images/
    logo.png
  data/
    sample.json
```

### 3. 跑生成

```bash
dart run build_runner build --delete-conflicting-outputs
```

会在 `lib/gen/assets.gen.dart` 里生成:

```dart
class $AssetsImagesGen {
  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');
}

class $AssetsDataGen {
  String get sample => 'assets/data/sample.json';
}

class Assets {
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsDataGen data = $AssetsDataGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);
  Image image({Key? key, ...}) => Image.asset(_assetName, ...);
  String get path => _assetName;
}
```

## 使用

```dart
// 之前:
Image.asset('assets/images/logo.png');
final jsonStr = await rootBundle.loadString('assets/data/sample.json');

// 现在:
Assets.images.logo.image();      // 返回 Image widget
Assets.images.logo.path;         // 拿路径字符串
rootBundle.loadString(Assets.data.sample);
```

## 好处

1. **打错字编译不过**: `Assets.images.lgoo` IDE 立刻报错。
2. **改文件名 / 重构路径**: 只要 `pubspec.yaml` 里路径正确, build 一次, 使用点自动跟着改名。
3. **IDE 自动补全**: 列目录。
4. **自动调整分辨率变体**: 2x / 3x 图片自动聚合成一个 `AssetGenImage`。

## `build.yaml` 选项

全工程级配置放在 `pubspec.yaml` 的 `flutter_gen:` 节, 比如:

```yaml
flutter_gen:
  output: lib/gen/
  line_length: 100
  integrations:
    flutter_svg: true          # 配合 flutter_svg 包, 支持 SvgPicture
    rive: false
  colors:
    inputs:
      - assets/colors.xml      # 生成强类型颜色表
  fonts:
    enabled: true              # 字体资源强类型
```

## 还能做什么

- **颜色**: 给个 XML / JSON, 生成 `AppColors.primary` 这种常量类。
- **字体**: 读 `pubspec.yaml` 里的字体声明, 生成 `FontFamily.montserrat`。
- **SVG**: 配合 `flutter_svg`, `Assets.images.icon.svg()` 直接返回 SvgPicture。
- **Rive / Lottie**: 集成特定包后可以直接 `Assets.animations.xxx.rive()`。

## 踩坑

1. **改 `pubspec.yaml` 或资源文件后忘了重跑 build_runner** → 新资源不在 `Assets.*`。
2. **`flutter_gen_runner` (dev) vs `flutter_gen` (runtime 其实没必要)**: 本工程只依赖 runner, `Assets` 类是生成的纯 Dart, 不需要运行时包。
3. **assets 路径别打错**: `pubspec.yaml` 里的资源路径必须是目录 (带斜杠结尾) 或具体文件。
4. **output 路径**: 我们放 `lib/gen/`, 建议加到 `analysis_options.yaml` 的 `exclude`, 避免 lint 警告 (已配置)。

## 在本工程的 Demo

`lib/chapters/chapter_14_page.dart` 展示:

- `Assets.images.logo.image()` 渲染一张 1x1 示意图片 (Demo 用, 肉眼不可见, 但不报错)。
- 列出所有生成的资源路径 (`Assets.images.values`, `Assets.data.values`)。
- 读 `Assets.data.sample` 文件内容并展示。

## 练习

1. 往 `assets/images/` 加一张真实 PNG 图片, 重跑 build_runner, 在 Demo 页用 `Assets.images.xxx.image()` 显示。
2. 配合 `flutter_svg` 包, 打开 `integrations.flutter_svg: true`, 试试 SVG 生成。
3. 思考: 这个生成器是怎么做到 "扫 `pubspec.yaml` + 扫文件系统" 两个维度数据的? (答: flutter_gen 对应的 builder 除了 `LibraryElement`, 还直接读 package assets, 属于 "非 Dart 代码输入" 型 builder)。

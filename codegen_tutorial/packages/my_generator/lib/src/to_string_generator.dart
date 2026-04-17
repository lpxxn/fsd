import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../my_generator.dart';

/// 读一个标了 `@ToStringGen` 的 class, 生成一份 `_\$XxxToString(...)`。
///
/// 教学重点:
///   1. `GeneratorForAnnotation<T>` 会自动只处理带 T 注解的元素;
///   2. 从 `element` (analyzer 拿到的 ClassElement) 里读字段;
///   3. 拼成字符串返回即可, 就是生成文件的内容 (source_gen 会把多份片段
///      合并到一个 `*.g.dart` part 文件)。
class ToStringGenerator extends GeneratorForAnnotation<ToStringGen> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@ToStringGen 只能用在 class 上。',
        element: element,
      );
    }

    final className = element.name ?? '_Unknown';
    final fields = element.fields
        .where((f) => !f.isStatic && !f.isSynthetic)
        .toList();

    return '''
String _\$${className}ToString($className self) {
  return ${_buildStringExpression(className, fields)};
}
''';
  }

  String _buildStringExpression(String className, List<FieldElement> fields) {
    if (fields.isEmpty) {
      return "'$className()'";
    }
    final inner = fields
        .map((f) => '${f.name}=\${self.${f.name}}')
        .join(', ');
    return "'$className($inner)'";
  }
}

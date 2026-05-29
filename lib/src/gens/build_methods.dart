import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';

Iterable<Method> buildMethods(String className, Iterable<FieldElement> fields) {
  return [
    Method(
      (m) => m
        ..name = 'copyWith'
        ..annotations.add(refer('override'))
        ..returns = refer(className)
        ..optionalParameters.addAll(
          fields.map(
            (field) => Parameter(
              (p) => p
                ..name = field.name!
                ..type = refer('Color?')
                ..named = true,
            ),
          ),
        )
        ..body = Block((b) {
          final buffer = StringBuffer();
          buffer.writeln('return $className(');

          for (final field in fields) {
            buffer.writeln(
              '${field.name}: ${field.name} ?? this.${field.name},',
            );
          }

          buffer.writeln(');');

          b.addExpression(CodeExpression(Code(buffer.toString())));
        }),
    ),
    Method(
      (m) => m
        ..name = 'lerp'
        ..annotations.add(refer('override'))
        ..returns = refer(className)
        ..requiredParameters.addAll([
          Parameter(
            (p) => p
              ..name = 'other'
              ..type = refer('ThemeExtension<$className>?'),
          ),
          Parameter(
            (p) => p
              ..name = 't'
              ..type = refer('double'),
          ),
        ])
        ..body = Block((b) {
          final buffer = StringBuffer();
          buffer.writeln('if (other is! $className) return this;');
          buffer.writeln('return $className(');

          for (final field in fields) {
            buffer.writeln(
              '${field.name}: Color.lerp(${field.name}, other.${field.name}, t)!,',
            );
          }

          buffer.writeln(');');

          b.addExpression(CodeExpression(Code(buffer.toString())));
        }),
    ),
    Method(
      (b) => b
        ..name = 'of'
        ..static = true
        ..returns = refer(className)
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'context'
              ..type = refer('BuildContext'),
          ),
        )
        ..body = Block((b) {
          final buffer = StringBuffer();

          buffer.writeln('return Theme.of(context).extension<$className>()!;');

          b.addExpression(CodeExpression(Code(buffer.toString())));
        }),
    ),
  ];
}

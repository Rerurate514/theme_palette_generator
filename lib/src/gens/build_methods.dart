import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';

Iterable<Method> buildMethods(String className, Iterable<FieldElement> fields) {
  final colorGetters = fields.map((field) => Method((m) => m
    ..name = field.name
    ..type = MethodType.getter
    ..returns = refer('Color'),
  ));

  return [
    ...colorGetters,
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
          final namedArgs = <String, Expression>{};
          for (final field in fields) {
            namedArgs[field.name!] = CodeExpression(
              Code('${field.name} ?? this.${field.name}'),
            );
          }

          b.addExpression(refer(className).call([], namedArgs).returned);
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
          b.statements.add(
            Code('if (other is! $className) return this;'),
          );

          final namedArgs = <String, Expression>{};
          for (final field in fields) {
            namedArgs[field.name!] = CodeExpression(
              Code('Color.lerp(${field.name}, other.${field.name}, t)!'),
            );
          }

          b.addExpression(
            refer(className).call([], namedArgs).returned,
          );
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
        ..body = refer('Theme')
            .property('of')
            .call([refer('context')])
            .property('extension')
            .call([], {}, [refer(className)])
            .nullChecked
            .code,
    ),
  ];
}

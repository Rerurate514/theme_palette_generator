import 'package:code_builder/code_builder.dart';
import 'package:analyzer/dart/element/element.dart';

Iterable<Method> buildMethods(
  String className,
  Iterable<FormalParameterElement> parameters,
) {
  final params = parameters.toList();

  return [
    // abstract getters
    ...params.map(
      (p) => Method(
        (m) => m
          ..name = p.name!
          ..type = MethodType.getter
          ..returns = refer('Color'),
      ),
    ),

    // copyWith
    Method(
      (m) => m
        ..name = 'copyWith'
        ..annotations.add(refer('override'))
        ..returns = refer(className)
        ..optionalParameters.addAll(
          parameters.map(
            (p) => Parameter(
              (p2) => p2
                ..name = p.name!
                ..type = refer('Color?')
                ..named = true,
            ),
          ),
        )
        ..body = refer('_$className').call([], {
          for (final p in parameters)
            p.name!: refer(p.name!).ifNullThen(refer('this').property(p.name!)),
        }).code,
    ),

    // lerp
    Method(
      (m) => m
        ..name = 'lerp'
        ..annotations.add(refer('override'))
        ..returns = refer('ThemeExtension<$className>')
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
        ..body = Block.of([
          Code('if (other is! $className) return this;'),
          refer('_$className')
              .call([], {
                for (final p in parameters)
                  p.name!: refer('Color').property('lerp').call([
                    refer(p.name!),
                    refer('other').property(p.name!),
                    refer('t'),
                  ]).nullChecked,
              })
              .returned
              .statement,
        ]),
    ),

    // toMap
    Method(
      (m) => m
        ..name = 'toMap'
        ..returns = refer('Map<String, Color>')
        ..body = literalMap({
          for (final p in params) literalString(p.name!): refer(p.name!),
        }).returned.statement,
    ),

    // == operator
    Method(
      (m) => m
        ..name = 'operator =='
        ..annotations.add(refer('override'))
        ..returns = refer('bool')
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'other'
              ..type = refer('Object'),
          ),
        )
        ..body = Block.of([
          Code('if (identical(this, other)) return true;'),
          Code('if (other is! $className) return false;'),
          Code(
            'return ${params.map((p) => 'other.${p.name} == ${p.name}').join(' && ')};',
          ),
        ]),
    ),

    // hashCode
    Method(
      (m) => m
        ..name = 'hashCode'
        ..type = MethodType.getter
        ..annotations.add(refer('override'))
        ..returns = refer('int')
        ..body = refer('Object')
            .property('hash')
            .call(params.map((p) => refer(p.name!)))
            .returned
            .statement,
    ),

    // buildTheme
    Method(
      (m) => m
        ..name = 'buildTheme'
        ..returns = refer('ThemeData')
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'base'
              ..named = true
              ..type = refer('ThemeData'),
          ),
        )
        ..body = refer('base')
            .property('copyWith')
            .call([], {
              'extensions': literalList([
                CodeExpression(Code('...base.extensions.values')),
                refer('this'),
              ]),
            })
            .returned
            .statement,
    ),
  ];
}

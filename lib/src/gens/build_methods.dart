import 'package:code_builder/code_builder.dart';
import 'package:analyzer/dart/element/element.dart';

Iterable<Method> buildMethods(String className, Iterable<Element> parameters) {
  final list = <Method>[];

  for (final param in parameters) {
    list.add(Method((m) => m
      ..name = param.name
      ..type = MethodType.getter
      ..returns = refer('Color')));
  }

  list.add(Method((m) => m
    ..name = 'copyWith'
    ..annotations.add(refer('override'))
    ..returns = refer(className)
    ..optionalParameters.addAll(parameters.map((p) => Parameter((p2) => p2
      ..name = p.name!
      ..type = refer('Color?')
      ..named = true)))
    ..body = refer('_$className').call([], {
      for (final p in parameters) p.name!: refer(p.name!).ifNullThen(refer('this').property(p.name!))
    }).code));

  list.add(Method((m) => m
    ..name = 'lerp'
    ..annotations.add(refer('override'))
    ..returns = refer('ThemeExtension<$className>')
    ..requiredParameters.addAll([
      Parameter((p) => p..name = 'other'..type = refer('ThemeExtension<$className>?')),
      Parameter((p) => p..name = 't'..type = refer('double')),
    ])
    ..body = Block.of([
      Code('if (other is! $className) return this;'),
      refer('_$className').call([], {
        for (final p in parameters)
          p.name!: refer('Color')
              .property('lerp')
              .call([refer(p.name!), refer('other').property(p.name!), refer('t')])
              .nullChecked
      }).returned.statement,
    ])));

  list.add(Method((m) => m
    ..name = 'of'
    ..static = true
    ..returns = refer(className)
    ..requiredParameters.add(Parameter((p) => p..name = 'context'..type = refer('BuildContext')))
    ..body = refer('Theme')
        .property('of')
        .call([refer('context')])
        .property('extension')
        .call([])
        .nullChecked
        .returned
        .statement));

  return list;
}

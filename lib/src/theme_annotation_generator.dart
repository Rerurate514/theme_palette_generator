import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:theme_palette_generator/src/annotations.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:theme_palette_generator/src/gens/build_methods.dart';

class ThemeAnnotationGenerator extends GeneratorForAnnotation<ThemePalette> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@ThemePalette annotation can only be applied to a class',
        element: element,
      );
    }

    final className = element.name!;

    if (element.constructors.isEmpty) {
      throw InvalidGenerationSourceError(
        'The class must have at least one constructor.',
        element: element,
      );
    }

    final constructor = element.constructors.firstWhere(
      (c) => c.isFactory,
      orElse: () => throw InvalidGenerationSourceError(
        'The class must have a default factory constructor.',
        element: element,
      ),
    );

    final colorParams = constructor.formalParameters.where(
      (p) => p.type.getDisplayString() == 'Color',
    ).toList();

    final abstractClass = Class(
      (b) => b
        ..name = '_\$$className'
        ..abstract = true
        ..extend = refer('ThemeExtension<$className>')
        ..constructors.add(Constructor((c) => c..constant = true))
        ..methods.addAll(
          buildMethods(className, colorParams)
        ),
    );

    final implClass = Class(
      (b) => b
        ..name = '_$className'
        ..extend = refer(className)
        ..constructors.add(Constructor((c) => c
          ..constant = true
          ..optionalParameters.addAll(colorParams.map((p) => Parameter((p2) => p2
            ..name = p.name!
            ..type = refer('Color')
            ..named = true
            ..required = true)))
          ..initializers.addAll(colorParams.map((p) => refer('this').property(p.name!).assign(refer(p.name!)).code))))
        ..fields.addAll(colorParams.map((p) => Field((f) => f
          ..name = p.name
          ..type = refer('Color')
          ..modifier = FieldModifier.final$
          ..annotations.add(refer('override'))))),
    );

    final emitter = DartEmitter(useNullSafetySyntax: true);
    final abstractCode = abstractClass.accept(emitter).toString();
    final implCode = implClass.accept(emitter).toString();

    final finalCode = '''
$abstractCode

$implCode
''';

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(finalCode);
  }
}

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

    final fields = element.fields.where((field) {
      final typeName = field.type.getDisplayString();
      return typeName == 'Color';
    });

    final themeMixin = Mixin(
      (b) => b
        ..name = '_\$$className'
        ..on = refer('ThemeExtension<$className>')
        ..methods.addAll(
          buildMethods(className, fields)
        ),
    );

    final emitter = DartEmitter(useNullSafetySyntax: true);
    final rawCode = themeMixin.accept(emitter).toString();

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(rawCode);
  }
}

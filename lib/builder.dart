import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:theme_palette_generator/src/theme_annotation_generator.dart';

Builder themePaletteBuilder(BuilderOptions options) {
  return LibraryBuilder(
    ThemeAnnotationGenerator(),
  );
}

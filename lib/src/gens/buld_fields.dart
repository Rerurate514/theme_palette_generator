import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';

Iterable<Field> buildFields(Iterable<FieldElement> fields) {
  return fields.map(
    (field) => Field(
      (f) => f
        ..name = field.name
        ..type = refer('Color')
        ..modifier = FieldModifier.final$,
    ),
  );
}

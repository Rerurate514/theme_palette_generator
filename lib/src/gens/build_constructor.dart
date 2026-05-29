import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';

Constructor buildConstructor(Iterable<FieldElement> fields) {
  return Constructor(
    (c) => c
      ..constant = true
      ..optionalParameters.addAll(
        fields.map(
          (field) => Parameter(
            (p) => p
              ..name = field.name!
              ..toThis = true
              ..required = true
          ),
        ),
      ),
  );
}

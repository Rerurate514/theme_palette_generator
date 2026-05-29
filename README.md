# theme_palette_generator

日本語版 -> https://github.com/Rerurate514/theme_palette_generator/blob/main/README-ja.md

A Flutter package for managing custom colors outside of Dynamic Color.
Useful for projects that need fine-grained brand color management or design systems that Dynamic Color alone can't handle.

Generates `ThemeExtension`-based custom color schemas with a [freezed](https://pub.dev/packages/freezed)-like syntax.

---

## Install
```sh
flutter pub add theme_palette_generator
```

`build_runner` is also required as a dev dependency.

```sh
flutter pub add dev:build_runner
```

---

## Usage
### 1. Define your color schema class
First, create a class that holds your custom color definitions.
The syntax is almost identical to freezed — the key differences are that your class extends `ThemeExtension`, and freezed-specific annotations are not used here.

```dart
import 'package:flutter/material.dart';
import 'package:theme_palette_generator/theme_palette_generator.dart';

part 'your_file_name.theme.g.dart';

@ThemePalette()
sealed class YourClassName extends ThemeExtension<YourClassName> with _$YourClassName {
  const factory YourClassName({
    required Color yourColorName,
  }) = _YourClassName;
}
```

Properties must be of type `Color` (from `package:flutter/material.dart`).
The `part` directive extension must be `.theme.g.dart`.

Here's a real-world example:

```dart
import 'package:flutter/material.dart';
import 'package:theme_palette_generator/theme_palette_generator.dart';

part 'app_color_scheme.theme.g.dart';

@ThemePalette()
sealed class AppColorScheme
    extends ThemeExtension<AppColorScheme>
    with _$AppColorScheme {
  const factory AppColorScheme({
    required Color surfaceSuccess,
    required Color surfaceWarning,
    required Color brandBlue,
    required Color secondaryBrandBlue,

    required Color statusPending,
    required Color statusProcessing,
    required Color statusCompleted,
    required Color statusFailed,
  }) = _AppColorScheme;
}
```

### 2. Run code generation
Once the class is defined, run `build_runner`.

```sh
dart run build_runner build
```

### 3. Define your colors
Define color instances for light and dark themes.

```dart
import 'package:flutter/material.dart';
import 'package:your_app/core/theme/app_color_scheme.dart';

const lightCustomColors = AppColorScheme(
  surfaceSuccess: Color(0xFFE8F5E9),
  surfaceWarning: Color(0xFFFFF3E0),
  brandBlue: Color(0xFF0D47A1),
  secondaryBrandBlue: Color(0xFFD3E4FF),

  statusPending: Color(0xFF9E9E9E),
  statusProcessing: Color(0xFF1976D2),
  statusCompleted: Color(0xFF388E3C),
  statusFailed: Color(0xFFD32F2F),
);

const darkCustomColors = AppColorScheme(
  surfaceSuccess: Color(0xFF1B5E20),
  surfaceWarning: Color(0xFFE65100),
  brandBlue: Color(0xFF2196F3),
  secondaryBrandBlue: Color(0xFFD3E4FF),

  statusPending: Color(0xFF757575),
  statusProcessing: Color(0xFF2196F3),
  statusCompleted: Color(0xFF4CAF50),
  statusFailed: Color(0xFFF44336),
);
```

In the same file, define the `ThemeData` to pass to `MaterialApp`.
`buildTheme()` takes an existing `ThemeData` and returns a new one with your custom colors injected into its `extensions`.

```dart
class AppTheme {
  static ThemeData get light => lightCustomColors.buildTheme(
    ThemeData.light(useMaterial3: true),
  );

  static ThemeData get dark => darkCustomColors.buildTheme(
    ThemeData.dark(useMaterial3: true),
  );
}
```

### 4. Pass to MaterialApp
```dart
return MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  // ...
);
```

### 5. Use colors in your widgets
Access colors via `BuildContext`.

```dart
@override
Widget build(BuildContext context) {
  final theme = context.themePalette;

  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: theme.brandBlue,
    ),
    child: Text("Tap"),
  );
}
```

That's it!

---

## API
### `copyWith`
Creates a new instance with some colors overridden.

```dart
final modified = lightCustomColors.copyWith(brandBlue: Colors.red);
```

### `lerp`
Interpolates between themes during animations. This is intended to be called by the Flutter engine — you generally won't call it directly.

### `toMap`
Converts the color schema to a `Map`.

```dart
final map = lightCustomColors.toMap();
print(map['brandBlue']); // Color(0xFF0D47A1)
```

### `== / hashCode`
Two instances with identical color values are considered equal.

```dart
lightCustomColors == lightCustomColors.copyWith() // true
```

### `buildTheme`
Returns a new `ThemeData` with the custom colors injected into its `extensions`.

```dart
final themeData = lightCustomColors.buildTheme(
  ThemeData.light(useMaterial3: true),
);
```

### `context.themePalette`
Retrieves the current custom color schema from within a widget.

```dart
final theme = context.themePalette;
final color = theme.brandBlue;
```

---

## Internal Structure
```
ThemeExtension
    ↑ extends
_$AppColorScheme (mixin) ← provides copyWith / lerp / toMap / buildTheme
    ↑ mixin
_AppColorScheme (generated class) ← implements AppColorScheme

BuildContext
    ↓ extension
AppColorSchemeBuildContextExtension → provides context.themePalette
```

---

## Dependencies

| Package | Purpose |
|---|---|
| [analyzer](https://pub.dev/packages/analyzer) | Static analysis of Dart code |
| [source_gen](https://pub.dev/packages/source_gen) | Code generation builders |
| [code_builder](https://pub.dev/packages/code_builder) | Fluent Dart code generation |
| [build_runner](https://pub.dev/packages/build_runner) | Build system for code generation |
| [build](https://pub.dev/packages/build) | build_runner-compatible generator authoring |

---

## License
MIT

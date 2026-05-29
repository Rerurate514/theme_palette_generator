# theme_palette_generator
FlutterでDynamic Color以外の独自カラーを扱うときに便利なパッケージです。
ブランドカラーの細かい管理や、Dynamic Colorでは対応しきれないデザインシステムを持つプロジェクトで役立ちます。

[freezed](https://pub.dev/packages/freezed)ライクな書き口で、`ThemeExtension`ベースのカスタムカラースキーマを自動生成します。

---

## Install
```sh
flutter pub add theme_palette_generator
```

依存関係に`build_runner`が必要なので、こちらも導入してください。

```sh
flutter pub add dev:build_runner
```

---

## Usage
### 1. カラースキーマのクラス定義
まず、独自のカラー定義を集めたクラスを作ります。書き口はfreezeとほぼ同じです。
違う点は`ThemeExtension`を継承している点と、freezedの各種アノテーションは存在しない点です。

```dart
import 'package:flutter/material.dart';
import 'package:theme_palette_generator/theme_palette_generator.dart';

part 'ファイル名.theme.g.dart';

@ThemePalette()
sealed class クラス名 extends ThemeExtension<クラス名> with _$クラス名 {
  const factory クラス名({
    required Color 色名,
  }) = _クラス名;
}
```

プロパティの型は`Color`（`package:flutter/material.dart`）のみ対応しています。
`part`ディレクティブの拡張子は`.theme.g.dart`です。

実際に定義するとこんな感じです。

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

### 2. コード生成
クラスを定義したら`build_runner`を走らせます。

```sh
dart run build_runner build
```

### 3. 色の定義
ライトテーマ・ダークテーマそれぞれのカラーインスタンスを定義します。

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

同じファイルに`MaterialApp`へ渡す`ThemeData`も定義します。
`buildTheme()`はThemeDataにカスタムカラーを注入したThemeDataを生成するメソッドです。引数として既存の`ThemeData`を受け取り、`extensions`にカスタムカラーを追加したものを返します。

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

### 4. MaterialAppに渡す
```dart
return MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  // ...
);
```

### 5. Widgetで使う
色を使うときは`BuildContext`を介して行います。

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

これだけです！

---

## API
### `copyWith`
一部の色だけ変えたインスタンスを作成できます。

```dart
final modified = lightCustomColors.copyWith(brandBlue: Colors.red);
```

### `lerp`
アニメーション中にテーマを補間します。Flutterエンジンが呼ぶことを想定しているので、基本的に直接呼ぶことはありません。

### `toMap`
Mapに変換します。

```dart
final map = lightCustomColors.toMap();
print(map['brandBlue']); // Color(0xFF0D47A1)
```

### `== / hashCode`
同じ色の組み合わせなら同一と判定します。

```dart
lightCustomColors == lightCustomColors.copyWith() // true
```

### `buildTheme`
既存の`ThemeData`にカスタムカラーを注入したThemeDataを返します。

```dart
final themeData = lightCustomColors.buildTheme(
  ThemeData.light(useMaterial3: true),
);
```

### `context.themePalette`
Widget内で現在のテーマカラーを取得します。

```dart
final theme = context.themePalette;
final color = theme.brandBlue;
```

---

## 内部構造
```
ThemeExtension
    ↑ extends
_$AppColorScheme (mixin) ← copyWith / lerp / toMap / buildTheme を提供
    ↑ mixin
_AppColorScheme (生成クラス) ← AppColorScheme を implements

BuildContext
    ↓ extension
AppColorSchemeBuildContextExtension → context.themePalette を提供
```

sealed classとfreezeの仕様上の違いによる制約で、`extends`ベースの実装ではコンストラクタをユーザー側のクラスから排除できませんでした。mixinを使うことでこの制約を迂回し、ファクトリだけで完結する実装にしています。

---

## Dependencies

| パッケージ | 用途 |
|---|---|
| [analyzer](https://pub.dev/packages/analyzer) | Dartコードの静的解析 |
| [source_gen](https://pub.dev/packages/source_gen) | コード生成ビルダー |
| [code_builder](https://pub.dev/packages/code_builder) | Dartコードの流れるようなビルド |
| [build_runner](https://pub.dev/packages/build_runner) | ビルドシステム |
| [build](https://pub.dev/packages/build) | build_runner互換ジェネレーター |

---

## License
MIT

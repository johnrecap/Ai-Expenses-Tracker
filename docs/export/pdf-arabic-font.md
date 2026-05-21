# PDF Arabic Font Requirement

PDF export is wired to load `assets/fonts/NotoSansArabic-Regular.ttf` when exported expense rows contain Arabic text so Arabic, English, and numeric content can render with a Unicode-capable font.

Bundled asset:

- Font: Noto Sans Arabic Regular
- Source: Noto Fonts Arabic, `https://notofonts.github.io/arabic/`
- License: SIL Open Font License 1.1
- Target path: `assets/fonts/NotoSansArabic-Regular.ttf`

Verification:

1. Run `flutter gen-l10n`.
2. Run `flutter analyze`.
3. Run `flutter test --reporter expanded --concurrency=1 --timeout 45s test/export/pdf_exporter_arabic_font_test.dart`.
4. Confirm the exported PDF shows Arabic glyphs instead of missing boxes.

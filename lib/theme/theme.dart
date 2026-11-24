import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.danger,
    required this.onDanger,
    required this.storyBackground,
    required this.onStory,
    required this.subtleText,
    required this.brandStart,
    required this.brandEnd,
    required this.onBrand,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color danger;
  final Color onDanger;
  final Color storyBackground;
  final Color onStory;
  final Color subtleText;
  final Color brandStart;
  final Color brandEnd;
  final Color onBrand;

  @override
  AppColorsExtension copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? danger,
    Color? onDanger,
    Color? storyBackground,
    Color? onStory,
    Color? subtleText,
    Color? brandStart,
    Color? brandEnd,
    Color? onBrand,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      storyBackground: storyBackground ?? this.storyBackground,
      onStory: onStory ?? this.onStory,
      subtleText: subtleText ?? this.subtleText,
      brandStart: brandStart ?? this.brandStart,
      brandEnd: brandEnd ?? this.brandEnd,
      onBrand: onBrand ?? this.onBrand,
    );
  }

  @override
  AppColorsExtension lerp(
      covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColorsExtension(
      success: l(success, other.success),
      onSuccess: l(onSuccess, other.onSuccess),
      warning: l(warning, other.warning),
      onWarning: l(onWarning, other.onWarning),
      danger: l(danger, other.danger),
      onDanger: l(onDanger, other.onDanger),
      storyBackground: l(storyBackground, other.storyBackground),
      onStory: l(onStory, other.onStory),
      subtleText: l(subtleText, other.subtleText),
      brandStart: l(brandStart, other.brandStart),
      brandEnd: l(brandEnd, other.brandEnd),
      onBrand: l(onBrand, other.onBrand),
    );
  }
}

class AppTheme {
  AppTheme._();

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double radiusSmall = 10;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 56;
  static const double avatarMd = 44;
  static const double avatarLg = 64;
  static const double logoSize = 88;
  static const double buttonHeight = 52;
  static const double propagandaHeight = 210;
  static const double contentMaxWidth = 720;
  static const double formMaxWidth = 440;
  static const double fabClearance = 96;
  static const double dotSize = 8;
  static const double dotActiveWidth = 22;
  static const double progressHeight = 3;
  static const double spinnerSize = 20;
  static const double spinnerStroke = 2.5;
  static const double colorDot = 36;
  static const double opacityOverlay = 0.62;
  static const double opacityHint = 0.7;
  static const double opacityTrack = 0.3;
  static const double opacityFill = 0.5;
  static const double borderDefault = 1;
  static const double borderSelected = 2;
  static const double borderThick = 3;

  static const Color _brand = Color(0xFF0A7D5A);
  static const Color _accent = Color(0xFFE07A2E);

  /// Cores disponíveis para as campanhas em texto (salvas como hex no servidor).
  static const List<String> campanhaCores = [
    '#0A7D5A',
    '#1565C0',
    '#B3261E',
    '#6A1B9A',
    '#9A4A00',
  ];

  static Color fromHex(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final limpo = hex.replaceFirst('#', '');
    final valor =
        int.tryParse(limpo.length == 6 ? 'FF$limpo' : limpo, radix: 16);
    return valor == null ? fallback : Color(valor);
  }

  /// As 5 fontes que a pessoa pode escolher em Configurações.
  static const List<String> fontes = [
    'Nunito',
    'Roboto',
    'Poppins',
    'Lato',
    'Merriweather',
  ];
  static const String fontePadrao = 'Nunito';
  static const Color corPadrao = _brand;

  /// Opacidade padrão dos "balões" (cartões, abas, formulários) sobre o
  /// plano de fundo. A pessoa ajusta isso em Configurações › Cores e letras.
  static const double opacidadeBalaoPadrao = 0.82;
  static const double opacidadeBalaoMinima = 0.35;

  /// Paleta de cores do app (todas escuras o bastante para texto branco).
  static const List<Color> paletaCores = [
    Color(0xFF0A7D5A),
    Color(0xFF00695C),
    Color(0xFF1565C0),
    Color(0xFF283593),
    Color(0xFF6A1B9A),
    Color(0xFFAD1457),
    Color(0xFFB3261E),
    Color(0xFF9A4A00),
  ];

  /// Segunda cor do degradê: tom vizinho e mais escuro da cor escolhida.
  static Color fimDegrade(Color cor) {
    final h = HSLColor.fromColor(cor);
    return h
        .withHue((h.hue + 35) % 360)
        .withLightness((h.lightness * 0.6).clamp(0.0, 1.0))
        .toColor();
  }

  static Color _escurecer(Color cor, double fator) {
    final h = HSLColor.fromColor(cor);
    return h.withLightness((h.lightness * fator).clamp(0.0, 1.0)).toColor();
  }

  static ThemeData get light => build(Brightness.light);
  static ThemeData get dark => build(Brightness.dark);

  static ThemeData build(
    Brightness brightness, {
    Color cor = corPadrao,
    String fonte = fontePadrao,
    bool degrade = true,
    double opacidadeBalao = opacidadeBalaoPadrao,
  }) =>
      _buildTheme(brightness, cor, fonte, degrade,
          opacidadeBalao.clamp(opacidadeBalaoMinima, 1.0));

  static const _lightColors = AppColorsExtension(
    success: Color(0xFF1B7F4B),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFF8A5300),
    onWarning: Color(0xFFFFFFFF),
    danger: Color(0xFFB3261E),
    onDanger: Color(0xFFFFFFFF),
    storyBackground: Color(0xFF07130F),
    onStory: Color(0xFFFFFFFF),
    subtleText: Color(0xFF55665F),
    brandStart: Color(0xFF0A7D5A),
    brandEnd: Color(0xFF04493A),
    onBrand: Color(0xFFFFFFFF),
  );

  static const _darkColors = AppColorsExtension(
    success: Color(0xFF6FD39A),
    onSuccess: Color(0xFF00391C),
    warning: Color(0xFFFFB95C),
    onWarning: Color(0xFF3D2500),
    danger: Color(0xFFFFB4AB),
    onDanger: Color(0xFF690005),
    storyBackground: Color(0xFF07130F),
    onStory: Color(0xFFFFFFFF),
    subtleText: Color(0xFFA6B8B0),
    brandStart: Color(0xFF0A6B4E),
    brandEnd: Color(0xFF032E25),
    onBrand: Color(0xFFFFFFFF),
  );

  static ThemeData _buildTheme(Brightness brightness, Color cor, String fonte,
      bool degrade, double opacidadeBalao) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: cor,
      brightness: brightness,
      tertiary: _accent,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final nomeFonte = fontes.contains(fonte) ? fonte : fontePadrao;
    final textTheme =
        GoogleFonts.getTextTheme(nomeFonte, base.textTheme).copyWith(
      headlineSmall: GoogleFonts.getFont(nomeFonte,
          textStyle: base.textTheme.headlineSmall,
          fontWeight: FontWeight.w800),
      titleLarge: GoogleFonts.getFont(nomeFonte,
          textStyle: base.textTheme.titleLarge, fontWeight: FontWeight.w800),
      titleMedium: GoogleFonts.getFont(nomeFonte,
          textStyle: base.textTheme.titleMedium, fontWeight: FontWeight.w700),
    );
    final inicio = isDark ? _escurecer(cor, 0.85) : cor;
    final fim = degrade
        ? (isDark ? _escurecer(fimDegrade(cor), 0.8) : fimDegrade(cor))
        : inicio;
    final appColors = (isDark ? _darkColors : _lightColors)
        .copyWith(brandStart: inicio, brandEnd: fim);
    final shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium));

    return base.copyWith(
      textTheme: textTheme,
      // Transparente para a imagem de fundo (dia/noite) aparecer atrás de tudo.
      scaffoldBackgroundColor: Colors.transparent,
      extensions: [appColors],
      appBarTheme: AppBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.primary),
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLowest.withValues(alpha: opacidadeBalao),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: BorderSide(color: scheme.outlineVariant, width: borderDefault),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerHighest
            .withValues(alpha: opacityFill * opacidadeBalao),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingMd, vertical: spacingMd),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: scheme.primary, width: borderSelected),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, buttonHeight),
          shape: shape,
          textStyle: textTheme.titleMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, buttonHeight),
          shape: shape,
          textStyle: textTheme.titleSmall,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            scheme.surfaceContainerLowest.withValues(alpha: opacidadeBalao),
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall
            ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: scheme.surface.withValues(alpha: opacidadeBalao),
      ),
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}

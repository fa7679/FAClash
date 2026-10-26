import 'dart:ui' show ImageFilter;

import 'package:fl_clash/providers/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'shape.dart';

/// Shared "future glass" design tokens.
///
/// The app and the website agree on the same named values: a deep
/// space-indigo base in dark mode, frosted white glass in light mode, soft
/// indigo glows and thin rims. Keep `docs/index.html` in sync when changing
/// these numbers.
abstract final class GlassTokens {
  /// Frosted blur strength. Past ~24 the page underneath smears into one
  /// flat wash instead of glass, so this is the ceiling, not a starting point.
  static const double blur = 22;

  /// Tint of the glass bar itself (the navigation dock).
  static double barTint(Brightness brightness) =>
      brightness == Brightness.dark ? 0.30 : 0.24;

  /// Top-lit white highlight that keeps glass readable over a flat page.
  static double sheen(Brightness brightness) =>
      brightness == Brightness.dark ? 0.07 : 0.12;

  /// Bottom dark edge fading upward.
  static const double edge = 0.05;

  /// Stronger translucent surface for floating layers (popups, sheets) that
  /// must carry readable text: alpha >= 0.72 per the contrast rule.
  static Color fillStrong(ColorScheme colorScheme) =>
      switch (colorScheme.brightness) {
        Brightness.dark => const Color(0xFF1C1F30).withValues(alpha: 0.72),
        Brightness.light => Colors.white.withValues(alpha: 0.72),
      };

  /// 1px rim around a glass surface; slightly indigo while hovered.
  static Color rim(ColorScheme colorScheme, {bool hovered = false}) {
    if (hovered) {
      return colorScheme.brightness == Brightness.dark
          ? const Color(0xFF8188F8).withValues(alpha: 0.45)
          : const Color(0xFF6366F1).withValues(alpha: 0.45);
    }
    return colorScheme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFF141828).withValues(alpha: 0.10);
  }

  /// Soft radial glow painted once behind the content area.
  static Color glowPrimary(Brightness brightness) =>
      brightness == Brightness.dark
      ? const Color(0x296366F1)
      : const Color(0x1A6366F1);

  static Color glowSecondary(Brightness brightness) =>
      brightness == Brightness.dark
      ? const Color(0x1A8188F8)
      : const Color(0x128188F8);
}

/// A reusable glass assembly: outer shadow, clip, backdrop blur, translucent
/// surface, top sheen, bottom edge and a rim — generalized from the
/// navigation dock so popups and sheets share the same material.
///
/// When the glass setting is off the surface degrades to an opaque M3
/// container and every extra layer is dropped.
/// Propagates the glass setting down the tree, including overlay routes
/// that live below the MaterialApp builder. Absent (bare test harnesses) it
/// reads as off, so surfaces render exactly like the plain M3 baseline.
class GlassScope extends InheritedWidget {
  const GlassScope({super.key, required this.enabled, required super.child});

  final bool enabled;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlassScope>()?.enabled ??
      false;

  @override
  bool updateShouldNotify(GlassScope oldWidget) => enabled != oldWidget.enabled;
}

/// Reads the glass setting from a provider inside a live scope.
bool glassEnabledOf(WidgetRef ref) {
  return ref.watch(
    themeSettingProvider.select(
      (state) => state.glassEnabled && !state.pureBlack,
    ),
  );
}

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.shape = AppShape.full,
    this.shadows,
    this.blur = GlassTokens.blur,
    this.fillColor,
    this.sheen = true,
    this.edge = true,
    this.rimColor,
  });
  final Widget child;
  final RoundedSuperellipseBorder shape;
  final List<BoxShadow>? shadows;

  /// Base surface color. When null [child] is expected to provide its own
  /// (e.g. the dock bar Material).
  final Color? fillColor;
  final double blur;
  final bool sheen;
  final bool edge;

  /// Rim color; defaults to [GlassTokens.rim]. The dock passes its own
  /// onSurface-based rim to stay visually identical to before.
  final Color? rimColor;

  @override
  Widget build(BuildContext context) {
    final glassEnabled = GlassScope.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    if (!glassEnabled) {
      return DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          color: colorScheme.surfaceContainerLow,
          shadows: shadows,
        ),
        child: child,
      );
    }
    final Widget surface = fillColor != null
        ? Material(color: fillColor, shape: shape, child: child)
        : child;
    return DecoratedBox(
      // Outside the clip: a shadow painted inside one is cut away at the
      // shape's edge.
      decoration: ShapeDecoration(shape: shape, shadows: shadows),
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Stack(
            children: [
              surface,
              if (sheen)
                IgnorePointer(
                  child: SizedBox.expand(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, 0.6],
                          colors: [
                            Colors.white.withValues(
                              alpha: GlassTokens.sheen(colorScheme.brightness),
                            ),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (edge)
                IgnorePointer(
                  child: SizedBox.expand(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0, 0.4],
                          colors: [
                            colorScheme.onSurface.withValues(
                              alpha: GlassTokens.edge,
                            ),
                            colorScheme.onSurface.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              IgnorePointer(
                child: SizedBox.expand(
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: shape.copyWith(
                        side: BorderSide(
                          color: rimColor ?? GlassTokens.rim(colorScheme),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

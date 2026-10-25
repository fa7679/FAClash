/// Features whose code stays but that may ship switched off. A disabled feature
/// hides its setting and ignores the stored value, so switching it back on
/// restores what the user had chosen.
///
/// [sidebarBlur] is on: without it the window never asks the platform for a
/// backdrop, and every translucent surface — the sidebar, the header — paints
/// over an opaque window instead, which reads as "no glass at all". Windows 10
/// needs the undocumented accent call for it, so the runtime probe in
/// `setBlur` still has the final say.
class Feature {
  const Feature({
    this.sidebarBlur = const bool.fromEnvironment(
      'FEATURE_SIDEBAR_BLUR',
      defaultValue: true,
    ),
  });

  final bool sidebarBlur;
}

Feature feature = const Feature();

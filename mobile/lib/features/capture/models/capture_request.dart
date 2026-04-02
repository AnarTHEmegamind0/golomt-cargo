enum CaptureThemeVariant { light, dark }

enum CaptureStatePreset { defaultState, loading, error, empty }

class CaptureRequest {
  const CaptureRequest({
    required this.screenId,
    required this.theme,
    required this.state,
  });

  final String screenId;
  final CaptureThemeVariant theme;
  final CaptureStatePreset state;

  static CaptureRequest fromUri(Uri uri) {
    final screenId = (uri.queryParameters['screen'] ?? 'index').trim();
    final themeRaw = (uri.queryParameters['theme'] ?? 'light').trim();
    final stateRaw = (uri.queryParameters['state'] ?? 'default').trim();

    return CaptureRequest(
      screenId: screenId.isEmpty ? 'index' : screenId,
      theme: switch (themeRaw) {
        'dark' => CaptureThemeVariant.dark,
        _ => CaptureThemeVariant.light,
      },
      state: switch (stateRaw) {
        'loading' => CaptureStatePreset.loading,
        'error' => CaptureStatePreset.error,
        'empty' => CaptureStatePreset.empty,
        _ => CaptureStatePreset.defaultState,
      },
    );
  }
}

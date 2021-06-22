import 'dart:ui';

import '../context.dart';
import 'light_theme.dart';
import 'theme_reader.dart';

class MapTheme {
  final String id;
  final List<ThemeLayer> layers;
  MapTheme({required this.id, required this.layers});

  static MapTheme light() => ThemeReader().read(lightThemeData());

  MapTheme atZoom(double zoom) {
    return MapTheme(
        id: this.id,
        layers:
            this.layers.where((layer) => _matchesZoom(zoom, layer)).toList());
  }

  bool _matchesZoom(double zoom, ThemeLayer layer) =>
      (zoom >= (layer.minzoom ?? -1)) && (zoom <= (layer.maxzoom ?? 100));
}

enum ThemeLayerType { fill, line, symbol, background, unsupported }

abstract class ThemeLayer {
  final String id;
  final ThemeLayerType type;
  final double? minzoom;
  final double? maxzoom;

  ThemeLayer(
    this.id,
    this.type, {
    required this.minzoom,
    required this.maxzoom,
  });

  void render(Context context, Size size);
}

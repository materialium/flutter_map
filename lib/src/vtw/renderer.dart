import 'dart:ui';

import 'package:map/map.dart';

import 'context.dart';
import 'features/feature_renderer.dart';
import 'themes/theme.dart';

class Renderer {
  final MapTheme theme;

  final featureRenderer = FeatureDispatcher();

  Renderer({required this.theme});

  /// renders the given tile to the canvas
  ///
  /// [zoomScaleFactor] the 1-dimensional scale at which the tile is being
  ///        rendered. If the tile is being rendered at twice it's normal size
  ///        along the x-axis, the zoomScaleFactor would be 2. 1.0 indicates that
  ///        no scaling is being applied.
  /// [zoom] the current zoom level, which is used to filter theme layers
  ///        via `minzoom` and `maxzoom`. Value must be >= 0 and <= 24
  void render(
    Canvas canvas,
    VectorTile tile, {
    required double zoomScaleFactor,
    required double zoom,
    required Size size,
  }) {
    final tileClip = Rect.fromLTWH(0, 0, size.width, size.height);
    final context =
        Context(canvas, featureRenderer, tile, zoomScaleFactor, zoom, tileClip);
    final effectiveTheme = theme.atZoom(zoom);
    effectiveTheme.layers.forEach((themeLayer) {
      themeLayer.render(context, size);
    });
  }
}

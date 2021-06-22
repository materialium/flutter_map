import 'dart:ui';

import 'package:map/map.dart';

import '../constants.dart';
import '../context.dart';
import '../themes/style.dart';
import '../themes/theme.dart';
import '../vector_tile_extensions.dart';
import 'feature_renderer.dart';

class LineRenderer extends FeatureRenderer {
  @override
  void render(Context context, ThemeLayerType layerType, Style style,
      Layer layer, Feature feature) {
    if (style.linePaint == null) {
      // logger.warn(() =>
      //     'line does not have a line paint for vector tile layer ${layer.name}');
      return;
    }
    final lines = feature.decodeLines();
    if (lines != null) {
      final path = Path();
      lines.forEach((line) {
        line.asMap().forEach((index, point) {
          if (point.length < 2) {
            throw Exception('invalid point ${point.length}');
          }
          final x = point[0] * tileSize;
          final y = point[1] * tileSize;
          if (index == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        });
      });
      if (!_isWithinClip(context, path)) {
        return;
      }
      var effectivePaint = style.linePaint!.paint(zoom: context.zoom);
      if (effectivePaint != null) {
        if (context.zoomScaleFactor > 1.0) {
          effectivePaint.strokeWidth =
              effectivePaint.strokeWidth / context.zoomScaleFactor;
        }
        context.canvas.drawPath(path, effectivePaint);
      }
    }
  }

  bool _isWithinClip(Context context, Path path) =>
      context.tileClip.overlaps(path.getBounds());
}

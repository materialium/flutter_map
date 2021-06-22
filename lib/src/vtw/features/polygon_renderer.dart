import 'package:map/map.dart';

import 'dart:ui';

import '../context.dart';
import '../themes/style.dart';
import '../themes/theme.dart';

import 'feature_renderer.dart';

class PolygonRenderer extends FeatureRenderer {
  PolygonRenderer();
  @override
  void render(Context context, ThemeLayerType layerType, Style style,
      Layer layer, Feature feature, Size size) {
    if (style.fillPaint == null && style.outlinePaint == null) {
      // logger.warn: polygon does not have a fill paint or an outline paint.
      return;
    }

    final geometry = feature.geometry;

    if (geometry is PolygonGeometry) {
      final coordinates = geometry.coordinates;
      _renderPolygon(context, style, layer, coordinates, size);
    } else if (geometry is MultiPolygonGeometry) {
      final polygons = geometry.coordinates;
      polygons?.forEach((coordinates) {
        _renderPolygon(context, style, layer, coordinates, size);
      });
    } else {
      // logger.warn: not implemented.
    }
  }

  void _renderPolygon(Context context, Style style, Layer layer,
      List<List<List<double>>> coordinates, Size size) {
    final path = Path();
    coordinates.forEach((ring) {
      ring.asMap().forEach((index, point) {
        if (point.length < 2) {
          throw Exception('invalid point ${point.length}');
        }
        final x = point[0] * size.width;
        final y = point[1] * size.height;
        if (index == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        if (index == (ring.length - 1)) {
          path.close();
        }
      });
    });
    if (!_isWithinClip(context, path)) {
      return;
    }
    final fillPaint = style.fillPaint == null
        ? null
        : style.fillPaint!.paint(zoom: context.zoom);
    if (fillPaint != null) {
      context.canvas.drawPath(path, fillPaint);
    }
    final outlinePaint = style.outlinePaint == null
        ? null
        : style.outlinePaint!.paint(zoom: context.zoom);
    if (outlinePaint != null) {
      context.canvas.drawPath(path, outlinePaint);
    }
  }

  bool _isWithinClip(Context context, Path path) =>
      context.tileClip.overlaps(path.getBounds());
}

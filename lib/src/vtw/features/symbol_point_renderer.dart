import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:map/map.dart' as map;

import 'text_abbreviator.dart';
import 'text_renderer.dart';
import '../vector_tile_extensions.dart';
import 'feature_renderer.dart';

import '../context.dart';

import '../themes/style.dart';
import '../themes/theme.dart';

class SymbolPointRenderer extends FeatureRenderer {
  @override
  void render(Context context, ThemeLayerType layerType, Style style,
      map.Layer layer, map.Feature feature, Size size) {
    final textPaint = style.textPaint;
    final textLayout = style.textLayout;
    if (textPaint == null || textLayout == null) {
      //logger.warn(() => 'point does not have a text paint or layout');
      return;
    }
    final points = feature.decodePoints();
    if (points != null) {
      //logger.log(() => 'rendering points');
      final text = textLayout.text(feature);
      if (text != null) {
        final abbreviated = TextAbbreviator().abbreviate(text);
        final textRenderer = TextRenderer(context, style, abbreviated);
        points.forEach((point) {
          points.forEach((point) {
            if (point.length < 2) {
              throw Exception('invalid point ${point.length}');
            }
            final x = point[0] * size.width;
            final y = point[1] * size.height;
            final box = textRenderer.labelBox(Offset(x, y));
            if (box != null && !context.labelSpace.isOccupied(box)) {
              if (context.tileClip.overlaps(box)) {
                context.labelSpace.occupy(box);
                textRenderer.render(Offset(x, y));
              }
            }
          });
        });
      } else {
        //logger.warn(() => 'point with no text');
      }
    }
  }
}

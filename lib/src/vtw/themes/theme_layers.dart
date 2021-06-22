import 'dart:ui';

import 'package:map/map.dart';

import 'selector.dart';

import '../constants.dart';
import '../context.dart';
import 'style.dart';
import 'theme.dart';

class DefaultLayer extends ThemeLayer {
  final LayerSelector selector;
  final Style style;

  DefaultLayer(String id, ThemeLayerType type,
      {required this.selector,
      required this.style,
      required double? minzoom,
      required double? maxzoom})
      : super(id, type, minzoom: minzoom, maxzoom: maxzoom);

  @override
  void render(Context context) {
    selector.select(context.tile.layers).forEach((layer) {
      selector.features(layer.features).forEach((feature) {
        context.featureRenderer.render(context, type, style, layer, feature);
        _releaseMemory(feature);
      });
    });
  }

  void _releaseMemory(Feature feature) {
//
  }
}

class BackgroundLayer extends ThemeLayer {
  final Color fillColor;

  BackgroundLayer(String id, this.fillColor)
      : super(id, ThemeLayerType.background, minzoom: 0, maxzoom: 24);

  @override
  void render(Context context) {
    //context.logger.log(() => 'rendering $id');
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;
    context.canvas.drawRect(
        Rect.fromLTRB(0, 0, tileSize.toDouble(), tileSize.toDouble()), paint);
  }
}

import 'dart:ui';

import 'package:map/map.dart';
import 'features/label_space.dart';

import 'features/feature_renderer.dart';

class Context {
  final Canvas canvas;
  final FeatureDispatcher featureRenderer;
  final VectorTile tile;
  final double zoomScaleFactor;
  final double zoom;
  final Rect tileClip;
  final LabelSpace labelSpace = LabelSpace();

  Context(
    this.canvas,
    this.featureRenderer,
    this.tile,
    this.zoomScaleFactor,
    this.zoom,
    this.tileClip,
  );
}

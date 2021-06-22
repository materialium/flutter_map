import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:map/src/vt/vector_tile.dart';
import 'vtw/renderer.dart';
import 'vtw/themes/theme.dart';

final _renderer = Renderer(theme: MapTheme.light());

/// Render object widget with a [RenderVectorTile] inside.
class VectorTileRenderObjectWidget extends SingleChildRenderObjectWidget {
  final VectorTile tile;

  const VectorTileRenderObjectWidget({
    required Widget child,
    required this.tile,
    Key? key,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderVectorTile()..tile = tile;
  }

  @override
  void updateRenderObject(BuildContext context, RenderVectorTile renderObject) {
    bool needsPaint = false;
    //bool needsLayout = false;

    if (renderObject.tile != tile) {
      renderObject.tile = tile;
      //needsLayout = true;
      needsPaint = true;
    }

    // if (needsLayout) {
    //   renderObject.markNeedsLayout();
    // }
    if (needsPaint) {
      renderObject.markNeedsPaint();
    }

    super.updateRenderObject(context, renderObject);
  }
}

/// RenderBox for [Map].
class RenderVectorTile extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  VectorTile? tile;

  @override
  bool hitTestSelf(Offset position) => false;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {}

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    size = constraints.biggest;

    if (child != null) {
      child!.layout(BoxConstraints.tight(size), parentUsesSize: false);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }

    if (tile != null) {
      final canvas = context.canvas;

      //canvas.save();
      //canvas.scale(scale.toDouble(), scale.toDouble());
      _renderer.render(canvas, tile!, zoomScaleFactor: 4, zoom: 15, size: size);
      //canvas.restore();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:map/src/vt/vector_tile.dart';

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
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}

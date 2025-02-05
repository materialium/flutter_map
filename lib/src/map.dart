import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';

/// The signature of the [Map] builder function.
typedef MapTileBuilder = Widget Function(
    BuildContext context, int x, int y, int z);

class Map extends StatefulWidget {
  final MapController controller;
  final MapTileBuilder builder;

  Map({
    Key? key,
    required this.builder,
    required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapState();
}

class _MapState extends State<Map> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _build);
  }

  Widget _build(BuildContext context, BoxConstraints constraints) {
    final controller = widget.controller;
    final tileSize = controller.tileSize;
    final size = constraints.biggest;
    final projection = controller.projection;

    final screenWidth = size.width;
    final screenHeight = size.height;

    final centerX = screenWidth / 2.0;
    final centerY = screenHeight / 2.0;

    final scale = pow(2.0, controller._zoom);

    final norm = projection.fromLngLatToTileIndex(controller._center);
    final ttl = TileIndex(norm.x * tileSize * scale, norm.y * tileSize * scale);

    final fixedZoom = (controller._zoom + 0.0000001).toInt();
    final fixedPowZoom = pow(2, fixedZoom);

    final centerTileIndexX = (norm.x * fixedPowZoom).floor();
    final centerTileIndexY = (norm.y * fixedPowZoom).floor();

    final scaleValue = pow(2.0, (controller._zoom % 1));
    final tileSizeScaled = tileSize * scaleValue;
    final numGrids = pow(2.0, controller._zoom).floor();

    final numTilesX = (screenWidth / tileSize / 2.0).ceil();
    final numTilesY = (screenHeight / tileSize / 2.0).ceil();

    final children = <Widget>[];

    for (int i = centerTileIndexX - numTilesX;
        i <= centerTileIndexX + numTilesX;
        i++) {
      if (i < 0 || i >= numGrids) {
        continue;
      }

      for (int j = centerTileIndexY - numTilesY;
          j <= centerTileIndexY + numTilesY;
          j++) {
        if (j < 0 || j >= numGrids) {
          continue;
        }

        final ox = (i * tileSizeScaled) + centerX - ttl.x;
        final oy = (j * tileSizeScaled) + centerY - ttl.y;

        final child = Positioned(
          width: tileSizeScaled.ceilToDouble(),
          height: tileSizeScaled.ceilToDouble(),
          left: ox.floorToDouble(),
          top: oy.floorToDouble(),
          child: widget.builder
              .call(context, i, j, (controller._zoom + 0.0000001).floor()),
        );

        children.add(child);
      }
    }

    final stack = Stack(children: children);

    return stack;
  }
}

/// A controller to modify the [center] and [zoom] of the [Map].
class MapController extends ChangeNotifier {
  MapController({
    required LatLng location,
    double zoom: 14,
    this.projection: const EPSG4326(),
    this.tileSize: 256,
  })  : _center = location,
        _zoom = zoom;

  LatLng _center;
  double _zoom;

  /// Dimention of the image received/downloaded from the tile source.
  double tileSize;

  /// [Projection] helps with converting [LatLng] to [TileIndex] and vice-versa.
  final Projection projection;

  /// Drags the map by [dx], [dy] pixels.
  void drag(double dx, double dy) {
    var scale = pow(2.0, _zoom);
    final mon = projection.fromLngLatToTileIndex(_center);

    mon.x -= (dx / tileSize) / scale;
    mon.y -= (dy / tileSize) / scale;

    center = projection.fromTileIndexToLngLat(mon);
  }

  /// Gets current center of the [Map].
  LatLng get center {
    return _center;
  }

  /// Sets current center of the [Map].
  set center(LatLng center) {
    _center = center;
    notifyListeners();
  }

  /// Gets current zoom of the [Map].
  double get zoom {
    return _zoom;
  }

  /// Sets current zoom of the [Map].
  set zoom(double zoom) {
    _zoom = zoom;
    notifyListeners();
  }
}

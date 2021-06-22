import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

class VectorMapPage extends StatefulWidget {
  @override
  _VectorMapPageState createState() => _VectorMapPageState();
}

class _VectorMapPageState extends State<VectorMapPage> {
  final controller = MapController(
    location: LatLng(35.68, 51.41),
  );

  void _gotoDefault() {
    controller.center = LatLng(35.68, 51.41);
    setState(() {});
  }

  void _onDoubleTap() {
    controller.zoom += 0.5;
    setState(() {});
  }

  Offset? _dragStart;
  double _scaleStart = 1.0;
  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      controller.zoom += 0.02;
      setState(() {});
    } else if (scaleDiff < 0) {
      controller.zoom -= 0.02;
      setState(() {});
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _dragStart = now;
      controller.drag(diff.dx, diff.dy);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vector Map'),
      ),
      body: MapLayoutBuilder(
        controller: controller,
        builder: (context, transformer) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: _onDoubleTap,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  final delta = event.scrollDelta;

                  controller.zoom -= delta.dy / 1000.0;
                  setState(() {});
                }
              },
              child: Map(
                controller: controller,
                builder: (context, x, y, z) {
                  return Tile();
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _gotoDefault,
        tooltip: 'My Location',
        child: Icon(Icons.my_location),
      ),
    );
  }
}

class Tile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TileState();
  }
}

class _TileState extends State<Tile> {
  VectorTile? tile;

  @override
  void initState() {
    super.initState();

    _load();
  }

  void _load() async {
    final data =
        await DefaultAssetBundle.of(context).load('assets/sample_tile.pbf');

    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    this.tile = VectorTile.fromBytes(bytes);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tile == null) {
      return CircularProgressIndicator();
    }
    return Container(
        decoration: BoxDecoration(color: Colors.black45),
        child: CustomPaint(
          size: Size(512, 512),
          painter: TilePainter(tile!, scale: 2),
        ));
  }
}

class TilePainter extends CustomPainter {
  final int scale;
  final VectorTile tile;
  final _renderer = Renderer(theme: MapTheme.light());
  TilePainter(this.tile, {required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    _renderer.render(canvas, tile,
        zoomScaleFactor: pow(2, scale).toDouble(), zoom: 15, size: size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

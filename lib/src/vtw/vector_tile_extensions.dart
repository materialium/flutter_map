import 'package:map/map.dart';

extension FeatureExtension on Feature {
  String? stringProperty(String name) {
    if (!properties.containsKey(name)) {
      return null;
    }

    return properties[name]!.stringValue;
  }

  GeometryType? get type {
    if (geometry is PointGeometry) {
      return GeometryType.point;
    }

    if (geometry is MultiPointGeometry) {
      return GeometryType.multiPoint;
    }

    if (geometry is LineStringGeometry) {
      return GeometryType.lineString;
    }

    if (geometry is MultiLineStringGeometry) {
      return GeometryType.multiLineString;
    }

    if (geometry is PolygonGeometry) {
      return GeometryType.polygon;
    }

    if (geometry is MultiPolygonGeometry) {
      return GeometryType.multiPolygon;
    }

    return null;
  }

  List<List<List<double>>>? decodeLines() {
    final geometry = this.geometry;

    if (geometry is LineStringGeometry) {
      return [geometry.coordinates];
    } else if (geometry is MultiLineStringGeometry) {
      return geometry.coordinates;
    } else {
      // logger.warm: not implemented.
      return null;
    }
  }

  List<List<double>>? decodePoints() {
    final geometry = this.geometry;

    if (geometry is PointGeometry) {
      return [geometry.coordinates];
    } else if (geometry is MultiPointGeometry) {
      return geometry.coordinates;
    } else {
      // logger.warn: not implemented.
      return null;
    }
  }
}

extension GeometryExtension on Geometry {
  GeometryType get type {
    final geometry = this;

    if (geometry is PointGeometry) {
      return GeometryType.point;
    }

    if (geometry is MultiPointGeometry) {
      return GeometryType.multiPoint;
    }

    if (geometry is LineStringGeometry) {
      return GeometryType.lineString;
    }

    if (geometry is MultiLineStringGeometry) {
      return GeometryType.multiLineString;
    }

    if (geometry is PolygonGeometry) {
      return GeometryType.polygon;
    }

    if (geometry is MultiPolygonGeometry) {
      return GeometryType.multiPolygon;
    }

    return GeometryType.unknown;
  }
}

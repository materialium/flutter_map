import 'dart:ui';

import 'theme_function.dart';
import 'theme_function_model.dart';

import 'color_parser.dart';

import 'style.dart';

class PaintStyle {
  final String id;
  final PaintingStyle paintingStyle;
  final DoubleZoomFunction opacity;
  final DoubleZoomFunction strokeWidth;
  final ColorZoomFunction color;

  PaintStyle({
    required this.id,
    required this.paintingStyle,
    required this.opacity,
    required this.strokeWidth,
    required this.color,
  });

  Paint? paint({required double zoom}) {
    final color = this.color(zoom);
    if (color == null) {
      return null;
    }
    final opacity = this.opacity(zoom);
    if (opacity != null && opacity <= 0) {
      return null;
    }
    final paint = Paint()
      ..style = paintingStyle
      ..color = color;
    if (opacity != null) {
      paint.color = color.withOpacity(opacity);
    }
    if (paintingStyle == PaintingStyle.stroke) {
      final strokeWidth = this.strokeWidth(zoom);
      if (strokeWidth == null) {
        return null;
      }
      paint.strokeWidth = strokeWidth;
    }
    return paint;
  }
}

class PaintFactory {
  PaintStyle? create(String id, PaintingStyle style, String prefix, paint,
      {double? defaultStrokeWidth = 1.0}) {
    if (paint == null) {
      return null;
    }
    final color = ColorParser.parse(paint['$prefix-color']);
    if (color == null) {
      return null;
    }
    final opacity = _toDouble(paint['$prefix-opacity']);
    final strokeWidth = _toDouble(paint['$prefix-width']);
    return PaintStyle(
      id: id,
      paintingStyle: style,
      opacity: opacity,
      strokeWidth: (zoom) => strokeWidth(zoom) ?? defaultStrokeWidth,
      color: color,
    );
  }

  DoubleZoomFunction _toDouble(doubleSpec) {
    if (doubleSpec is num) {
      final value = doubleSpec.toDouble();
      return (zoom) => value;
    }
    if (doubleSpec is Map) {
      final model = DoubleFunctionModelFactory().create(doubleSpec);
      if (model != null) {
        return (zoom) => DoubleThemeFunction().exponential(model, zoom);
      }
    }
    return (_) => null;
  }
}

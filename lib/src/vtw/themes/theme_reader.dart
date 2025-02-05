import 'package:flutter/painting.dart';
import 'text_halo_factory.dart';

import 'color_parser.dart';
import 'paint_factory.dart';
import 'selector_factory.dart';
import 'style.dart';
import 'theme.dart';
import 'dart:core';

import 'theme_function.dart';
import 'theme_function_model.dart';
import 'theme_layers.dart';
import '../vector_tile_extensions.dart';

class ThemeReader {
  MapTheme read(Map<String, dynamic> json) {
    final id = json['id'] ?? 'default';
    final layers = json['layers'] as List<dynamic>;
    final themeLayers = layers
        .map((layer) => _toThemeLayer(layer))
        .whereType<ThemeLayer>()
        .toList();
    return MapTheme(id: id, layers: themeLayers);
  }
}

ThemeLayer? _toThemeLayer(Map<String, dynamic> jsonLayer) {
  final visibility = jsonLayer['visibility'];
  if (visibility == 'none') {
    return null;
  }
  final type = jsonLayer['type'];
  if (type == 'background') {
    return _toBackgroundTheme(jsonLayer);
  } else if (type == 'fill') {
    return _toFillTheme(jsonLayer);
  } else if (type == 'line') {
    return _toLineTheme(jsonLayer);
  } else if (type == 'symbol') {
    return _toSymbolTheme(jsonLayer);
  }
  //logger.warn(() => 'theme layer type $type not implemented');
  return null;
}

ThemeLayer? _toBackgroundTheme(Map<String, dynamic> jsonLayer) {
  final backgroundColor =
      ColorParser.toColor(jsonLayer['paint']?['background-color']);
  if (backgroundColor != null) {
    return BackgroundLayer(jsonLayer['id'] ?? _unknownId, backgroundColor);
  }
  return null;
}

ThemeLayer? _toFillTheme(Map<String, dynamic> jsonLayer) {
  final selector = SelectorFactory.create(jsonLayer);
  final paintJson = jsonLayer['paint'];
  final paint = PaintFactory.create(
      _layerId(jsonLayer), PaintingStyle.fill, 'fill', paintJson);
  final outlinePaint = PaintFactory.create(
      _layerId(jsonLayer), PaintingStyle.stroke, 'fill-outline', paintJson,
      defaultStrokeWidth: 0.1);
  if (paint != null) {
    return DefaultLayer(jsonLayer['id'] ?? _unknownId, _toLayerType(jsonLayer),
        selector: selector,
        style: Style(fillPaint: paint, outlinePaint: outlinePaint),
        minzoom: _minZoom(jsonLayer),
        maxzoom: _maxZoom(jsonLayer));
  }
}

ThemeLayer? _toLineTheme(Map<String, dynamic> jsonLayer) {
  final selector = SelectorFactory.create(jsonLayer);
  final jsonPaint = jsonLayer['paint'];
  final lineStyle = PaintFactory.create(
      _layerId(jsonLayer), PaintingStyle.stroke, 'line', jsonPaint);
  if (lineStyle != null) {
    return DefaultLayer(jsonLayer['id'] ?? _unknownId, _toLayerType(jsonLayer),
        selector: selector,
        style: Style(linePaint: lineStyle),
        minzoom: _minZoom(jsonLayer),
        maxzoom: _maxZoom(jsonLayer));
  }
}

String _layerId(Map<String, dynamic> jsonLayer) =>
    jsonLayer['id'] as String? ?? '<none>';

ThemeLayer? _toSymbolTheme(Map<String, dynamic> jsonLayer) {
  final selector = SelectorFactory.create(jsonLayer);
  final jsonPaint = jsonLayer['paint'];
  final paint = PaintFactory.create(
      _layerId(jsonLayer), PaintingStyle.fill, 'text', jsonPaint);
  if (paint != null) {
    final layout = _toTextLayout(jsonLayer);
    final textHalo = _toTextHalo(jsonLayer);

    return DefaultLayer(jsonLayer['id'] ?? _unknownId, _toLayerType(jsonLayer),
        selector: selector,
        style: Style(textPaint: paint, textLayout: layout, textHalo: textHalo),
        minzoom: _minZoom(jsonLayer),
        maxzoom: _maxZoom(jsonLayer));
  }
}

double? _minZoom(Map<String, dynamic> jsonLayer) =>
    (jsonLayer['minzoom'] as num?)?.toDouble();
double? _maxZoom(Map<String, dynamic> jsonLayer) =>
    (jsonLayer['maxzoom'] as num?)?.toDouble();

TextLayout _toTextLayout(Map<String, dynamic> jsonLayer) {
  final layout = jsonLayer['layout'];
  final textSize = _toTextSize(layout);
  final textLetterSpacing =
      _toDoubleZoomFunction(layout?['text-letter-spacing']);
  final placement =
      LayoutPlacement.fromName(layout?['symbol-placement'] as String?);
  final anchor = LayoutAnchor.fromName(layout?['text-anchor'] as String?);
  final textFunction = _toTextFunction(layout?['text-field']);
  return TextLayout(
      placement: placement,
      anchor: anchor,
      text: textFunction,
      textSize: textSize,
      textLetterSpacing: textLetterSpacing);
}

TextHaloFunction? _toTextHalo(Map<String, dynamic> jsonLayer) {
  final paint = jsonLayer['paint'];
  if (paint != null) {
    final haloWidth = (paint['text-halo-width'] as num?)?.toDouble();
    final colorFunction = ColorParser.parse(paint['text-halo-color']);
    if (haloWidth != null && colorFunction != null) {
      return TextHaloFactory.toHaloFunction(colorFunction, haloWidth);
    }
  }
}

FeatureTextFunction _toTextFunction(String? textField) {
  if (textField != null) {
    final match = RegExp(r'\{(.+?)\}').firstMatch(textField);
    if (match != null) {
      final fieldName = match.group(1);
      if (fieldName != null) {
        return (feature) => feature.stringProperty(fieldName);
      }
    }
  }
  return (feature) => feature.stringProperty('name');
}

DoubleZoomFunction _toTextSize(Map<String, dynamic>? layout) {
  final function = _toDoubleZoomFunction(layout?['text-size']);

  return (function != null) ? function : (zoom) => 16.0;
}

DoubleZoomFunction? _toDoubleZoomFunction(dynamic layoutProperty) {
  if (layoutProperty == null) {
    return null;
  }
  if (layoutProperty is Map) {
    final model = DoubleFunctionModelFactory().create(layoutProperty);
    if (model != null) {
      return (zoom) => DoubleThemeFunction().exponential(model, zoom);
    }
  } else if (layoutProperty is num) {
    final size = layoutProperty.toDouble();
    return (zoom) => size;
  }
  return null;
}

ThemeLayerType _toLayerType(Map<String, dynamic> jsonLayer) {
  final type = jsonLayer['type'] ?? '';
  switch (type) {
    case 'background':
      return ThemeLayerType.background;
    case 'fill':
      return ThemeLayerType.fill;
    case 'line':
      return ThemeLayerType.line;
    case 'symbol':
      return ThemeLayerType.symbol;
    default:
      return ThemeLayerType.unsupported;
  }
}

final _unknownId = '<unknown>';

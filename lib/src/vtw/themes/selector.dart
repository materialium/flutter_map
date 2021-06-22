import 'package:map/map.dart';

abstract class LayerSelector {
  const LayerSelector._();

  factory LayerSelector.none() = _NoneLayerSelector;
  factory LayerSelector.composite(List<LayerSelector> selectors) =
      _CompositeSelector;
  factory LayerSelector.any(List<LayerSelector> selectors) =
      _AnyCompositeSelector;
  factory LayerSelector.named(String name) = _NamedLayerSelector;
  factory LayerSelector.withProperty(String name,
      {required List<dynamic> values,
      required bool negated}) = _PropertyLayerSelector;
  factory LayerSelector.hasProperty(String name, {required bool negated}) =
      _HasPropertyLayerSelector;
  factory LayerSelector.comparingProperty(
          String name, ComparisonOperator op, num value) =
      _NumericComparisonLayerSelector;

  Iterable<Layer> select(Iterable<Layer> tileLayers);

  Iterable<Feature> features(Iterable<Feature> features);
}

enum ComparisonOperator {
  GREATER_THAN_OR_EQUAL_TO,
  LESS_THAN_OR_EQUAL_TO,
  GREATER_THAN,
  LESS_THAN
}

class _CompositeSelector extends LayerSelector {
  final List<LayerSelector> delegates;
  _CompositeSelector(this.delegates) : super._();

  @override
  Iterable<Layer> select(Iterable<Layer> tileLayers) {
    Iterable<Layer> result = tileLayers;
    delegates.forEach((delegate) {
      result = delegate.select(result);
    });
    return result;
  }

  Iterable<Feature> features(Iterable<Feature> features) {
    Iterable<Feature> result = features;
    delegates.forEach((delegate) {
      result = delegate.features(result);
    });
    return result;
  }
}

class _AnyCompositeSelector extends LayerSelector {
  final List<LayerSelector> delegates;
  _AnyCompositeSelector(this.delegates) : super._();

  @override
  Iterable<Layer> select(Iterable<Layer> tileLayers) {
    final Set<Layer> selected = Set();
    for (final delegate in delegates) {
      selected.addAll(delegate.select(tileLayers));
    }
    return tileLayers.where((layer) => selected.contains(layer));
  }

  Iterable<Feature> features(Iterable<Feature> features) {
    final Set<Feature> selected = Set();
    for (final delegate in delegates) {
      selected.addAll(delegate.features(features));
    }
    return features.where((layer) => selected.contains(layer));
  }
}

class _NamedLayerSelector extends LayerSelector {
  final String name;
  _NamedLayerSelector(this.name) : super._();

  @override
  Iterable<Layer> select(Iterable<Layer> tileLayers) =>
      tileLayers.where((layer) => layer.name == name);

  Iterable<Feature> features(Iterable<Feature> features) => features;
}

class _HasPropertyLayerSelector extends LayerSelector {
  final String name;
  final bool negated;
  _HasPropertyLayerSelector(this.name, {required this.negated}) : super._();

  @override
  Iterable<Layer> select(Iterable<Layer> tileLayers) => tileLayers;

  @override
  Iterable<Feature> features(Iterable<Feature> features) {
    return features.where((feature) {
      final properties = feature.properties;
      final hasProperty = properties.containsKey(name);
      return negated ? !hasProperty : hasProperty;
    });
  }
}

class _NumericComparisonLayerSelector extends LayerSelector {
  final String name;
  final ComparisonOperator op;
  final num value;
  _NumericComparisonLayerSelector(this.name, this.op, this.value) : super._() {
    if (name.startsWith('\$')) {
      throw Exception('Unsupported comparison property $name');
    }
  }

  @override
  Iterable<Feature> features(Iterable<Feature> features) {
    return features.where((feature) {
      final properties = feature.properties;
      if (!properties.containsKey(name)) {
        return false;
      }

      return _matches(properties[name]);
    });
  }

  @override
  Iterable<Layer> select(Iterable<Layer> tileLayers) => tileLayers;

  _matches(Value? value) {
    final v = value?.intValue?.toInt() ?? value?.doubleValue;
    if (v == null) {
      return false;
    }
    switch (op) {
      case ComparisonOperator.GREATER_THAN_OR_EQUAL_TO:
        return v >= this.value;
      case ComparisonOperator.LESS_THAN_OR_EQUAL_TO:
        return v >= this.value;
      case ComparisonOperator.LESS_THAN:
        return v < this.value;
      case ComparisonOperator.GREATER_THAN:
        return v > this.value;
    }
  }
}

class _PropertyLayerSelector extends LayerSelector {
  final String name;
  final List<dynamic> values;
  final bool negated;
  const _PropertyLayerSelector(
    this.name, {
    required this.values,
    required this.negated,
  }) : super._();

  @override
  Iterable<Layer> select(Iterable<Layer> tileLayers) => tileLayers;

  @override
  Iterable<Feature> features(Iterable<Feature> features) {
    return features.where((feature) {
      if (name == '\$type') {
        return _matchesType(feature);
      }
      final properties = feature.properties;
      final positiveMatch =
          properties.containsKey(name) && _positiveMatch(properties[name]);
      return negated ? !positiveMatch : positiveMatch;
    });
  }

  bool _matchesType(Feature feature) {
    final typeName = _typeName(feature.geometry);
    return values.contains(typeName);
  }

  String _typeName(Geometry? geometry) {
    if (geometry == null) {
      return '<none>';
    }

    if (geometry is PointGeometry) {
      return 'Point';
    }

    if (geometry is LineStringGeometry) {
      return 'LineString';
    }

    if (geometry is PolygonGeometry) {
      return 'Polygon';
    }

    return '<none>';
  }

  bool _positiveMatch(Value? value) {
    if (value != null) {
      final v = value.stringValue ??
          value.intValue?.toInt() ??
          value.doubleValue ??
          value.boolValue;
      return v == null ? false : values.contains(v);
    }
    return false;
  }
}

class _NoneLayerSelector extends LayerSelector {
  _NoneLayerSelector() : super._();

  @override
  Iterable<Feature> features(Iterable<Feature> features) => [];

  @override
  Iterable<Layer> select(Iterable<Layer> tileLayers) => [];
}

import 'package:map/map.dart' as map;
import '../../vt/vector_tile.dart';
import '../themes/theme.dart';
import '../context.dart';
import 'symbol_line_renderer.dart';
import 'symbol_point_renderer.dart';
import 'polygon_renderer.dart';
import 'line_renderer.dart';
import '../themes/style.dart';
import '../vector_tile_extensions.dart';

abstract class FeatureRenderer {
  void render(Context context, ThemeLayerType layerType, Style style,
      Layer layer, Feature feature);
}

class FeatureDispatcher extends FeatureRenderer {
  final Map<map.GeometryType, FeatureRenderer> typeToRenderer;
  final Map<map.GeometryType, FeatureRenderer> symbolTypeToRenderer;

  FeatureDispatcher()
      : typeToRenderer = createDispatchMapping(),
        symbolTypeToRenderer = createSymbolDispatchMapping();

  void render(Context context, ThemeLayerType layerType, Style style,
      Layer layer, Feature feature) {
    final type = feature.type;
    if (type != null) {
      final rendererMapping = layerType == ThemeLayerType.symbol
          ? symbolTypeToRenderer
          : typeToRenderer;
      final delegate = rendererMapping[type];
      if (delegate == null) {
        // logger.warn(
        //     () => 'layer type $layerType feature $type is not implemented');
      } else {
        delegate.render(context, layerType, style, layer, feature);
      }
    }
  }

  static Map<GeometryType, FeatureRenderer> createDispatchMapping() {
    return {
      GeometryType.polygon: PolygonRenderer(),
      GeometryType.lineString: LineRenderer(),
    };
  }

  static Map<GeometryType, FeatureRenderer> createSymbolDispatchMapping() {
    return {
      GeometryType.point: SymbolPointRenderer(),
      GeometryType.lineString: SymbolLineRenderer()
    };
  }
}

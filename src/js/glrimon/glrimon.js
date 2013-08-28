// Generated by CoffeeScript 1.6.1
(function() {
  var layer_url, map, querySites;

  map = {};

  layer_url = "http://umd-cla-gis01.d.umn.edu/arcgis/rest/services/NRRI/glritest001/MapServer";

  querySites = function(e) {
    /* query server for sites near mouseclick
    */

    var def, pad, popupTemplate, q, qt, queryGeom;
    pad = map.extent.getWidth() / map.width * 5;
    queryGeom = new esri.geometry.Extent(e.mapPoint.x - pad, e.mapPoint.y - pad, e.mapPoint.x + pad, e.mapPoint.y + pad, map.spatialReference);
    console.log(map.spatialReference);
    q = new esri.tasks.Query();
    q.outSpatialReference = {
      "wkid": map.spatialReference
    };
    q.returnGeometry = true;
    q.outFields = ["site", "name", "geomorph", 'lon'];
    q.geometry = queryGeom;
    popupTemplate = new esri.dijit.PopupTemplate({
      title: "{site}",
      fieldInfos: [
        {
          fieldName: "site",
          visible: true,
          label: "site: "
        }, {
          fieldName: "name",
          visible: true,
          label: "name: "
        }, {
          fieldName: "geomorph",
          visible: true,
          label: "geomorph: "
        }, {
          fieldName: "lon",
          visible: true,
          label: "lon: "
        }
      ]
    });
    qt = new esri.tasks.QueryTask(layer_url + '/0');
    console.log(['q', q]);
    def = qt.execute(q);
    def.addCallback(function(result) {
      console.log(['result', result]);
      return dojo.map(result.features, function(f) {
        console.log(['f', f]);
        f.setInfoTemplate(popupTemplate);
        return f;
      });
    });
    map.infoWindow.setFeatures([def]);
    return map.infoWindow.show(e.screenPoint, map.getInfoWindowAnchor(e.screenPoint));
  };

  require(['esri/map', 'esri/layers/ArcGISDynamicMapServiceLayer', "esri/layers/WMSLayer", 'esri/layers/FeatureLayer', 'esri/dijit/Legend', 'esri/tasks/query', "esri/layers/LayerDrawingOptions", "esri/renderers/SimpleRenderer", "esri/renderers/UniqueValueRenderer", "esri/renderers/ClassBreaksRenderer", "esri/symbols/SimpleMarkerSymbol", "esri/symbols/SimpleLineSymbol", "dojo/_base/Color", 'dojo/_base/array', 'dojo/parser', 'esri/dijit/BasemapGallery', 'esri/arcgis/utils', 'esri/dijit/Popup', 'esri/dijit/PopupTemplate', 'dojo/dom-class', 'dojo/dom-construct', 'dojo/on', 'dojox/charting/Chart', 'dojox/charting/themes/Dollar', 'dijit/layout/BorderContainer', 'dijit/layout/ContentPane', 'dijit/layout/AccordionContainer', 'dijit/TitlePane', 'dojo/domReady!'], function(Map, ArcGISDynamicMapServiceLayer, WMSLayer, FeatureLayer, Legend, query, LayerDrawingOptions, SimpleRenderer, UniqueValueRenderer, ClassBreaksRenderer, SimpleMarkerSymbol, SimpleLineSymbol, Color, arrayUtils, parser, BasemapGallery, arcgisUtils, Popup, PopupTemplate, domClass, domConstruct, On, Chart, theme) {
    var basemapGallery, colors, drawing_options, i, opts, popup, range, renderer, rivers, star, start, step, steps, stop, thing, things, _i, _j, _len, _ref;
    parser.parse();
    popup = new Popup({
      titleInBody: false
    }, domConstruct.create("div"));
    map = new Map("map", {
      slider: true,
      sliderStyle: "large",
      basemap: "topo",
      center: [-84, 45],
      zoom: 6,
      infoWindow: popup,
      minScale: 10000000
    });
    domClass.add(map.infoWindow.domNode, "myTheme");
    rivers = new ArcGISDynamicMapServiceLayer(layer_url, {
      mode: ArcGISDynamicMapServiceLayer.MODE_ONDEMAND,
      outFields: ["*"]
    });
    star = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE, 8, new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, new Color([255, 0, 0]), 2), new Color([0, 255, 0, 0.25]));
    renderer = new ClassBreaksRenderer(star, 'logn');
    colors = [[255, 0, 0], [255, 128, 0], [128, 128, 0], [0, 128, 128], [0, 0, 255]];
    range = [-92, -74];
    steps = colors.length;
    step = (range[1] - range[0]) / steps;
    for (i = _i = 0, _ref = steps - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      if (i === 0) {
        start = -Infinity;
        stop = range[0] + (i + 1) * step;
      } else if (i === steps - 1) {
        start = range[0] + i * step;
        stop = +Infinity;
      } else {
        start = range[0] + i * step;
        stop = range[0] + (i + 1) * step;
      }
      renderer.addBreak(start, stop, new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 8, new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, new Color([255, 0, 0]), 2), new Color(colors[i])));
      console.log(start, stop, colors[i]);
    }
    renderer = new UniqueValueRenderer(star, 'geomorph');
    things = [
      {
        value: 'riverine',
        color: [0, 255, 0]
      }, {
        value: 'barrier (protected)',
        color: [255, 0, 0]
      }, {
        value: 'lacustrine (coastal)',
        color: [0, 0, 255]
      }
    ];
    for (_j = 0, _len = things.length; _j < _len; _j++) {
      thing = things[_j];
      renderer.addValue({
        value: thing.value,
        symbol: new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 8, new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, new Color(thing.color), 2), new Color([255, 128, 128])),
        label: thing.value,
        description: thing.value
      });
    }
    drawing_options = new LayerDrawingOptions();
    drawing_options.renderer = renderer;
    opts = [];
    opts[0] = drawing_options;
    rivers.setLayerDrawingOptions(opts);
    basemapGallery = new BasemapGallery({
      showArcGISBasemaps: true,
      map: map
    }, "basemapGallery");
    basemapGallery.startup();
    map.on("layers-add-result", function(evt) {
      var layerInfo, legendDijit;
      layerInfo = arrayUtils.map(evt.layers, function(layer, index) {
        return {
          layer: layer.layer,
          title: layer.layer.name
        };
      });
      if (layerInfo.length > 0) {
        legendDijit = new Legend({
          map: map,
          layerInfos: layerInfo
        }, "legendDiv");
        return legendDijit.startup();
      }
    });
    map.addLayers([rivers]);
    return dojo.connect(map, 'onClick', querySites);
  });

}).call(this);

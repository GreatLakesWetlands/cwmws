// Generated by CoffeeScript 1.6.1
var layer_url, map;

map = {};

layer_url = "http://umd-cla-gis01.d.umn.edu:6080/arcgis/rest/services/NRRI/glritest000/MapServer";

require(['esri/map', 'esri/layers/ArcGISDynamicMapServiceLayer', 'esri/dijit/Legend', 'dojo/_base/array', 'dojo/parser', 'esri/dijit/BasemapGallery', 'esri/arcgis/utils', 'dijit/layout/BorderContainer', 'dijit/layout/ContentPane', 'dijit/layout/AccordionContainer', 'dijit/TitlePane', 'dojo/domReady!'], function(Map, ArcGISDynamicMapServiceLayer, Legend, arrayUtils, parser, BasemapGallery, arcgisUtils) {
  var basemapGallery, rivers;
  parser.parse();
  map = new Map("map", {
    basemap: "topo",
    center: [-90, 44],
    zoom: 6
  });
  rivers = new ArcGISDynamicMapServiceLayer(layer_url, {
    mode: ArcGISDynamicMapServiceLayer.MODE_ONDEMAND,
    outFields: ["*"]
  });
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
    }
    return legendDijit.startup();
  });
  return map.addLayers([rivers]);
});

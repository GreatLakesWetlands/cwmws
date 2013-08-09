# coffee -bcw js/glrimon/glrimon.coffee &

map = {}

layer_url = "http://umd-cla-gis01.d.umn.edu:6080/arcgis/rest/services/NRRI/glritest000/MapServer"

require ["esri/map", "esri/layers/FeatureLayer", "esri/dijit/Legend",
"dojo/_base/array", "dojo/parser",
"dijit/layout/BorderContainer", "dijit/layout/ContentPane", 
"dijit/layout/AccordionContainer", "dojo/domReady!"], 
(Map, FeatureLayer, Legend, arrayUtils, parser) ->
    parser.parse();
    
    map = new Map "map",
        basemap:"topo",
        center: [-96.53, 38.374],
        zoom: 13

    rivers = new FeatureLayer "http://sampleserver3.arcgisonline.com/ArcGIS/rest/services/Hydrography/Watershed173811/MapServer/1",
        mode: FeatureLayer.MODE_ONDEMAND,
        outFields: ["*"]
    
    waterbodies = new FeatureLayer "http://sampleserver3.arcgisonline.com/ArcGIS/rest/services/Hydrography/Watershed173811/MapServer/0",
        mode: FeatureLayer.MODE_ONDEMAND,
        outFields: ["*"]
   
    map.on "layers-add-result", (evt) ->
        layerInfo = arrayUtils.map evt.layers, (layer, index) ->
            layer:layer.layer
            title:layer.layer.name
    
        if layerInfo.length > 0
            legendDijit = new Legend
                map: map,
                layerInfos: layerInfo
              , "legendDiv"
            legendDijit.startup();

    map.addLayers [waterbodies, rivers]


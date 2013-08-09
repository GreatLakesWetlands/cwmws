# coffee -bcw js/glrimon/glrimon.coffee &

map = {}

layer_url = "http://umd-cla-gis01.d.umn.edu:6080/arcgis/rest/services/NRRI/glritest000/MapServer"

require ["esri/map", "esri/layers/FeatureLayer",
        "esri/dijit/AttributeInspector",
        "esri/symbols/SimpleLineSymbol",
        "esri/symbols/SimpleFillSymbol", "dojo/_base/Color",
        "esri/layers/ArcGISDynamicMapServiceLayer", "esri/config",
        "esri/tasks/query", "dojo/parser", "dojo/dom-construct",
        "dijit/form/Button", "dijit/layout/BorderContainer",
        "dijit/layout/ContentPane", "dojo/domReady!" ], (Map,
        FeatureLayer, AttributeInspector, SimpleLineSymbol,
        SimpleFillSymbol, Color, ArcGISDynamicMapServiceLayer,
        esriConfig, Query, parser, domConstruct, Button) ->
 
    # parser.parse()
        
    esriConfig.defaults.io.proxyUrl = "/proxy"
 
    map = new Map 'mapDiv',
        basemap: "topo"
        center: [-88, 44]
        zoom: 7
    
    map.on "layers-add-result", (evt) ->
    
        console.log "layers-add-result"
    
        # layerInfo = arrayUtils.map evt.layers, (layer, index) ->
        #     layer:layer.layer
        #     title:layer.layer.name
        
        layer = evt.layers[0].layer
        selectQuery = new Query()
        
        layerInfos = [{
            'featureLayer': layer,
            'showAttachments': false,
            'isEditable': true,
            'fieldInfos': [
              {'fieldName': 'activeprod', 'isEditable':true, 'tooltip': 'Current Status', 'label':'Status:'},
              {'fieldName': 'field_name', 'isEditable':true, 'tooltip': 'The name of this oil field', 'label':'Field Name:'},
              {'fieldName': 'approxacre', 'isEditable':false,'label':'Acreage:'},
              {'fieldName': 'avgdepth', 'isEditable':false, 'label':'Average Depth:'},
              {'fieldName': 'cumm_oil', 'isEditable':false, 'label':'Cummulative Oil:'},
              {'fieldName': 'cumm_gas', 'isEditable':false, 'label':'Cummulative Gas:'}
            ]
          }];

                
        if layerInfo.length > 0
        
            console.log layerInfo
        
            legendDijit = new Legend
                map: map,
                layerInfos: []  layerInfo
              , "legendDiv"
            legendDijit.startup()
            
            attInspector = new AttributeInspector layerInfos: layerInfos, domConstruct.create "div"
              
            map.infoWindow.setContent attInspector.domNode

    layer = new ArcGISDynamicMapServiceLayer layer_url
    
    map.addLayers [layer]
    
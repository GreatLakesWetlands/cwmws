# /usr/bin/coffee -cw js/glrimon/glrimon.coffee &

map = {}

layer_url = "http://umd-cla-gis01.d.umn.edu/arcgis/rest/services/NRRI/glritest000/MapServer"

querySites = (e) ->
    ### query server for sites near mouseclick ###
    
    # build an extent around the click point
    pad = map.extent.getWidth() / map.width * 5
    queryGeom = new esri.geometry.Extent e.mapPoint.x - pad, e.mapPoint.y - pad,
        e.mapPoint.x + pad, e.mapPoint.y + pad,
        map.spatialReference
    console.log map.spatialReference
    q = new esri.tasks.Query()
    q.outSpatialReference = {"wkid": 102100} # map.spatialReference # {"wkid": 4326}
    q.returnGeometry = true
    q.outFields = ["site", "name", "geomorph"] # ["NAME", "STATE_FIPS", "CNTY_FIPS"]
    q.geometry = queryGeom

    popupTemplate = new esri.dijit.PopupTemplate
        title: "{site}"
        fieldInfos: [
            { fieldName: "site", visible: true, label: "site: " },
            { fieldName: "name", visible: true, label: "name: " },
            { fieldName: "geomorph", visible: true, label: "geomorph: " },
            # { fieldName: "CNTY_FIPS", visible: true, label: "County FIPS: " },
            # { fieldName: "STATE_FIPS", visible: true, label: "State FIPS: " }
        ]

    qt = new esri.tasks.QueryTask layer_url + '/0'
    console.log ['q', q]
    def = qt.execute q
    def.addCallback (result) ->
        console.log ['result', result]
        dojo.map result.features, (f) ->
            console.log ['f', f]
            f.setInfoTemplate popupTemplate
            return f

    map.infoWindow.setFeatures [def]
    # show the popup
    map.infoWindow.show e.screenPoint, map.getInfoWindowAnchor e.screenPoint


require [
    'esri/map',
    'esri/layers/ArcGISDynamicMapServiceLayer',
    "esri/layers/WMSLayer", 
    'esri/layers/FeatureLayer',
    'esri/dijit/Legend',
    'esri/tasks/query',
    "esri/layers/LayerDrawingOptions", 
    "esri/renderers/SimpleRenderer",
    "esri/symbols/SimpleMarkerSymbol",
    "esri/symbols/SimpleLineSymbol", 
    "dojo/_base/Color",
    'dojo/_base/array',
    'dojo/parser',
    'esri/dijit/BasemapGallery',
    'esri/arcgis/utils',
    'esri/dijit/Popup',
    'esri/dijit/PopupTemplate',
    'dojo/dom-class',
    'dojo/dom-construct',
    'dojo/on',
    'dojox/charting/Chart',
    'dojox/charting/themes/Dollar',
    'dijit/layout/BorderContainer',
    'dijit/layout/ContentPane',
    'dijit/layout/AccordionContainer',
    'dijit/TitlePane',
    'dojo/domReady!'
], (
    Map,
    ArcGISDynamicMapServiceLayer,
    WMSLayer,
    FeatureLayer,
    Legend,
    query,
    LayerDrawingOptions,
    SimpleRenderer,
    SimpleMarkerSymbol,
    SimpleLineSymbol,
    Color,
    arrayUtils,
    parser,
    BasemapGallery,
    arcgisUtils,
    Popup,
    PopupTemplate,
    domClass,
    domConstruct,
    On,
    Chart,
    theme
) ->
    parser.parse()
    
    popup = new Popup
        titleInBody: false, 
        domConstruct.create "div"
    
    map = new Map "map",
        slider: true
        sliderStyle: "large"
        basemap:"topo"
        center: [-84, 45]
        zoom: 6
        infoWindow: popup
        minScale: 10000000
        
    domClass.add map.infoWindow.domNode, "myTheme"
    
    template = new PopupTemplate
        title: "Boston Marathon 2013"
        description: "{Percent_Fi} of starters from {STATE_NAME} finished"
        fieldInfos: [
            fieldName: "Number_Ent",
            label: "Entrants"
          ,
            fieldName: "Number_Sta",
            label: "Starters"
          ,
            fieldName: "Number_Fin",
            label: "Finishers"
        ]
        mediaInfos: []
 
    rivers = new ArcGISDynamicMapServiceLayer layer_url,
        mode: ArcGISDynamicMapServiceLayer.MODE_ONDEMAND,
        outFields: ["*"]
        infoTemplate:template

    star = new SimpleMarkerSymbol SimpleMarkerSymbol.STYLE_CIRCLE, 8,
        new SimpleLineSymbol SimpleLineSymbol.STYLE_SOLID,
            new Color([255,0,0]), 2,
        new Color([0,255,0,0.25])
    
    renderer = new SimpleRenderer(star)
    drawing_options = new LayerDrawingOptions()
    drawing_options.renderer = renderer
    opts = []
    opts[0] = drawing_options  # would be not zero if not sub layer 0
    rivers.setLayerDrawingOptions(opts)
        
    basemapGallery = new BasemapGallery
        showArcGISBasemaps: true
        map: map, 
        "basemapGallery"
        
    basemapGallery.startup()
   
    map.on "layers-add-result", (evt) ->
        layerInfo = arrayUtils.map evt.layers, (layer, index) ->
            layer:layer.layer
            title:layer.layer.name
            
        if layerInfo.length > 0
            legendDijit = new Legend {map: map, layerInfos: layerInfo}, "legendDiv"
            legendDijit.startup()

    map.addLayers [rivers]

    dojo.connect map, 'onClick', querySites
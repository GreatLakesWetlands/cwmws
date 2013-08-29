# /usr/bin/coffee -cw js/glrimon/glrimon.coffee &
map = {}

layer_url = "http://umd-cla-gis01.d.umn.edu/arcgis/rest/services/NRRI/glritest001/MapServer"
querySites = (e) ->
    ### query server for sites near mouseclick ###
    
    # build an extent around the click point
    pad = map.extent.getWidth() / map.width * 5
    queryGeom = new esri.geometry.Extent e.mapPoint.x - pad, e.mapPoint.y - pad,
        e.mapPoint.x + pad, e.mapPoint.y + pad,
        map.spatialReference
    console.log map.spatialReference
    q = new esri.tasks.Query()
    q.outSpatialReference = {"wkid": map.spatialReference} # 102100 # {"wkid": 4326}
    q.returnGeometry = true
    q.outFields = ["site", "name", "geomorph", 'lon']
    q.geometry = queryGeom

    popupTemplate = new esri.dijit.PopupTemplate
        title: "{site}"
        fieldInfos: [
            { fieldName: "site", visible: true, label: "site: " },
            { fieldName: "name", visible: true, label: "name: " },
            { fieldName: "geomorph", visible: true, label: "geomorph: " },
            { fieldName: "lon", visible: true, label: "lon: " },
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
### main #######################################################################
require [
    'esri/map',
    'esri/layers/ArcGISDynamicMapServiceLayer',
    'esri/layers/WMSLayer',
    'esri/layers/FeatureLayer',
    'esri/dijit/Legend',
    'esri/tasks/query',
    'esri/layers/LayerDrawingOptions',
    'esri/renderers/SimpleRenderer',
    'esri/renderers/UniqueValueRenderer',
    'esri/renderers/ClassBreaksRenderer',
    'esri/symbols/SimpleMarkerSymbol',
    'esri/symbols/SimpleLineSymbol',
    "esri/toolbars/draw",
    'dojo/_base/Color',
    'dojo/_base/array',
    'dojo/parser',
    'esri/dijit/BasemapGallery',
    'esri/arcgis/utils',
    'esri/dijit/Popup',
    'esri/dijit/PopupTemplate',
    'dojo/dom-class',
    'dojo/dom-construct',
    'dojo/on',
    'dojo/keys',
    'dojox/charting/Chart',
    'dojox/charting/themes/Dollar',
    'esri/tasks/locator',
    'esri/SpatialReference',
    'esri/graphic',
    'esri/symbols/Font',
    'esri/symbols/TextSymbol',
    'esri/geometry/Point',
    'esri/geometry/Extent',
    'esri/geometry/webMercatorUtils',
    'dojo/number',
    'dojo/dom',
    'dojo/json',
    'dijit/registry',
    'dijit/layout/BorderContainer',
    'dijit/layout/ContentPane',
    'dijit/layout/AccordionContainer',
    'dijit/TitlePane',
    'dijit/form/Button',
    'dijit/form/Textarea',
    'dojo/query',
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
    UniqueValueRenderer,
    ClassBreaksRenderer,
    SimpleMarkerSymbol,
    SimpleLineSymbol,
    Draw,
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
    Keys,
    Chart,
    theme,
    Locator,
    SpatialReference,
    Graphic,
    Font,
    TextSymbol,
    Point,
    Extent,
    webMercatorUtils,
    number,
    dom,
    JSON,
    registry
) ->
    
    select = (shape) ->
        
        tb = new Draw map
        tb.on "draw-end", (evt) ->
            tb.deactivate()
            map.enableMapNavigation()
            console.log evt
        map.disableMapNavigation()
        
        esri.bundle.toolbars.draw.addShape = "Click and drag from corner to corner"
        
        tb.activate esri.toolbars.Draw.RECTANGLE
        
    ### setup misc #################################################################

    parser.parse()  

    popup = new Popup
        titleInBody: false, 
        domConstruct.create "div"

    star = new SimpleMarkerSymbol SimpleMarkerSymbol.STYLE_SQUARE, 8,
        new SimpleLineSymbol SimpleLineSymbol.STYLE_SOLID,
            new Color([255,0,0]), 2,
        new Color([0,255,0,0.25])

    ### create map #################################################################

    map = new Map "map",
        slider: true
        sliderStyle: "large"
        basemap:"topo"
        center: [-84, 45]
        zoom: 6
        infoWindow: popup
        minScale: 10000000

    ### legend #####################################################################

    map.on "layers-add-result", (evt) ->
        layerInfo = arrayUtils.map evt.layers, (layer, index) ->
            layer:layer.layer
            title:layer.layer.name
            
        if layerInfo.length > 0
            legendDijit = new Legend 
                map: map
                layerInfos: layerInfo
              ,
                "legendDiv"
            legendDijit.startup()

    ### BasemapGallery #############################################################

    basemapGallery = new BasemapGallery
        showArcGISBasemaps: true
        map: map, 
        "basemapGallery"
        
    basemapGallery.startup()

    ### find address ###############################################################

    locator = new Locator         "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"

    locate = ->
        dom.byId('find_active').innerHTML = 'Searching, please wait'
        locator.addressToLocations
            address: SingleLine: dom.byId("address").value + ', U.S.A.'
            outFields: ["*"]
        
    registry.byId("locate").on "click", locate  
    registry.byId("address").on "keyup", (evt) ->
        if evt.keyCode != Keys.ENTER
            return
        locate()

    locator.on "address-to-locations-complete", (evt) ->
        dom.byId('find_active').innerHTML = ''
        map.graphics.clear()
        geocodeResult = evt.addresses[0]
        r = Math.floor Math.random() * 250
        g = Math.floor Math.random() * 100
        b = Math.floor Math.random() * 100
      
        symbol = new SimpleMarkerSymbol(
            SimpleMarkerSymbol.STYLE_CIRCLE, 
            15, 
            new SimpleLineSymbol(
                SimpleLineSymbol.STYLE_SOLID, 
                new Color [r, g, b, 0.5], 
                6
            ), new Color [r, g, b, 0.9])
        pointMeters = webMercatorUtils.geographicToWebMercator(geocodeResult.location)
        locationGraphic = new Graphic(pointMeters, symbol)
       
        font = new Font().setFamily('sans-serif').setSize("12pt").setWeight(Font.WEIGHT_BOLD)
        textSymbol = new TextSymbol(
          geocodeResult.address, 
          font, 
          new Color([r, g, b, 0.8])
        ).setOffset(5, 15)

        map.graphics.add locationGraphic
        map.graphics.add new Graphic(pointMeters, textSymbol)
        
        ptAttr = evt.addresses[0].attributes
        minx = parseFloat ptAttr.Xmin
        maxx = parseFloat ptAttr.Xmax
        miny = parseFloat ptAttr.Ymin
        maxy = parseFloat ptAttr.Ymax

        esriExtent = new Extent minx, miny, maxx, maxy, new SpatialReference {wkid:4326}
        map.setExtent webMercatorUtils.geographicToWebMercator esriExtent 

        # showResults(evt.addresses);

    ### ClassBreaksRenderer ########################################################

    renderer = new ClassBreaksRenderer star, 'lon'
    colors = [
        [255,0,0],
        [255,128,0],
        [128,128,0],
        [0,128,128],
        [0,0,255],
    ]

    range = [-92, -74]
    steps = colors.length
    step = (range[1] - range[0]) / steps
    for i in [0..steps-1]
        if i == 0
            start = -Infinity
            stop = range[0]+(i+1)*step
        else if i == steps - 1
            start = range[0]+i*step
            stop = +Infinity
        else
            start = range[0]+i*step
            stop = range[0]+(i+1)*step
        
        renderer.addBreak start, stop, # star,
            new SimpleMarkerSymbol SimpleMarkerSymbol.STYLE_CIRCLE, 8,
                new SimpleLineSymbol SimpleLineSymbol.STYLE_SOLID,
                    new Color([255,0,0]), 2,
                new Color(colors[i])
                
        console.log start, stop, colors[i]

    ### SimpleRenderer #############################################################

    renderer = new SimpleRenderer star

    ### UniqueValueRenderer ########################################################

    renderer = new UniqueValueRenderer star, 'geomorph'

    things =[
        value: 'riverine'
        color: [0,255,0]
      ,
        value: 'barrier (protected)'
        color: [255,0,0]
      ,
        value: 'lacustrine (coastal)'
        color: [0,0,255]
    ]

    for thing in things                
        renderer.addValue 
            value: thing.value
            symbol:
                new SimpleMarkerSymbol SimpleMarkerSymbol.STYLE_CIRCLE, 8,
                    new SimpleLineSymbol SimpleLineSymbol.STYLE_SOLID,
                        new Color(thing.color), 2,
                    new Color([255,128,128])
            label: thing.value
            description: thing.value

    ### load sites layer ###########################################################

    sites = new ArcGISDynamicMapServiceLayer layer_url,
    mode: ArcGISDynamicMapServiceLayer.MODE_ONDEMAND,
    outFields: ["*"]

    drawing_options = new LayerDrawingOptions()
    drawing_options.renderer = renderer
    opts = []
    opts[0] = drawing_options  # would be not zero if not sub layer 0
    sites.setLayerDrawingOptions(opts)
            
    map.addLayers [sites]

    ### connect signals ############################################################

    dojo.connect map, 'onClick', querySites

    registry.byId("select-rect").on "click", -> select('rectangle')


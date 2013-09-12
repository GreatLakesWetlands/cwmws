# /usr/bin/coffee -cw js/glrimon/glrimon.coffee &

### replace .js with .coffee for original source ###

### setup ######################################################################

map = {}

window.selected_sites = []

layer_url = "http://umd-cla-gis01.d.umn.edu/arcgis/rest/services/NRRI/glritest001/MapServer"

### querySites #################################################################

querySites = (e) ->
    ### query server for sites near mouseclick ###
    
    # build an extent around the click point
    pad = map.extent.getWidth() / map.width * 5
    queryGeom = new esri.geometry.Extent e.mapPoint.x - pad, e.mapPoint.y - pad,
        e.mapPoint.x + pad, e.mapPoint.y + pad,
        map.spatialReference
    q = new esri.tasks.Query()
    q.outSpatialReference = {"wkid": map.spatialReference}
    q.returnGeometry = true
    q.outFields = ["site", "name", "geomorph", 'lat', 'lon']
    q.geometry = queryGeom

    popupTemplate = new esri.dijit.PopupTemplate
        title: "{site}"
        fieldInfos: [
            { fieldName: "site", visible: true, label: "site: " },
            { fieldName: "name", visible: true, label: "name: " },
            { fieldName: "geomorph", visible: true, label: "geomorph: " },
            { fieldName: "lat", visible: true, label: "lat: ", format: places: 6 },
            { fieldName: "lon", visible: true, label: "lon: ", format: places: 6 },
        ]

    qt = new esri.tasks.QueryTask layer_url + '/1'
    def = qt.execute q
    def.addCallback (result) ->

        dojo.map result.features, (f) ->
            f.setInfoTemplate popupTemplate
            return f

    map.infoWindow.setFeatures [def]
    # show the popup
    map.infoWindow.show e.screenPoint, map.getInfoWindowAnchor e.screenPoint

### main #######################################################################

require([
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
    'esri/symbols/SimpleFillSymbol',
    'esri/toolbars/draw',
    'dojo/_base/Color',
    'dojo/_base/array',
    'dojo/parser',
    'esri/dijit/BasemapGallery',
    'esri/arcgis/utils',
    'esri/dijit/Popup',
    'esri/dijit/PopupTemplate',
    'esri/dijit/Measurement',
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
    'esri/layers/ImageParameters',
    'dojo/number',
    'dojo/dom',
    'dojo/json',
    'dijit/registry',
    'dojo/query',
    'dijit/Dialog',
    'dijit/form/TextBox',
    'dijit/form/Button',
    "dijit/form/CheckBox",
    'dijit/layout/BorderContainer',
    'esri/config',
    'esri/sniff',
    'esri/SnappingManager',
    'esri/tasks/GeometryService',
    'dijit/layout/ContentPane',
    'dijit/layout/AccordionContainer',
    'dijit/TitlePane',
    'dijit/form/Textarea',
    'esri/dijit/Scalebar',
    'dijit/form/CheckBox',
    'dojo/domReady!'
], (
    Map,
    ArcGISDynamicMapServiceLayer,
    WMSLayer,
    FeatureLayer,
    Legend,
    Query,
    LayerDrawingOptions,
    SimpleRenderer,
    UniqueValueRenderer,
    ClassBreaksRenderer,
    SimpleMarkerSymbol,
    SimpleLineSymbol,
    SimpleFillSymbol,
    Draw,
    Color,
    arrayUtils,
    parser,
    BasemapGallery,
    arcgisUtils,
    Popup,
    PopupTemplate,
    Measurement,
    domClass,
    domConstruct,
    dojo_on,
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
    ImageParameters,
    number,
    dom,
    JSON,
    registry,
    dojo_query,
    Dialog,
    TextBox,
    Button,
    CheckBox,
    BorderContainer,
    esriConfig,
    has,
    SnappingManager,
    GeometryService
) ->
    
    ### setup misc #################################################################

    parser.parse()  

    popup = new Popup
        titleInBody: false, 
        domConstruct.create "div"

    star = new SimpleMarkerSymbol SimpleMarkerSymbol.STYLE_SQUARE, 8,
        new SimpleLineSymbol SimpleLineSymbol.STYLE_SOLID,
            new Color([0,0,255]), 2,
        new Color([0,255,0,0.25])

    perimeter = new SimpleFillSymbol SimpleFillSymbol.STYLE_NULL,
        new SimpleLineSymbol SimpleLineSymbol.STYLE_SOLID,
            new Color([255,0,0]), 2
        new Color([0,0,0])

    ### show_species ###############################################################

    show_species = (evt) ->
        feature = map.infoWindow.getSelectedFeature()
        
        site = feature.attributes.site

        q = new esri.tasks.Query()
        q.returnGeometry = true
        q.outFields = ["site", "taxa", "name"]
        q.where = "site = #{site}"

        qt = new esri.tasks.QueryTask layer_url + '/2'
        def = qt.execute q
        def.addCallback (result) ->

            taxa = ''
            div = domConstruct.create "div"
            
            for feat in result.features
                if feat.attributes.taxa != taxa
                    taxa = feat.attributes.taxa
                    h2 = domConstruct.create "h2"
                    h2.innerHTML = taxa
                    domConstruct.place h2, div, 'last'
                name = domConstruct.create "div"
                name.innerHTML = feat.attributes.name
                domConstruct.place name, div, 'last'
                
            if taxa == ''
                note = domConstruct.create "p"
                note.innerHTML = "No species reported yet."
                domConstruct.place note, div, 'last'
            
            ans = new Dialog
                title: "Species for site #{site}"
                content: div
            ans.show()
            
    ### select #####################################################################

    select = (shape) ->
        
        toolbar = new Draw map
        toolbar.on "draw-end", (evt) ->
        
            toolbar.deactivate()

            q = new esri.tasks.Query()
            q.outSpatialReference = "wkid": map.spatialReference
            q.returnGeometry = true
            q.outFields = ["site", "name", "geomorph", 'lon']
            q.geometry = evt.geometry
            q.spatialRelationship = Query.SPATIAL_REL_INTERSECTS
            
            map.enableMapNavigation()
        
            qt = new esri.tasks.QueryTask layer_url + '/1'
            def = qt.execute q
            def.addCallback (result) ->
            
                    
                symbol = new SimpleMarkerSymbol(
                    SimpleMarkerSymbol.STYLE_CIRCLE, 
                    8, 
                    new SimpleLineSymbol(
                        SimpleLineSymbol.STYLE_SOLID, 
                        new Color [0, 255, 255, 0.5], 
                        1
                    ), new Color [0, 255, 255, 0.9])      
            
                for i in result.features
                    if i.attributes.site not in window.selected_sites
                        window.selected_sites.push i.attributes.site
                        locationGraphic = new Graphic(i.geometry.getExtent().getCenter(), symbol)
                        map.graphics.add locationGraphic

                if window.selected_sites.length == result.features.length
                    text = "#{result.features.length} sites."
                else
                    text = "#{result.features.length} sites, total selected now #{window.selected_sites.length}."
                dom.byId('select_results').innerHTML = text
                
            
        map.disableMapNavigation()
        esri.bundle.toolbars.draw.addShape = "Click and drag from corner to corner"
        dom.byId('select_results').innerHTML = 
                    "Draw a rectangle on the map"
        toolbar.activate esri.toolbars.Draw.RECTANGLE
        
    ### create map #################################################################

    map = new Map "map",
        slider: true
        sliderStyle: "large"
        basemap:"topo"
        center: [-84, 45]
        zoom: 6
        infoWindow: popup
        minScale: 10000000

    map.markers = []
    ### address locator graphics markers ###
    ### links from popup ###########################################################

    link = domConstruct.create "a",
        "class": "action" 
        "id": "statsLink"
        "innerHTML": "Species",
        "href": "javascript: void(0);"
      ,
        dojo_query(".actionList", map.infoWindow.domNode)[0]

    dojo_on link, "click", show_species

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
            map.legend = legendDijit

    ### set up layer picker ########################################################

    map.on "layers-add-result", (evt) ->
        ul = dojo_query "#layers"
        for layer in sites.layerInfos
            li = domConstruct.create 'li', {}, ul[0]
            cb = new CheckBox 
                value: layer.name, 
                id: 'cb_'+layer.name
                checked: layer.defaultVisibility
              , 
                ''
            domConstruct.place cb.domNode, li
            domConstruct.create 'label', 
                innerHTML: layer.name
                for: 'cb_'+layer.name
              ,
                li
            cb.on 'change', do (layer=layer) -> (visible) ->            
                if not visible
                    sites.visibleLayers = sites.visibleLayers.filter (i) ->
                        i isnt layer.id
                else
                    if layer.id not in sites.visibleLayers
                        sites.visibleLayers.push layer.id
                sites.setVisibleLayers sites.visibleLayers
    ### BasemapGallery #############################################################

    basemapGallery = new BasemapGallery
        showArcGISBasemaps: true
        map: map, 
        "basemapGallery"
        
    basemapGallery.startup()

    ### find address / site ########################################################

    locator = new Locator         "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"

    locate = (address, status) ->
        
        status.innerHTML = 'Searching...'

        ### if only digits, treat as a site number ###
        non_digit = false
        for c in address
            if c not in '0123456789'
                non_digit = true
                break
        
        if non_digit    
            locator.addressToLocations
                address: SingleLine: address + ', U.S.A.'
                outFields: ["*"]
        else
        
            q = new esri.tasks.Query()
            q.returnGeometry = true
            q.outFields = ["site", "name", "geomorph", 'lat', 'lon']
            q.where = "site = #{address}"
        
            qt = new esri.tasks.QueryTask layer_url + '/1'
            def = qt.execute q
            def.addCallback (result) ->
                if result.features.length > 0
                    status.innerHTML = ""
                    map.setExtent result.features[0].geometry.getExtent().expand 1.5
                else
                    status.innerHTML = "Site #{address} not found"     
        
    dojo_query(".search-box").forEach (node) ->
        
        domConstruct.create "div", innerHTML: "Find site # / address:", node
        tb = new TextBox style: 'width: 12em', value: '123', ''
        domConstruct.place tb.domNode, node
        bt = new Button innerHTML: "Find", ''
        domConstruct.place bt.domNode, node
        status = domConstruct.create "div", 
            class: 'find-active', node
        
        tb.on 'keyup', do (tb=tb, status=status) -> (evt) ->
            if evt.keyCode != Keys.ENTER
                return
            locate tb.get('value'), status
        bt.on 'click', do (tb=tb, status=status) -> (evt) -> locate tb.get('value'), status
        
    locator.on "address-to-locations-complete", (evt) ->

        dojo_query(".find-active").forEach (node) ->
            node.innerHTML = ''
        
        console.log map
        for i in map.markers
            console.log i
            map.graphics.remove i
            console.log 'removed'
        map.markers = []
            
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
        text = new Graphic(pointMeters, textSymbol)
        map.graphics.add text
        map.markers = [locationGraphic, text]
        
        ptAttr = evt.addresses[0].attributes
        minx = parseFloat ptAttr.Xmin
        maxx = parseFloat ptAttr.Xmax
        miny = parseFloat ptAttr.Ymin
        maxy = parseFloat ptAttr.Ymax

        esriExtent = new Extent minx, miny, maxx, maxy, new SpatialReference {wkid:4326}
        map.setExtent webMercatorUtils.geographicToWebMercator esriExtent 

        # showResults(evt.addresses);

    ### SimpleRenderer #############################################################

    renderer = new SimpleRenderer star

    line_renderer = SimpleRenderer perimeter

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

    ### load sites layer ###########################################################

    # ip = new ImageParameters()
    # #ip.format = "svg"
    # #ip.transparent = true
    # ip.layerIds = [0]
    # ip.layerOption = ImageParameters.LAYER_OPTION_SHOW

    sites = new ArcGISDynamicMapServiceLayer layer_url,
        mode: ArcGISDynamicMapServiceLayer.MODE_ONDEMAND,
        outFields: ["*"]
        # imageParameters: ip

    drawing_options = new LayerDrawingOptions()
    drawing_options.renderer = renderer
    opts = []
    ### zero for sub layer zero, 1 for sublayer 1, etc. ###
    opts[0] = drawing_options  

    drawing_options = new LayerDrawingOptions()
    drawing_options.renderer = line_renderer
    opts[1] = drawing_options  

    sites.setLayerDrawingOptions(opts)
            
    map.addLayers [sites]

    ### connect signals ############################################################

    map.query_click = map.on 'click', querySites
    basemapGallery.on 'selection-change', -> 
        registry.byId("basemap-gallery-pane").toggle()

    registry.byId("select-clear").on "click", ->
        window.selected_sites = []
        dom.byId('select_results').innerHTML = "No sites selected."
        map.graphics.clear()
        
    registry.byId("select-rect").on "click", -> select('rectangle')

    map.on 'load', (evt) ->
        m = new Measurement map: evt.map, 'measurement'
        m.startup()
        dojo_query('#measurement').on 'click', -> evt.map.query_click.remove()
        m.on 'measure-end', (evt) ->
            map.query_click = map.on 'click', querySites
            m.setTool evt.toolName, false
            
    # * * * layerDefinitions available for ArcGISDynamicMapServiceLayer


        
    ### sometimes 1-2 zooms / pans are needed to get features / legend
    to show, so try this to avoid that ###
    map.addLayers []


)


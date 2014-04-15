# /usr/bin/coffee -cw glrimon.coffee &

# while /usr/bin/coffee -c glrimon.coffee && cp glrimon.js ../../../templates/dlayer/js/glrimon.js ; do inotifywait -e close_write -r . ; done

### setup ######################################################################

map = {}

window.selected_sites = []
window.highlighted_sites = []
window.theme_name = 'geomorph'

protocol = 'http:'

layer_url = "{% url 'dlayer.views.gis' %}cwmlyr00"

centroid_layer = "/0"
boundary_layer = "/1"

no_definition_query = '"site" > 0 and "site" < 10000'
no_definition_query = '1 = 1'
# getting "Origin <whatever> is not allowed by Access-Control-Allow-Origin."
# errors, seems to go away if the definition query is set to this instead
# of ""?

# for GLEI-2 only
# no_definition_query = "site in (1027, 1041, 1077, 1458, 1465, 1469, 1497, 1514, 1698, 1703, 1859, 1862, 1863, 1866, 1888, 1928, 5512, 5541, 5574, 5634, 5729, 5933, 5950)"
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
    'dojo/dom-attr',
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
    "dijit/form/Select",
    "dijit/form/RadioButton",
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
    domAttr,
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
    CheckBox, Select, RadioButton,
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
            new Color([0,0,255]), 1
        new Color([0,0,0])

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
        q.outFields = ["*"]
        q.geometry = queryGeom
        
        q.where = centroids.getDefinitionExpression()
        
        console.log q
        console.log sites
        
        fieldInfos = [
            { fieldName: "site", visible: true, label: "site: " },
            { fieldName: "name", visible: true, label: "name: " },
            { fieldName: "geomorph", visible: true, label: "geomorph: " },
            { fieldName: "lat", visible: true, label: "lat: ", format: places: 6 },
            { fieldName: "lon", visible: true, label: "lon: ", format: places: 6 },
            { fieldName: "year", visible: true, label: "year: " },
        ]

        ### {% if level >= levels.agency %} ###
        fieldInfos = fieldInfos.concat [
            { fieldName: "bird_ibi", visible: true, label: "bird_ibi: " },
            { fieldName: "fish_ibi", visible: true, label: "fish_ibi: " },
            { fieldName: "invert_ibi", visible: true, label: "invert_ibi: " },
            { fieldName: "veg_ibi", visible: true, label: "veg_ibi: " },
        ]
        ### {% endif %} ###

        popupTemplate = new esri.dijit.PopupTemplate
            fieldInfos: fieldInfos
            title: "{site}"
            
        qt = new esri.tasks.QueryTask layer_url + boundary_layer
        def = qt.execute q
        def.addCallback (result) ->

            dojo.map result.features, (f) ->
                f.setInfoTemplate popupTemplate
                return f

        map.infoWindow.setFeatures [def]
        # show the popup
        map.infoWindow.show e.screenPoint, map.getInfoWindowAnchor e.screenPoint
    ### set_legend #################################################################

    set_legend = (which) ->

        renderer = renderers[which]
        
        window.theme_name = which

        if not renderer
            renderer = make_renderer which
        else
            centroids.setRenderer(renderer)
            map.removeLayer(centroids)
            map.addLayer(centroids)
            centroids.hide()
            centroids.show()
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
    ### {% if level >= levels.agency %} ###

    ### show_species ###############################################################

    species_table = "/2"

    show_species = (evt) ->
        feature = map.infoWindow.getSelectedFeature()
        
        site = feature.attributes.site

        q = new esri.tasks.Query()
        q.returnGeometry = true
        q.outFields = ["site", "taxa", "name"]
        q.where = "site = #{site}"

        qt = new esri.tasks.QueryTask layer_url + species_table
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
            
            q.where = centroids.getDefinitionExpression()
            
            map.enableMapNavigation()
        
            qt = new esri.tasks.QueryTask layer_url + boundary_layer
            def = qt.execute q
            def.addCallback (result) ->
            
                    
                symbol = new SimpleMarkerSymbol(
                    SimpleMarkerSymbol.STYLE_CIRCLE, 
                    12, 
                    new SimpleLineSymbol(
                        SimpleLineSymbol.STYLE_SOLID, 
                        new Color [0, 255, 255, 0.5], 
                        0
                    ), new Color [0, 255, 255, 1])      
            
                for i in result.features
                
                    if i.attributes.site not in window.highlighted_sites
                        window.highlighted_sites.push i.attributes.site
                        if i.attributes.site not in window.selected_sites
                            window.selected_sites.push i.attributes.site
                        locationGraphic = new Graphic i.geometry.getExtent().getCenter(),
                            symbol
                        map.graphics.add locationGraphic

                text = "#{result.features.length} sites."
                dom.byId('select_results').innerHTML = text
                
        map.disableMapNavigation()
        esri.bundle.toolbars.draw.addShape = "Click and drag from corner to corner"
        dom.byId('select_results').innerHTML = 
                    "Draw a rectangle on the map"
        toolbar.activate esri.toolbars.Draw.RECTANGLE

    ### clear_site_selection #######################################################

    clear_site_selection = ->
        window.highlighted_sites = []
        window.selected_sites = []
        dom.byId('select_results').innerHTML = "No sites selected."
        map.graphics.clear()
        centroids.setDefinitionExpression no_definition_query
        sites.setDefinitionExpression no_definition_query
        set_legend "geomorph"  # because other renderers hide sites

    ### selected_only ##############################################################

    selected_only = (evt, force = false) ->

        if (not force and centroids.getDefinitionExpression() and
            centroids.getDefinitionExpression() != no_definition_query and
            window.highlighted_sites.length == 0)
                centroids.setDefinitionExpression no_definition_query
                sites.setDefinitionExpression no_definition_query
        else
            if not force and window.highlighted_sites.length != 0
                window.selected_sites = window.highlighted_sites
            definition = "SITE in (#{window.selected_sites.toString()})"
            centroids.setDefinitionExpression definition
            sites.setDefinitionExpression definition

        text = "#{window.selected_sites.length} sites selected."
        dom.byId('select_results').innerHTML = text

        map.graphics.clear()
        window.highlighted_sites = []
    ### show_only ##################################################################

    show_only = ->

        q = new esri.tasks.Query()
        q.returnGeometry = false
        q.outFields = ["site"]
        combine = if registry.byId("spp_any").get('checked') then ' or' else ' and'
        current = ''
        where = ''
        for taxa in ['amphibian', 'bird', 'fish', 'invertebrate', 'plant']
            if registry.byId("i_"+taxa).get('checked')
                where += "#{current} \"taxa\" like '%#{taxa}%'"
                current = combine
        console.log(where)
        
        q.where = where

        qt = new esri.tasks.QueryTask layer_url + centroid_layer
        def = qt.execute q
        def.addCallback (result) ->   
            sites = (feature.attributes.site for feature in result.features)
            console.log sites
            console.log window.selected_sites
            if window.selected_sites and window.selected_sites.length > 0
                sites = (site for site in sites when site in window.selected_sites)
                
            console.log sites
            
            window.selected_sites = sites
            #centroids.setDefinitionExpression no_definition_query
            #sites.setDefinitionExpression no_definition_query

            selected_only(evt=null, force=true)
            
    ### links from popup ###########################################################

    link = domConstruct.create "a",
        "class": "action" 
        "id": "statsLink"
        "innerHTML": "Species",
        "href": "javascript: void(0);"
      ,
        dojo_query(".actionList", map.infoWindow.domNode)[0]

    dojo_on link, "click", show_species

    ### {% endif %} ###
    ### do_legend #####################################################################

    do_legend = (evt) ->

        layerInfo = arrayUtils.map evt.layers, (layer, index) ->
            layer:layer.layer
            title: layer.layer.name # window.theme_name
        
        if layerInfo.length > 0
            legendDijit = new Legend 
                map: map
                layerInfos: layerInfo
              ,
                "legendDiv"
            legendDijit.startup()
            map.legend = legendDijit
    ### set up layer picker - map layer version ####################################

    ###
    this version works with a ArcGISDynamicMapServiceLayer (called 'sites'),
    disabled for now
    ###

    layer_list_setup_map_layer = (evt) ->
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

    # map.on "layers-add-result", layer_list_setup_map_layer

    ### set up layer picker - feature layer version ################################

    layer_list_setup_feature_layer = (evt) ->
        ul = dojo_query "#layers"
        for layer in layers_list
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
                layer.setVisibility(visible)

    map.on "layers-add-result", layer_list_setup_feature_layer

    ### BasemapGallery #############################################################

    basemapGallery = new BasemapGallery
        showArcGISBasemaps: true
        map: map, 
        "basemapGallery"
        
    basemapGallery.startup()

    ### find address / site ########################################################

    locator = new Locator protocol+"//geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"

    locate = (address, status) ->
        
        status.innerHTML = 'Searching...'

        ### if only digits, treat as a site number ###
        is_site_num = true
        for c in address
            if c not in '0123456789'
                is_site_num = false
                break
                
        is_coord = true
        for c in address
            if c not in '°,WwEeNnSs -.0123456789'
                is_coord = false
                break
        
        if is_site_num    
        
            q = new esri.tasks.Query()
            q.returnGeometry = true
            q.outFields = ["site", "name", "geomorph", 'lat', 'lon']
            q.where = "site = #{address}"
        
            qt = new esri.tasks.QueryTask layer_url + boundary_layer
            def = qt.execute q
            def.addCallback (result) ->
                if result.features.length > 0
                    status.innerHTML = ""
                    map.setExtent result.features[0].geometry.getExtent().expand 1.5
                else
                    status.innerHTML = "Site #{address} not found"     
        else if is_coord
        
            sign = 1
            if 'w' in address.toLowerCase()
                sign = -1
            address = address.replace /[,°NnSsEeWw]/g, ' '
            address = address.split /\s+/
            address = address.map (ll) -> parseInt ll, 10
            address[1] *= sign
            if address[1] > 0
                address[1] *= -1
                
            address = new Point address[1], address[0]
            map.centerAt address
            
            symbol = new SimpleMarkerSymbol(
                SimpleMarkerSymbol.STYLE_CIRCLE, 
                12, 
                new SimpleLineSymbol(
                    SimpleLineSymbol.STYLE_SOLID, 
                    new Color [80, 255, 80, 0.5], 
                    0
                ), new Color [80, 255, 80, 1])      
        
            locationGraphic = new Graphic address, symbol
            map.graphics.add locationGraphic
            
        else
            locator.addressToLocations
                address: SingleLine: address + ', U.S.A.'
                outFields: ["*"]
        
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

    simple_renderer = new SimpleRenderer star

    line_renderer = SimpleRenderer perimeter

    ### UniqueValueRenderer ########################################################

    unique_renderer = new UniqueValueRenderer null, 'geomorph'

    things =[
        value: 'riverine', color: [0,200,0]
      ,
        value: 'barrier (protected)', color: [0,0,255]
      ,
        value: 'lacustrine (coastal)', color: [255,127,0]
    ]

    for thing in things                
        unique_renderer.addValue 
            value: thing.value
            symbol:
                new SimpleMarkerSymbol SimpleMarkerSymbol.STYLE_CIRCLE, 10,
                    null # new SimpleLineSymbol SimpleLineSymbol.STYLE_SOLID,
                    #    new Color(thing.color), 2,
                    new Color(thing.color)
            label: thing.value
            description: thing.value

    year_renderer = new UniqueValueRenderer null, 'year'

    things =[
        value: '2011', color: [255, 127, 28], shape: SimpleMarkerSymbol.STYLE_CIRCLE
      ,
        value: '2012', color: [204, 101, 73], shape: SimpleMarkerSymbol.STYLE_SQUARE
      ,
        value: '2013', color: [153, 76, 119], shape: SimpleMarkerSymbol.STYLE_DIAMOND
      ,
        value: '2014', color: [102, 51, 164], shape: SimpleMarkerSymbol.STYLE_CROSS
      ,
        value: '2015', color: [52, 26, 209], shape: SimpleMarkerSymbol.STYLE_X
    ]

    for thing in things                
        year_renderer.addValue 
            value: thing.value
            symbol:
                new SimpleMarkerSymbol thing.shape, 10,
                    new SimpleLineSymbol SimpleLineSymbol.STYLE_SOLID,
                        new Color(thing.color), 2,
                    new Color(thing.color)
            label: thing.value
            description: thing.value

    ### ClassBreaksRenderer ########################################################

    breaks_renderer = new ClassBreaksRenderer star, 'lon'
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
        
        breaks_renderer.addBreak start, stop, # star,
            new SimpleMarkerSymbol SimpleMarkerSymbol.STYLE_CIRCLE, 8,
                new SimpleLineSymbol SimpleLineSymbol.STYLE_SOLID,
                    new Color([100,100,100]), 1,
                new Color(colors[i])
    ### make_renderer ########################################################

    make_renderer = (which) ->

        breaks_renderer = new ClassBreaksRenderer null, which
        
        colors = [
            [163,0,0],
            [254,0,0],
            [255,191,0],
            [255,255,0],
            [195,255,195],
            [2,194,0],
            [1,100,0],
        ]
        name_lists = 
            fish_ibi: 
                names: [
                    "Highly degraded",
                    "Degraded",
                    "Moderately impacted",
                    "Reference",
                    ]
                colors: [
                    [254,0,0],
                    [255,191,0],
                    [255,255,0],
                    [2,194,0],
                    ]
                mode: 'as is'

            invert_ibi: 
                names: [
                    "Degraded",
                    "Moderately degraded",
                    "Moderately impacted",
                    "Mildly impacted",
                    "Reference",
                    ]
                colors: [
                    [254,0,0],
                    [255,191,0],
                    [255,255,0],
                    [2,194,0],
                    [1,100,0],
                    ]
                mode: 'as is'

            veg_ibi: 
                names: [
                    "Lowest score",
                    " ",
                    " ",
                    " ",
                    "Highest score",
                    ]
                colors: [
                    [254,0,0],
                    [255,191,0],
                    [255,255,0],
                    [2,194,0],
                    [1,100,0],
                    ]
                mode: 'as is'
                
            bird_ibi: 
                names: [
                    "Lowest score",
                    " ",
                    " ",
                    " ",
                    "Highest score",
                    ]
                colors: [
                    [254,0,0],
                    [255,191,0],
                    [255,255,0],
                    [2,194,0],
                    [1,100,0],
                    ]
                mode: 'quintile'
        
        colors = name_lists[which]['colors']
        names = name_lists[which]['names']
        mode = name_lists[which]['mode']
        
        if centroids.getDefinitionExpression() != no_definition_query
            # don't use the explicit names
            colors = name_lists['veg_ibi']['colors']
            names = name_lists['veg_ibi']['names']
            
        q = new esri.tasks.Query()
        q.returnGeometry = false
        q.outFields = [which]
        q.where = centroids.getDefinitionExpression()

        qt = new esri.tasks.QueryTask layer_url + centroid_layer
        def = qt.execute q

        def.addCallback do (colors=colors, names=names, which=which, mode=mode) -> (result) ->  
        
            values = []
            
            for feature in result.features
                x = feature.attributes[which]
                if x isnt null and not isNaN(x) and x > 0
                    # Grrr, ArcGIS is translating null to zero
                    values.push parseFloat(x)
                    
            breaks = []
                    
            if mode != 'quintile'
                range = [
                    values.reduce (a,b) -> Math.min a,b  # two ways
                  ,
                    Math.max values...                   # to do this
                ]
                steps = colors.length
                step = (range[1] - range[0]) / steps
                for i in [0..steps-1]
                    if i == 0
                        start = 0.0001 # -Infinity
                        stop = range[0]+(i+1)*step
                    else if i == steps - 1
                        start = range[0]+i*step
                        stop = +Infinity
                    else
                        start = range[0]+i*step
                        stop = range[0]+(i+1)*step
                    breaks.push
                        start: start
                        stop: stop
                        name: names[i]
                        color: colors[i]
            else
                steps = colors.length
                values.sort (a,b) -> a - b
                step = values.length / 5.0
                for i in [0..steps-1]
                    if i == 0
                        start = 0.0001 # -Infinity
                        stop = values[Math.floor((i+1)*step)]
                    else if i == steps - 1
                        start = values[Math.floor((i)*step)]
                        stop = +Infinity
                    else
                        start = values[Math.floor((i)*step)]
                        stop = values[Math.floor((i+1)*step)]
                    breaks.push
                        start: start
                        stop: stop
                        name: names[i]
                        color: colors[i]
                        
            for break_ in breaks
                    
                breaks_renderer.addBreak 
                    minValue: break_.start
                    maxValue: break_.stop
                    symbol:
                        new SimpleMarkerSymbol SimpleMarkerSymbol.STYLE_CIRCLE, 10,
                            new SimpleLineSymbol SimpleLineSymbol.STYLE_SOLID,
                                new Color([100,100,100]), 1,
                            new Color(break_.color)
                    label: break_.name
                
            centroids.setRenderer(breaks_renderer)
        
            centroids.hide()
            centroids.show()
            
            #X dojo_query('#legendDiv')[0].innerHTML = ''
            #X domAttr.remove(dojo_query('#legendDiv')[0], 'widgetid')
            #X console.log dojo_query('#legendDiv')
            #X do_legend
            #X     layers: [centroids, sites]
            
    ### load layers ################################################################

    renderer = breaks_renderer

    centroids = new FeatureLayer layer_url+centroid_layer,
        mode: FeatureLayer.MODE_SNAPSHOT,
        outFields: ["*"]

    centroids.setRenderer(renderer)

    sites = new FeatureLayer layer_url+boundary_layer,
        mode: FeatureLayer.MODE_SNAPSHOT,
        outFields: ["*"]

    sites.setRenderer(line_renderer)

    centroids.setDefinitionExpression no_definition_query
    sites.setDefinitionExpression no_definition_query

    layers_list = [sites, centroids]
    map.addLayers layers_list

    renderers = 
        geomorph: unique_renderer
        samp_year: year_renderer

    set_legend 'geomorph'
    ### connect signals ############################################################

    map.query_click = map.on 'click', querySites
    basemapGallery.on 'selection-change', -> 
        registry.byId("basemap-gallery-pane").toggle()

    # may or may not exist depending on user level
    if registry.byId("select-clear")
        registry.byId("select-clear").on "click", clear_site_selection
        registry.byId("select-rect").on "click", -> select 'rectangle' 
        registry.byId("select-only").on "click", selected_only

    if registry.byId("show-only")
        registry.byId("show-only").on "click", show_only

    registry.byId("legend-pick").on "change", ->
        set_legend registry.byId("legend-pick").get('value')
    if registry.byId("legend-redo")
        registry.byId("legend-redo").on "click", ->
            set_legend registry.byId("legend-pick").get('value')

    map.on "layers-add-result", do_legend

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



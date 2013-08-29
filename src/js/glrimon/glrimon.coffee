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
    parser.parse()
    
    locator = new Locator         "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
    
    locate = ->
    
        console.log 'locating'
    
        address = {
             SingleLine: dom.byId("address").value
        }
        options = {
            address: address,
            outFields: ["*"]
        }
        # optionally return the out fields if you need to calculate the extent of the geocoded point
        locator.addressToLocations(options)
    
    ### click the Find button ###
    registry.byId("locate").on "click", locate  
    registry.byId("address").on "keyup", (evt) ->
        if evt.keyCode != Keys.ENTER
            return
        locate()
    
    locator.on "address-to-locations-complete", (evt) ->
        console.log "address-to-locations-complete"
        map.graphics.clear()
        arrayUtils.forEach(evt.addresses, (geocodeResult, index) ->
            r = Math.floor(Math.random() * 250)
            g = Math.floor(Math.random() * 100)
            b = Math.floor(Math.random() * 100)
          
            symbol = new SimpleMarkerSymbol(
              SimpleMarkerSymbol.STYLE_CIRCLE, 
              20, 
              new SimpleLineSymbol(
                SimpleLineSymbol.STYLE_SOLID, 
                new Color([r, g, b, 0.5]), 
                10
              ), new Color([r, g, b, 0.9]))
            pointMeters = webMercatorUtils.geographicToWebMercator(geocodeResult.location)
            locationGraphic = new Graphic(pointMeters, symbol)
           
            font = new Font().setSize("12pt").setWeight(Font.WEIGHT_BOLD)
            textSymbol = new TextSymbol(
              (index + 1) + ".) " + geocodeResult.address, 
              font, 
              new Color([r, g, b, 0.8])
            ).setOffset(5, 15)

            map.graphics.add(locationGraphic)
            map.graphics.add(new Graphic(pointMeters, textSymbol))
        )
        ptAttr = evt.addresses[0].attributes
        minx = parseFloat(ptAttr.Xmin)
        maxx = parseFloat(ptAttr.Xmax)
        miny = parseFloat(ptAttr.Ymin)
        maxy = parseFloat(ptAttr.Ymax)
    
        esriExtent = new Extent(minx, miny, maxx, maxy, new SpatialReference({wkid:4326}))
        map.setExtent(webMercatorUtils.geographicToWebMercator(esriExtent))

        # showResults(evt.addresses);
    
    
    ###

    map.on("extent-change", updateExtent);

    function updateExtent() {
      dom.byId("currentextent").innerHTML = "<b>Current Extent JSON:</b> " + JSON.stringify(map.extent.toJson());
      dom.byId("currentextent").innerHTML += "<br/><b>Current Zoom level:</b> " + map.getLevel();
    }

    function showResults(results) {
      var rdiv = dom.byId("resultsdiv");
      rdiv.innerHTML = "<p><b>Results : " + results.length + "</b></p>";
      
      var content = [];
      arrayUtils.forEach(results, function(result, index) {             
        var x = result.location.x.toFixed(5);
        var y = result.location.y.toFixed(5);
        content.push("<fieldset>");
        content.push("<legend><b>" + (index + 1) + ". " + result.address + "</b></legend>");
        content.push("<i>Score:</i> " + result.score);
        content.push("<br/>");
        content.push("<i>Address Found In</i> : " + result.address);
        content.push("<br/><br/>");
        content.push("Latitude (y): " + y);
        content.push("  ");
        content.push("Longitude (x): " + x);
        content.push("<br/><br/>");
        content.push("<b>GeoRSS-Simple</b><br/>");
        content.push("<georss:point>" + y + " " + x + "</georss:point>");
        content.push("<br/><br/>");
        content.push("<b>GeoRSS-GML</b><br/>");
        content.push("<georss:where><gml:Point><gml:pos>" + y + " " + x + "</gml:pos><gml:Point></georss:where>");
        content.push("<br/><br/>");
        content.push("<b>Esri JSON</b><br/>");
        content.push("<b>WGS:</b> " + JSON.stringify(result.location.toJson()));
        content.push("<br/>");
        
        var location_wm = webMercatorUtils.geographicToWebMercator(result.location);
        
        content.push("<b>WM:</b> " + JSON.stringify(location_wm.toJson()));
        content.push("<br/><br/>");
        content.push("<b>Geo JSON</b><br/>");
        content.push('"geometry": {"type": "Point", "coordinates": [' + y + ',' + x + ']}');
        content.push("<br/><br/>");
        content.push("<input type='button' value='Center At Address' onclick='zoomTo(" + y + "," + x + ")'/>");
        content.push("</fieldset>");
      });
      rdiv.innerHTML += content.join("");
    }

    ###          
  
    ###
  
  function zoomTo(lat, lon) {
    require([
      "esri/geometry/Point", "esri/geometry/webMercatorUtils"
    ], function(Point, webMercatorUtils) {
      var point = new Point(lon, lat, {
        wkid: "4326"
      });
      var wmpoint = webMercatorUtils.geographicToWebMercator(point);
      map.centerAt(wmpoint);
    });
  }
    ###
    
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
    
    rivers = new ArcGISDynamicMapServiceLayer layer_url,
        mode: ArcGISDynamicMapServiceLayer.MODE_ONDEMAND,
        outFields: ["*"]

    star = new SimpleMarkerSymbol SimpleMarkerSymbol.STYLE_SQUARE, 8,
        new SimpleLineSymbol SimpleLineSymbol.STYLE_SOLID,
            new Color([255,0,0]), 2,
        new Color([0,255,0,0.25])
    
    renderer = new ClassBreaksRenderer star, 'logn'
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
    
    # renderer = new SimpleRenderer star
    
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
            legendDijit = new Legend 
                map: map
                layerInfos: layerInfo
              ,
                "legendDiv"
            legendDijit.startup()

    map.addLayers [rivers]

    dojo.connect map, 'onClick', querySites
// Generated by CoffeeScript 1.4.0

/* setup
*/


(function() {
  var boundary_layer, centroid_layer, layer_url, map, no_definition_query, protocol,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  map = {};

  window.selected_sites = [];

  window.highlighted_sites = [];

  window.theme_name = 'geomorph';

  protocol = 'http:';

  layer_url = "{% url 'dlayer.views.gis' %}cwmlyr00";

  centroid_layer = "/0";

  boundary_layer = "/1";

  no_definition_query = '"site" > 0 and "site" < 10000';

  no_definition_query = '1 = 1';

  /* main
  */


  require(['esri/map', 'esri/layers/ArcGISDynamicMapServiceLayer', 'esri/layers/WMSLayer', 'esri/layers/FeatureLayer', 'esri/dijit/Legend', 'esri/tasks/query', 'esri/layers/LayerDrawingOptions', 'esri/renderers/SimpleRenderer', 'esri/renderers/UniqueValueRenderer', 'esri/renderers/ClassBreaksRenderer', 'esri/symbols/SimpleMarkerSymbol', 'esri/symbols/SimpleLineSymbol', 'esri/symbols/SimpleFillSymbol', 'esri/toolbars/draw', 'dojo/_base/Color', 'dojo/_base/array', 'dojo/parser', 'esri/dijit/BasemapGallery', 'esri/arcgis/utils', 'esri/dijit/Popup', 'esri/dijit/PopupTemplate', 'esri/dijit/Measurement', 'dojo/dom-class', 'dojo/dom-construct', 'dojo/dom-attr', 'dojo/on', 'dojo/keys', 'dojox/charting/Chart', 'dojox/charting/themes/Dollar', 'esri/tasks/locator', 'esri/SpatialReference', 'esri/graphic', 'esri/symbols/Font', 'esri/symbols/TextSymbol', 'esri/geometry/Point', 'esri/geometry/Extent', 'esri/geometry/webMercatorUtils', 'esri/layers/ImageParameters', 'dojo/number', 'dojo/dom', 'dojo/json', 'dijit/registry', 'dojo/query', 'dijit/Dialog', 'dijit/form/TextBox', 'dijit/form/Button', "dijit/form/CheckBox", "dijit/form/Select", "dijit/form/RadioButton", 'dijit/layout/BorderContainer', 'esri/config', 'esri/sniff', 'esri/SnappingManager', 'esri/tasks/GeometryService', 'dijit/layout/ContentPane', 'dijit/layout/AccordionContainer', 'dijit/TitlePane', 'dijit/form/Textarea', 'esri/dijit/Scalebar', 'dijit/form/CheckBox', 'dojo/domReady!'], function(Map, ArcGISDynamicMapServiceLayer, WMSLayer, FeatureLayer, Legend, Query, LayerDrawingOptions, SimpleRenderer, UniqueValueRenderer, ClassBreaksRenderer, SimpleMarkerSymbol, SimpleLineSymbol, SimpleFillSymbol, Draw, Color, arrayUtils, parser, BasemapGallery, arcgisUtils, Popup, PopupTemplate, Measurement, domClass, domConstruct, domAttr, dojo_on, Keys, Chart, theme, Locator, SpatialReference, Graphic, Font, TextSymbol, Point, Extent, webMercatorUtils, ImageParameters, number, dom, JSON, registry, dojo_query, Dialog, TextBox, Button, CheckBox, Select, RadioButton, BorderContainer, esriConfig, has, SnappingManager, GeometryService) {
    /* setup misc
    */

    var basemapGallery, breaks_renderer, centroids, clear_site_selection, colors, do_legend, i, layer_list_setup_feature_layer, layer_list_setup_map_layer, layers_list, line_renderer, link, locate, locator, make_renderer, perimeter, popup, querySites, range, renderer, renderers, select, selected_only, set_legend, show_only, show_species, simple_renderer, sites, species_table, star, start, step, steps, stop, thing, things, unique_renderer, year_renderer, _i, _j, _k, _len, _len1, _ref;
    parser.parse();
    popup = new Popup({
      titleInBody: false
    }, domConstruct.create("div"));
    star = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE, 8, new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, new Color([0, 0, 255]), 2), new Color([0, 255, 0, 0.25]));
    perimeter = new SimpleFillSymbol(SimpleFillSymbol.STYLE_NULL, new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, new Color([0, 0, 255]), 1), new Color([0, 0, 0]));
    /* querySites
    */

    querySites = function(e) {
      /* query server for sites near mouseclick
      */

      var def, fieldInfos, pad, popupTemplate, q, qt, queryGeom;
      pad = map.extent.getWidth() / map.width * 5;
      queryGeom = new esri.geometry.Extent(e.mapPoint.x - pad, e.mapPoint.y - pad, e.mapPoint.x + pad, e.mapPoint.y + pad, map.spatialReference);
      q = new esri.tasks.Query();
      q.outSpatialReference = {
        "wkid": map.spatialReference
      };
      q.returnGeometry = true;
      q.outFields = ["*"];
      q.geometry = queryGeom;
      q.where = centroids.getDefinitionExpression();
      console.log(q);
      console.log(sites);
      fieldInfos = [
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
          fieldName: "lat",
          visible: true,
          label: "lat: ",
          format: {
            places: 6
          }
        }, {
          fieldName: "lon",
          visible: true,
          label: "lon: ",
          format: {
            places: 6
          }
        }, {
          fieldName: "year",
          visible: true,
          label: "year: "
        }
      ];
      /* {% if level >= levels.agency %}
      */

      fieldInfos = fieldInfos.concat([
        {
          fieldName: "bird_ibi",
          visible: true,
          label: "bird_ibi: "
        }, {
          fieldName: "fish_ibi",
          visible: true,
          label: "fish_ibi: "
        }, {
          fieldName: "invert_ibi",
          visible: true,
          label: "invert_ibi: "
        }, {
          fieldName: "veg_ibi",
          visible: true,
          label: "veg_ibi: "
        }
      ]);
      /* {% endif %}
      */

      popupTemplate = new esri.dijit.PopupTemplate({
        fieldInfos: fieldInfos,
        title: "{site}"
      });
      qt = new esri.tasks.QueryTask(layer_url + boundary_layer);
      def = qt.execute(q);
      def.addCallback(function(result) {
        return dojo.map(result.features, function(f) {
          f.setInfoTemplate(popupTemplate);
          return f;
        });
      });
      map.infoWindow.setFeatures([def]);
      return map.infoWindow.show(e.screenPoint, map.getInfoWindowAnchor(e.screenPoint));
    };
    /* set_legend
    */

    set_legend = function(which) {
      var renderer;
      renderer = renderers[which];
      window.theme_name = which;
      if (!renderer) {
        return renderer = make_renderer(which);
      } else {
        centroids.setRenderer(renderer);
        map.removeLayer(centroids);
        map.addLayer(centroids);
        centroids.hide();
        return centroids.show();
      }
    };
    /* create map
    */

    map = new Map("map", {
      slider: true,
      sliderStyle: "large",
      basemap: "topo",
      center: [-84, 45],
      zoom: 6,
      infoWindow: popup,
      minScale: 10000000
    });
    map.markers = [];
    /* address locator graphics markers
    */

    /* {% if level >= levels.agency %}
    */

    /* show_species
    */

    species_table = "/2";
    show_species = function(evt) {
      var def, feature, q, qt, site;
      feature = map.infoWindow.getSelectedFeature();
      site = feature.attributes.site;
      q = new esri.tasks.Query();
      q.returnGeometry = true;
      q.outFields = ["site", "taxa", "name"];
      q.where = "site = " + site;
      qt = new esri.tasks.QueryTask(layer_url + species_table);
      def = qt.execute(q);
      return def.addCallback(function(result) {
        var ans, div, feat, h2, name, note, taxa, _i, _len, _ref;
        taxa = '';
        div = domConstruct.create("div");
        _ref = result.features;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          feat = _ref[_i];
          if (feat.attributes.taxa !== taxa) {
            taxa = feat.attributes.taxa;
            h2 = domConstruct.create("h2");
            h2.innerHTML = taxa;
            domConstruct.place(h2, div, 'last');
          }
          name = domConstruct.create("div");
          name.innerHTML = feat.attributes.name;
          domConstruct.place(name, div, 'last');
        }
        if (taxa === '') {
          note = domConstruct.create("p");
          note.innerHTML = "No species reported yet.";
          domConstruct.place(note, div, 'last');
        }
        ans = new Dialog({
          title: "Species for site " + site,
          content: div
        });
        return ans.show();
      });
    };
    /* select
    */

    select = function(shape) {
      var toolbar;
      toolbar = new Draw(map);
      toolbar.on("draw-end", function(evt) {
        var def, q, qt;
        toolbar.deactivate();
        q = new esri.tasks.Query();
        q.outSpatialReference = {
          "wkid": map.spatialReference
        };
        q.returnGeometry = true;
        q.outFields = ["site", "name", "geomorph", 'lon'];
        q.geometry = evt.geometry;
        q.spatialRelationship = Query.SPATIAL_REL_INTERSECTS;
        q.where = centroids.getDefinitionExpression();
        map.enableMapNavigation();
        qt = new esri.tasks.QueryTask(layer_url + boundary_layer);
        def = qt.execute(q);
        return def.addCallback(function(result) {
          var i, locationGraphic, symbol, text, _i, _len, _ref, _ref1, _ref2;
          symbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 12, new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, new Color([0, 255, 255, 0.5], 0)), new Color([0, 255, 255, 1]));
          _ref = result.features;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            i = _ref[_i];
            if (_ref1 = i.attributes.site, __indexOf.call(window.highlighted_sites, _ref1) < 0) {
              window.highlighted_sites.push(i.attributes.site);
              if (_ref2 = i.attributes.site, __indexOf.call(window.selected_sites, _ref2) < 0) {
                window.selected_sites.push(i.attributes.site);
              }
              locationGraphic = new Graphic(i.geometry.getExtent().getCenter(), symbol);
              map.graphics.add(locationGraphic);
            }
          }
          text = "" + result.features.length + " sites.";
          return dom.byId('select_results').innerHTML = text;
        });
      });
      map.disableMapNavigation();
      esri.bundle.toolbars.draw.addShape = "Click and drag from corner to corner";
      dom.byId('select_results').innerHTML = "Draw a rectangle on the map";
      return toolbar.activate(esri.toolbars.Draw.RECTANGLE);
    };
    /* clear_site_selection
    */

    clear_site_selection = function() {
      window.highlighted_sites = [];
      window.selected_sites = [];
      dom.byId('select_results').innerHTML = "No sites selected.";
      map.graphics.clear();
      centroids.setDefinitionExpression(no_definition_query);
      sites.setDefinitionExpression(no_definition_query);
      return set_legend("geomorph");
    };
    /* selected_only
    */

    selected_only = function(evt, force) {
      var definition, text;
      if (force == null) {
        force = false;
      }
      if (!force && centroids.getDefinitionExpression() && centroids.getDefinitionExpression() !== no_definition_query && window.highlighted_sites.length === 0) {
        centroids.setDefinitionExpression(no_definition_query);
        sites.setDefinitionExpression(no_definition_query);
      } else {
        if (!force && window.highlighted_sites.length !== 0) {
          window.selected_sites = window.highlighted_sites;
        }
        definition = "SITE in (" + (window.selected_sites.toString()) + ")";
        centroids.setDefinitionExpression(definition);
        sites.setDefinitionExpression(definition);
      }
      text = "" + window.selected_sites.length + " sites selected.";
      dom.byId('select_results').innerHTML = text;
      map.graphics.clear();
      return window.highlighted_sites = [];
    };
    /* show_only
    */

    show_only = function() {
      var combine, current, def, q, qt, taxa, where, _i, _len, _ref;
      q = new esri.tasks.Query();
      q.returnGeometry = false;
      q.outFields = ["site"];
      combine = registry.byId("spp_any").get('checked') ? ' or' : ' and';
      current = '';
      where = '';
      _ref = ['amphibian', 'bird', 'fish', 'invertebrate', 'plant'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        taxa = _ref[_i];
        if (registry.byId("i_" + taxa).get('checked')) {
          where += "" + current + " \"taxa\" like '%" + taxa + "%'";
          current = combine;
        }
      }
      console.log(where);
      q.where = where;
      qt = new esri.tasks.QueryTask(layer_url + centroid_layer);
      def = qt.execute(q);
      return def.addCallback(function(result) {
        var evt, feature, force, site, sites;
        sites = (function() {
          var _j, _len1, _ref1, _results;
          _ref1 = result.features;
          _results = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            feature = _ref1[_j];
            _results.push(feature.attributes.site);
          }
          return _results;
        })();
        console.log(sites);
        console.log(window.selected_sites);
        if (window.selected_sites && window.selected_sites.length > 0) {
          sites = (function() {
            var _j, _len1, _results;
            _results = [];
            for (_j = 0, _len1 = sites.length; _j < _len1; _j++) {
              site = sites[_j];
              if (__indexOf.call(window.selected_sites, site) >= 0) {
                _results.push(site);
              }
            }
            return _results;
          })();
        }
        console.log(sites);
        window.selected_sites = sites;
        return selected_only(evt = null, force = true);
      });
    };
    /* links from popup
    */

    link = domConstruct.create("a", {
      "class": "action",
      "id": "statsLink",
      "innerHTML": "Species",
      "href": "javascript: void(0);"
    }, dojo_query(".actionList", map.infoWindow.domNode)[0]);
    dojo_on(link, "click", show_species);
    /* {% endif %}
    */

    /* do_legend
    */

    do_legend = function(evt) {
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
        legendDijit.startup();
        return map.legend = legendDijit;
      }
    };
    /* set up layer picker - map layer version
    */

    /*
        this version works with a ArcGISDynamicMapServiceLayer (called 'sites'),
        disabled for now
    */

    layer_list_setup_map_layer = function(evt) {
      var cb, layer, li, ul, _i, _len, _ref, _results;
      ul = dojo_query("#layers");
      _ref = sites.layerInfos;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        layer = _ref[_i];
        li = domConstruct.create('li', {}, ul[0]);
        cb = new CheckBox({
          value: layer.name,
          id: 'cb_' + layer.name,
          checked: layer.defaultVisibility
        }, '');
        domConstruct.place(cb.domNode, li);
        domConstruct.create('label', {
          innerHTML: layer.name,
          "for": 'cb_' + layer.name
        }, li);
        _results.push(cb.on('change', (function(layer) {
          return function(visible) {
            var _ref1;
            if (!visible) {
              sites.visibleLayers = sites.visibleLayers.filter(function(i) {
                return i !== layer.id;
              });
            } else {
              if (_ref1 = layer.id, __indexOf.call(sites.visibleLayers, _ref1) < 0) {
                sites.visibleLayers.push(layer.id);
              }
            }
            return sites.setVisibleLayers(sites.visibleLayers);
          };
        })(layer)));
      }
      return _results;
    };
    /* set up layer picker - feature layer version
    */

    layer_list_setup_feature_layer = function(evt) {
      var cb, layer, li, ul, _i, _len, _results;
      ul = dojo_query("#layers");
      _results = [];
      for (_i = 0, _len = layers_list.length; _i < _len; _i++) {
        layer = layers_list[_i];
        li = domConstruct.create('li', {}, ul[0]);
        cb = new CheckBox({
          value: layer.name,
          id: 'cb_' + layer.name,
          checked: layer.defaultVisibility
        }, '');
        domConstruct.place(cb.domNode, li);
        domConstruct.create('label', {
          innerHTML: layer.name,
          "for": 'cb_' + layer.name
        }, li);
        _results.push(cb.on('change', (function(layer) {
          return function(visible) {
            return layer.setVisibility(visible);
          };
        })(layer)));
      }
      return _results;
    };
    map.on("layers-add-result", layer_list_setup_feature_layer);
    /* BasemapGallery
    */

    basemapGallery = new BasemapGallery({
      showArcGISBasemaps: true,
      map: map
    }, "basemapGallery");
    basemapGallery.startup();
    /* find address / site
    */

    locator = new Locator(protocol + "//geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer");
    locate = function(address, status) {
      var c, def, is_coord, is_site_num, locationGraphic, q, qt, sign, symbol, _i, _j, _len, _len1;
      status.innerHTML = 'Searching...';
      /* if only digits, treat as a site number
      */

      is_site_num = true;
      for (_i = 0, _len = address.length; _i < _len; _i++) {
        c = address[_i];
        if (__indexOf.call('0123456789', c) < 0) {
          is_site_num = false;
          break;
        }
      }
      is_coord = true;
      for (_j = 0, _len1 = address.length; _j < _len1; _j++) {
        c = address[_j];
        if (__indexOf.call('°,WwEeNnSs -.0123456789', c) < 0) {
          is_coord = false;
          break;
        }
      }
      if (is_site_num) {
        q = new esri.tasks.Query();
        q.returnGeometry = true;
        q.outFields = ["site", "name", "geomorph", 'lat', 'lon'];
        q.where = "site = " + address;
        qt = new esri.tasks.QueryTask(layer_url + boundary_layer);
        def = qt.execute(q);
        return def.addCallback(function(result) {
          if (result.features.length > 0) {
            status.innerHTML = "";
            return map.setExtent(result.features[0].geometry.getExtent().expand(1.5));
          } else {
            return status.innerHTML = "Site " + address + " not found";
          }
        });
      } else if (is_coord) {
        sign = 1;
        if (__indexOf.call(address.toLowerCase(), 'w') >= 0) {
          sign = -1;
        }
        address = address.replace(/[,°NnSsEeWw]/g, ' ');
        address = address.split(/\s+/);
        address = address.map(function(ll) {
          return parseFloat(ll);
        });
        address[1] *= sign;
        if (address[1] > 0) {
          address[1] *= -1;
        }
        address = new Point(address[1], address[0]);
        map.centerAt(address);
        symbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 12, new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, new Color([80, 255, 80, 0.5], 0)), new Color([80, 255, 80, 1]));
        locationGraphic = new Graphic(address, symbol);
        return map.graphics.add(locationGraphic);
      } else {
        return locator.addressToLocations({
          address: {
            SingleLine: address + ', U.S.A.'
          },
          outFields: ["*"]
        });
      }
    };
    dojo_query(".search-box").forEach(function(node) {
      var bt, status, tb;
      domConstruct.create("div", {
        innerHTML: "Find site # / address:"
      }, node);
      tb = new TextBox({
        style: 'width: 12em',
        value: '123'
      }, '');
      domConstruct.place(tb.domNode, node);
      bt = new Button({
        innerHTML: "Find"
      }, '');
      domConstruct.place(bt.domNode, node);
      status = domConstruct.create("div", {
        "class": 'find-active'
      }, node);
      tb.on('keyup', (function(tb, status) {
        return function(evt) {
          if (evt.keyCode !== Keys.ENTER) {
            return;
          }
          return locate(tb.get('value'), status);
        };
      })(tb, status));
      return bt.on('click', (function(tb, status) {
        return function(evt) {
          return locate(tb.get('value'), status);
        };
      })(tb, status));
    });
    locator.on("address-to-locations-complete", function(evt) {
      var b, esriExtent, font, g, geocodeResult, i, locationGraphic, maxx, maxy, minx, miny, pointMeters, ptAttr, r, symbol, text, textSymbol, _i, _len, _ref;
      dojo_query(".find-active").forEach(function(node) {
        return node.innerHTML = '';
      });
      console.log(map);
      _ref = map.markers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        console.log(i);
        map.graphics.remove(i);
        console.log('removed');
      }
      map.markers = [];
      geocodeResult = evt.addresses[0];
      r = Math.floor(Math.random() * 250);
      g = Math.floor(Math.random() * 100);
      b = Math.floor(Math.random() * 100);
      symbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 15, new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, new Color([r, g, b, 0.5], 6)), new Color([r, g, b, 0.9]));
      pointMeters = webMercatorUtils.geographicToWebMercator(geocodeResult.location);
      locationGraphic = new Graphic(pointMeters, symbol);
      font = new Font().setFamily('sans-serif').setSize("12pt").setWeight(Font.WEIGHT_BOLD);
      textSymbol = new TextSymbol(geocodeResult.address, font, new Color([r, g, b, 0.8])).setOffset(5, 15);
      map.graphics.add(locationGraphic);
      text = new Graphic(pointMeters, textSymbol);
      map.graphics.add(text);
      map.markers = [locationGraphic, text];
      ptAttr = evt.addresses[0].attributes;
      minx = parseFloat(ptAttr.Xmin);
      maxx = parseFloat(ptAttr.Xmax);
      miny = parseFloat(ptAttr.Ymin);
      maxy = parseFloat(ptAttr.Ymax);
      esriExtent = new Extent(minx, miny, maxx, maxy, new SpatialReference({
        wkid: 4326
      }));
      return map.setExtent(webMercatorUtils.geographicToWebMercator(esriExtent));
    });
    /* SimpleRenderer
    */

    simple_renderer = new SimpleRenderer(star);
    line_renderer = SimpleRenderer(perimeter);
    /* UniqueValueRenderer
    */

    unique_renderer = new UniqueValueRenderer(null, 'geomorph');
    things = [
      {
        value: 'riverine',
        color: [0, 200, 0]
      }, {
        value: 'barrier (protected)',
        color: [0, 0, 255]
      }, {
        value: 'lacustrine (coastal)',
        color: [255, 127, 0]
      }
    ];
    for (_i = 0, _len = things.length; _i < _len; _i++) {
      thing = things[_i];
      unique_renderer.addValue({
        value: thing.value,
        symbol: new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 10, null, new Color(thing.color)),
        label: thing.value,
        description: thing.value
      });
    }
    year_renderer = new UniqueValueRenderer(null, 'year');
    things = [
      {
        value: '2011',
        color: [255, 127, 28],
        shape: SimpleMarkerSymbol.STYLE_CIRCLE
      }, {
        value: '2012',
        color: [204, 101, 73],
        shape: SimpleMarkerSymbol.STYLE_SQUARE
      }, {
        value: '2013',
        color: [153, 76, 119],
        shape: SimpleMarkerSymbol.STYLE_DIAMOND
      }, {
        value: '2014',
        color: [102, 51, 164],
        shape: SimpleMarkerSymbol.STYLE_CROSS
      }, {
        value: '2015',
        color: [52, 26, 209],
        shape: SimpleMarkerSymbol.STYLE_X
      }
    ];
    for (_j = 0, _len1 = things.length; _j < _len1; _j++) {
      thing = things[_j];
      year_renderer.addValue({
        value: thing.value,
        symbol: new SimpleMarkerSymbol(thing.shape, 10, new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, new Color(thing.color), 2), new Color(thing.color)),
        label: thing.value,
        description: thing.value
      });
    }
    /* ClassBreaksRenderer
    */

    breaks_renderer = new ClassBreaksRenderer(star, 'lon');
    colors = [[255, 0, 0], [255, 128, 0], [128, 128, 0], [0, 128, 128], [0, 0, 255]];
    range = [-92, -74];
    steps = colors.length;
    step = (range[1] - range[0]) / steps;
    for (i = _k = 0, _ref = steps - 1; 0 <= _ref ? _k <= _ref : _k >= _ref; i = 0 <= _ref ? ++_k : --_k) {
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
      breaks_renderer.addBreak(start, stop, new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 8, new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, new Color([100, 100, 100]), 1), new Color(colors[i])));
    }
    /* make_renderer
    */

    make_renderer = function(which) {
      var def, mode, name_lists, names, q, qt;
      breaks_renderer = new ClassBreaksRenderer(null, which);
      colors = [[163, 0, 0], [254, 0, 0], [255, 191, 0], [255, 255, 0], [195, 255, 195], [2, 194, 0], [1, 100, 0]];
      name_lists = {
        fish_ibi: {
          names: ["Highly degraded", "Degraded", "Moderately impacted", "Reference"],
          colors: [[254, 0, 0], [255, 191, 0], [255, 255, 0], [2, 194, 0]],
          mode: 'as is'
        },
        invert_ibi: {
          names: ["Degraded", "Moderately degraded", "Moderately impacted", "Mildly impacted", "Reference"],
          colors: [[254, 0, 0], [255, 191, 0], [255, 255, 0], [2, 194, 0], [1, 100, 0]],
          mode: 'as is'
        },
        veg_ibi: {
          names: ["Lowest score", " ", " ", " ", "Highest score"],
          colors: [[254, 0, 0], [255, 191, 0], [255, 255, 0], [2, 194, 0], [1, 100, 0]],
          mode: 'as is'
        },
        bird_ibi: {
          names: ["Lowest score", " ", " ", " ", "Highest score"],
          colors: [[254, 0, 0], [255, 191, 0], [255, 255, 0], [2, 194, 0], [1, 100, 0]],
          mode: 'quintile'
        }
      };
      colors = name_lists[which]['colors'];
      names = name_lists[which]['names'];
      mode = name_lists[which]['mode'];
      if (centroids.getDefinitionExpression() !== no_definition_query) {
        colors = name_lists['veg_ibi']['colors'];
        names = name_lists['veg_ibi']['names'];
      }
      q = new esri.tasks.Query();
      q.returnGeometry = false;
      q.outFields = [which];
      q.where = centroids.getDefinitionExpression();
      qt = new esri.tasks.QueryTask(layer_url + centroid_layer);
      def = qt.execute(q);
      return def.addCallback((function(colors, names, which, mode) {
        return function(result) {
          var break_, breaks, feature, values, x, _l, _len2, _len3, _m, _n, _o, _ref1, _ref2, _ref3;
          values = [];
          _ref1 = result.features;
          for (_l = 0, _len2 = _ref1.length; _l < _len2; _l++) {
            feature = _ref1[_l];
            x = feature.attributes[which];
            if (x !== null && !isNaN(x) && x > 0) {
              values.push(parseFloat(x));
            }
          }
          breaks = [];
          if (mode !== 'quintile') {
            range = [
              values.reduce(function(a, b) {
                return Math.min(a, b);
              }), Math.max.apply(Math, values)
            ];
            steps = colors.length;
            step = (range[1] - range[0]) / steps;
            for (i = _m = 0, _ref2 = steps - 1; 0 <= _ref2 ? _m <= _ref2 : _m >= _ref2; i = 0 <= _ref2 ? ++_m : --_m) {
              if (i === 0) {
                start = 0.0001;
                stop = range[0] + (i + 1) * step;
              } else if (i === steps - 1) {
                start = range[0] + i * step;
                stop = +Infinity;
              } else {
                start = range[0] + i * step;
                stop = range[0] + (i + 1) * step;
              }
              breaks.push({
                start: start,
                stop: stop,
                name: names[i],
                color: colors[i]
              });
            }
          } else {
            steps = colors.length;
            values.sort(function(a, b) {
              return a - b;
            });
            step = values.length / 5.0;
            for (i = _n = 0, _ref3 = steps - 1; 0 <= _ref3 ? _n <= _ref3 : _n >= _ref3; i = 0 <= _ref3 ? ++_n : --_n) {
              if (i === 0) {
                start = 0.0001;
                stop = values[Math.floor((i + 1) * step)];
              } else if (i === steps - 1) {
                start = values[Math.floor(i * step)];
                stop = +Infinity;
              } else {
                start = values[Math.floor(i * step)];
                stop = values[Math.floor((i + 1) * step)];
              }
              breaks.push({
                start: start,
                stop: stop,
                name: names[i],
                color: colors[i]
              });
            }
          }
          for (_o = 0, _len3 = breaks.length; _o < _len3; _o++) {
            break_ = breaks[_o];
            breaks_renderer.addBreak({
              minValue: break_.start,
              maxValue: break_.stop,
              symbol: new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 10, new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, new Color([100, 100, 100]), 1), new Color(break_.color)),
              label: break_.name
            });
          }
          centroids.setRenderer(breaks_renderer);
          centroids.hide();
          return centroids.show();
        };
      })(colors, names, which, mode));
    };
    /* load layers
    */

    renderer = breaks_renderer;
    centroids = new FeatureLayer(layer_url + centroid_layer, {
      mode: FeatureLayer.MODE_SNAPSHOT,
      outFields: ["*"]
    });
    centroids.setRenderer(renderer);
    sites = new FeatureLayer(layer_url + boundary_layer, {
      mode: FeatureLayer.MODE_SNAPSHOT,
      outFields: ["*"]
    });
    sites.setRenderer(line_renderer);
    centroids.setDefinitionExpression(no_definition_query);
    sites.setDefinitionExpression(no_definition_query);
    layers_list = [sites, centroids];
    map.addLayers(layers_list);
    renderers = {
      geomorph: unique_renderer,
      samp_year: year_renderer
    };
    set_legend('geomorph');
    /* connect signals
    */

    map.query_click = map.on('click', querySites);
    basemapGallery.on('selection-change', function() {
      return registry.byId("basemap-gallery-pane").toggle();
    });
    if (registry.byId("select-clear")) {
      registry.byId("select-clear").on("click", clear_site_selection);
      registry.byId("select-rect").on("click", function() {
        return select('rectangle');
      });
      registry.byId("select-only").on("click", selected_only);
    }
    if (registry.byId("show-only")) {
      registry.byId("show-only").on("click", show_only);
    }
    registry.byId("legend-pick").on("change", function() {
      return set_legend(registry.byId("legend-pick").get('value'));
    });
    if (registry.byId("legend-redo")) {
      registry.byId("legend-redo").on("click", function() {
        return set_legend(registry.byId("legend-pick").get('value'));
      });
    }
    map.on("layers-add-result", do_legend);
    map.on('load', function(evt) {
      var m;
      m = new Measurement({
        map: evt.map
      }, 'measurement');
      m.startup();
      dojo_query('#measurement').on('click', function() {
        return evt.map.query_click.remove();
      });
      return m.on('measure-end', function(evt) {
        map.query_click = map.on('click', querySites);
        return m.setTool(evt.toolName, false);
      });
    });
    /* sometimes 1-2 zooms / pans are needed to get features / legend
    to show, so try this to avoid that
    */

    return map.addLayers([]);
  });

}).call(this);

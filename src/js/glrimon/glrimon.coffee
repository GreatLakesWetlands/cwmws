# coffee -bcw js/glrimon/glrimon.coffee &

dojo.require "esri.map"
dojo.require "esri.arcgis.utils"
dojo.require "esri.dijit.Legend"

map = {}

init = ->
    webmapid = "19d06f6ea88f4a53a55e504fae5061cd"
    esri.arcgis.utils.createMap(webmapid, "mapDiv").then (response) -> 
        map = response.map
        legend = new esri.dijit.Legend
            map: map
            layerInfos: esri.arcgis.utils.getLegendLayers response
          ,
            "legendDiv"
            
        legend.startup()

dojo.ready init

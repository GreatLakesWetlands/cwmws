from django.shortcuts import HttpResponse, render_to_response, RequestContext

import sys
if sys.version_info.major > 2:
    from urllib.request import urlopen
else:
    from urllib2 import urlopen

access_levels = {
    'public': 0,
    'agency': 10,
    'collaborator': 20,
    'researcher': 30,
    'corepi': 40,
    'dev': 100,
}

USER_LEVEL = 0
def gis(request):
    """gis - proxy an ArcGIS request

    :Parameters:
    - `request`: request
    """
    
    lookup = {
        'cwmlyr00': 'http://umd-cla-gis01.d.umn.edu/arcgis/rest/services/NRRI/glritest003/MapServer',
    }
    
    path = request.get_full_path().split('/', 4)[3:]
    path[0] = lookup[path[0]]
    path = '/'.join(path)
    #D print(path)
    #D print(request.body)
    data = urlopen(path).read()
    #D print("%d bytes"%len(data))
    
    return HttpResponse(data)
def map(request):
    """map - show the map

    :Parameters:
    - `request`: request
    """

    return render_to_response("dlayer/glritest001.html",
        {
            'level': USER_LEVEL,
            'levels': access_levels,
        },
        RequestContext(request))
def js(request):
    """js - render js through a template

    :Parameters:
    - `request`: request
    """
    
    response = render_to_response("dlayer/js/glrimon.js",
        {
            'level': USER_LEVEL,
            'levels': access_levels,
        },
        RequestContext(request))
    response["Content-type"] = "text/plain"
    return response
# Create your views here.

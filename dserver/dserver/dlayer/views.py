from django.shortcuts import HttpResponse, render_to_response, RequestContext

import urllib

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
    
    path = request.get_full_path().replace('/map/gis', '')
    path = 'http://umd-cla-gis01.d.umn.edu' + path
    print(path)
    #D print(request.body)
    data = urllib.request.urlopen(path).read()
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

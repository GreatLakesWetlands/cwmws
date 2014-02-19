from django.shortcuts import HttpResponse, render_to_response, RequestContext

import urllib
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
            'level': 0,
            'levels': {
                'public': 0,
                'agency': 10,
                'researcher': 20,
                'corepi': 30,
                'dev': 100,
            }
        },
        RequestContext(request))
# Create your views here.

from django.shortcuts import HttpResponse, render_to_response, RequestContext
from django.contrib.auth.models import User, Group
from django.views.decorators.csrf import csrf_exempt

import sys
if sys.version_info.major > 2:
    from urllib.request import urlopen
else:
    from urllib2 import urlopen

access_levels = {
    'public': 0,
    'agency': 10,
    'enduser': 20,
    'researcher': 30,
    'cwmpi': 40,
    'corepi': 50,
    'editor': 60,
    'dev': 100,
}

def get_user_level(user):
    """get_user_level - Return user level from access_levels

    :Parameters:
    - `user`: user to check
    """
    groups = user.groups.values_list('name', flat=True) or ['public']
    return max((access_levels[g] for g in groups))
@csrf_exempt
def gis(request):
    """gis - proxy an ArcGIS request

    :Parameters:
    - `request`: request
    """
    
    level = get_user_level(request.user)
    
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
            'level': get_user_level(request.user),
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
            'level': get_user_level(request.user),
            'levels': access_levels,
        },
        RequestContext(request))
    response["Content-type"] = "text/plain"
    return response
# Create your views here.

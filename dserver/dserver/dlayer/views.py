from django.shortcuts import render, HttpResponse

import urllib

def gis(request):
    """gis - proxy an ArcGIS request

    :Parameters:
    - `request`: request
    """
    
    path = request.get_full_path()[4:]  # remove '/gis'
    path = 'http://umd-cla-gis01.d.umn.edu' + path
    print(path)
    #D print(request.body)
    data = urllib.request.urlopen(path).read()
    #D print("%d bytes"%len(data))
    
    return HttpResponse(data)
# Create your views here.

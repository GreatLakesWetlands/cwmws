from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',

    url(r'^gis/', 'dlayer.views.gis'),
    url(r'^', 'dlayer.views.map'),
    
)

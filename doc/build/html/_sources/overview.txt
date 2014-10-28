System overview
===============

The system presents data for the Great Lakes Coastal Wetlands using:
    
 - `ESRI ArcGIS JavaScript <https://developers.arcgis.com/javascript/>`_
   for map display and spatial queries
 - ESRI GIS Server for data (spatial and tabular) storage and querying
 - `Dojo <http://dojotoolkit.org/>`_ and `Dijit <http://dojotoolkit.org/>`_
   JavaScript libraries - ESRI's choice of JavaScript / HTML widget layers.
 - `CoffeeScript <http://coffeescript.org/>`_ for authoring JavaScript
 - `Sphinx <http://sphinx-doc.org/>`_ and 
   `reStructuredText <http://docutils.sourceforge.net/rst.html>`_ for
   documentation
 - `Django <https://www.djangoproject.com/>`_ the Python web application
   framework for managing user access levels, providing proxy access to
   resources (ESRI GIS Server etc.), and delivering supporting content
 - `Mezzanine Content Management System (CMS) <http://mezzanine.jupo.org/>`_
   for user facing documentation and report delivery
 - `git <http://git-scm.com/>`_ revision control, with hosting on
   `GitHub <https://github.com/GreatLakesWetlands>`_
 - `Apache <http://httpd.apache.org/>`_ for serving the Django web application
   using the WSGI interface.

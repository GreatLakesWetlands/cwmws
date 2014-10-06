glrimon.coffee
==============

useful to automatically convert ``glrimon.coffee`` to ``glrimon.js``
everytime ``glrimon.coffee`` is changed::

/usr/bin/coffee -cw glrimon.coffee &

Global variables
----------------

.. js:data:: map

A global map object

.. js:data:: window.selected_sites, window.highlighted_sites, window.theme_name

some page level data bound to the window object

.. js:data:: protocol

For conveniently switching between `"http"` and `"https"`

Methods
-------

.. js:function:: main

Not really a function called main, just the main Dojo ``require()`` call
which wraps everything else.

.. js:function:: querySites(event)

query server for sites near mouseclick

:param event: the triggering mouse click event


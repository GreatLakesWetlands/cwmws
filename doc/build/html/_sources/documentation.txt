Documentation system
====================

Sphinx is supposed to support CoffeeScript including::
    
    .. automodule:: somefile

but it was not possible to get autodoc (automodule) working for both
Python and CoffeeScript simultaneously, and most of the CoffeeScript
code is wrapped in a Dojo require() function which further complicates
things, so CoffeeScript documentation is handled by extracting all the
lines starting with ``#:`` if .coffee files and treating them as if
they were Sphinx Python docs.  This is done by ``make.sh``.

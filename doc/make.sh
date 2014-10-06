export DJANGO_SETTINGS_MODULE=cwmenduser.settings
export PYTHONPATH=/mnt/usr1/proj/GLRI/Monitor/esriapp/dserver:\
/mnt/usr1/proj/GLRI/Monitor/esriapp/dserver/cwmenduser
python extract_docs.py \
    ../dserver/cwmenduser/dlayer/static/dlayer/js/glrimon.coffee \
    >source/coffeeauto.rst
make $@

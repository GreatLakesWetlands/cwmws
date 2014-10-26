export DJANGO_SETTINGS_MODULE=cwmenduser.settings
export PYTHONPATH=$PWD/../dserver:$PWD/../dserver/cwmenduser
python extract_docs.py \
    ../dserver/cwmenduser/dlayer/static/dlayer/js/glrimon.coffee \
    >source/coffeeauto.rst
make $@

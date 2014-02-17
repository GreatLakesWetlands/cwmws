BASE_DIR=/home/tbrown/Proj/GLRI/Monitor/esriapp/dserver
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"
virtualenv --python=python3 venv
. venv/bin/activate
pip install django
if [ `which django-admin.py` == \
     `readlink -f $BASE_DIR/venv/bin/django-admin.py` ]; then
     # readlink - return sym. link free path, as does `which`
    echo "Correct django-admin.py"
else
    echo "INCORRECT django-admin.py"
fi
django-admin.py startproject dserver
cd dserver
python manage.py syncdb --noinput
python manage.py createsuperuser
python manage.py startapp dlayer

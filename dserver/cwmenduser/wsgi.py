from __future__ import unicode_literals

import os

# TNB
import sys
sys.path[:0] = [
    "/mnt/usr1/beav/site/esriapp/dserver/venv/lib/python2.7/site-packages",
    "/mnt/usr1/beav/site/esriapp/dserver/cwmenduser",
    "/mnt/usr1/beav/site/esriapp/dserver/",
]

sys.path = [i.replace("empty/empty", "esriapp/dserver/venv")
            for i in sys.path]



PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
settings_module = "%s.settings" % PROJECT_ROOT.split(os.sep)[-1]
os.environ.setdefault("DJANGO_SETTINGS_MODULE", settings_module)

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()

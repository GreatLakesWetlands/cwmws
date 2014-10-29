from __future__ import unicode_literals

import os

# TNB
import sys
sys.path.append(os.path.dirname(__file__))
from local_settings import WSGI_PATH
sys.path[:0] = WSGI_PATH

sys.path = [i.replace("empty/empty", "esriapp/dserver/venv")
            for i in sys.path]



PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
settings_module = "%s.settings" % PROJECT_ROOT.split(os.sep)[-1]
os.environ.setdefault("DJANGO_SETTINGS_MODULE", settings_module)
os.environ["LC_ALL"] = 'en_US.UTF-8'
os.environ["LC_LANG"] = 'en_US.UTF-8'
os.environ["LANG"] = 'en_US.UTF-8'

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()

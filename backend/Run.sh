#! /bin/bash

nohup gunicorn -b 0.0.0.0:5000 flask1:app > gunicorn_log.txt 2>&1 &

nohup uwsgi --ini uwsgi.ini > uwsgi.txt 2>&1 &
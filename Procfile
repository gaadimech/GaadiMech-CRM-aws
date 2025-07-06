web: gunicorn --workers=3 --threads=3 --timeout=300 --bind=127.0.0.1:8000 --log-level=info --access-logfile=/var/log/web.log --error-logfile=/var/log/web.err application:application

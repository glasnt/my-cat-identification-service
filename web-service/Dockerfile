
FROM python:3.8-slim

ENV PORT 8080

COPY . ./

RUN pip install Flask gunicorn

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 app:app

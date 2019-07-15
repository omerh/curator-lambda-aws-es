FROM python:3.7-slim-stretch

RUN apt-get update \
  && apt-get install -y zip make \
  && pip install awscli
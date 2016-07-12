FROM armv7/armhf-debian:jessie

MAINTAINER boris
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install -y --no-install-recommends ruby2.1 ruby-sqlite3

USER 1000
EXPOSE 1234
WORKDIR /Kemuri
CMD ruby web-server.rb

ADD . /Kemuri

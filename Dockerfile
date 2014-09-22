FROM debian:stable

MAINTAINER boris
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install -y --no-install-recommends ruby1.9.1 ruby1.9.1-dev ruby-sqlite3

ADD . /Kemuri
USER 1000
EXPOSE 1234
WORKDIR /Kemuri

CMD ruby web-server.rb

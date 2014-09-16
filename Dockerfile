FROM ubuntu:14.04
#make that container based on ubuntu lts

MAINTAINER boris@brzr
RUN apt-get update
#RUN apt-get upgrade
#RUN apt-get install -y ruby1.9.1 ruby1.9.1-dev 
#RUN apt-get install -y sqlite3 libsqlite3-dev build-essential
#RUN gem install sqlite3
RUN apt-get install -y -q ruby1.9.1 ruby1.9.1-dev ruby-sqlite3

ADD . /Kemuri
USER 1000
EXPOSE 1234
WORKDIR /Kemuri

CMD ruby web-server.rb

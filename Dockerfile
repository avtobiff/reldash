FROM debian:testing-slim

ADD . /var/www/reldash/reldash

RUN apt-get update && \
    apt-get -y install ca-certificates git make erlang elixir

RUN cd /var/www/reldash/reldash && make build

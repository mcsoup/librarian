FROM elixir
MAINTAINER Matt Campbell "mcsoup@gmail.com"

WORKDIR /librarian
ADD . /librarian

RUN mix local.hex --force \
 && mix local.rebar --force \
 && cd /librarian \
 && mix deps.get

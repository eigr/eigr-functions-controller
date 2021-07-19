#########################
###### Build Image ######
#########################

FROM bitwalker/alpine-elixir:1.9.4 as builder

ENV MIX_ENV=prod
ENV MIX_HOME=/opt/mix
ENV HEX_HOME=/opt/hex

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /app

COPY mix.lock mix.exs ./
COPY config config

RUN mix deps.get --only-prod && mix deps.compile

COPY priv priv
COPY lib lib

RUN mix release

#########################
##### Release Image #####
#########################

FROM alpine:3

RUN apk add --update openssl ncurses zstd

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/bakeware/permastate_operator .
RUN chown -R nobody: /app

CMD ["./permastate_operator"]

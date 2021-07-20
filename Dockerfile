#########################
###### Build Image ######
#########################
FROM elixir:1.12-alpine as builder

RUN apk add --update git build-base zstd

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

RUN apk add --update openssl zstd

WORKDIR /home/app

COPY --from=builder /app/_build/prod/rel/bakeware/permastate_operator .

RUN chown -R nobody: /home/app

CMD ["./permastate_operator"]

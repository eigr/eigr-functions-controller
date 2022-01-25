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

ENV MIX_ENV=prod

RUN apk upgrade --no-cache && \
    apk add --no-cache --update openssl zstd libgcc libstdc++ ncurses-libs

RUN addgroup -S app && adduser -S app -G app
WORKDIR /home/app

#COPY --from=builder /app/_build/prod/rel/bakeware/eigr_functions_controller .
COPY --from=builder /app/_build/ .

RUN chown -R app: /home/app
USER app

#CMD ["./eigr_functions_controller", "start"]
CMD ["./prod/rel/eigr_functions_controller/bin/eigr_functions_controller", "start"]

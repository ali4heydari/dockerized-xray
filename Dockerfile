# builder stage
FROM golang:1.20.5-alpine3.18 as builder
LABEL maintainer="Ali Heydari <ali4heydari@gmail.com>"
ARG XRAY_TAG="v1.8.3"
# Thanks to wulabing <wulabing@gmail.com> for initial version


WORKDIR /app

RUN apk add --no-cache git && \
    git clone --depth 1 --branch $XRAY_TAG https://github.com/XTLS/Xray-core.git . && \
    go mod download && \
    go build -o xray /app/main/



# runner stage
FROM alpine:3.18 as runner

ENV UUID=""
ENV DEST=""
ENV SERVERNAMES=""
ENV PRIVATEKEY=""
ENV SHORTIDS=""
ENV NETWORK=""
ENV TZ=Asia/Tehran
ENV PATH="${PATH}:/app/bin"

WORKDIR /app

COPY --from=builder /app/xray /app/bin/xray

COPY ./entrypoint.sh ./scheduled-job.sh ./

RUN apk add --no-cache tzdata ca-certificates jq curl libqrencode perl-utils && \
    mkdir -p /var/log/xray && \
    mkdir -p /var/log/xray && \
    chmod +x ./entrypoint.sh ./scheduled-job.sh

EXPOSE 10808
EXPOSE 10809

VOLUME /app/configs

ENTRYPOINT ["/app/entrypoint.sh"]

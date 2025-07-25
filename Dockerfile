FROM alpine:latest

RUN apk update && apk add --no-cache fio

WORKDIR /data

ENTRYPOINT ["fio"]  

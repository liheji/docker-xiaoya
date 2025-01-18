# Builder
FROM alpine as builder

RUN apk add dumb-init

# Create image
FROM xiaoyaliu/alist:hostmode

LABEL MAINTAINER me@yilee.top

ENV TZ=Asia/Shanghai

ARG TARGETARCH

RUN apk add --no-cache tzdata

COPY --chmod=755 --from=builder /usr/bin/dumb-init /dumb-init

COPY --chmod=755 ./*.sh /

RUN /service.sh download

EXPOSE 5678

VOLUME [ "/data", "/script" ]

ENTRYPOINT [ "/dumb-init", "--", "/start.sh" ]

CMD []

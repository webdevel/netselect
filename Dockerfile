FROM alpine:3.13

WORKDIR /app
COPY netselect.c ./
COPY test.sh ./
COPY Makefile ./
COPY README ./
COPY netinet ./netinet/

RUN printf "http://dl-cdn.alpinelinux.org/alpine/v3.13/main\nhttp://dl-cdn.alpinelinux.org/alpine/v3.13/community" > /etc/apk/repositories
RUN set -eux; \
	apk add --no-cache --no-progress --quiet \
	    musl-dev \
	    make \
	    curl \
        gcc \
        g++

ENTRYPOINT ["tail", "-f", "/dev/null"]

FROM scolagreco/alpine-base:v3.16.2

RUN set -x \
	&& apk update \
        && apk add apache2 apache2-utils apache2-ctl apache2-ssl apache2-ldap apache2-proxy apache2-proxy-html \
	&& ln -s /usr/lib/libxml2.so.2 /usr/lib/libxml2.so

EXPOSE 80 443

COPY httpd-foreground /usr/local/bin/

ENTRYPOINT ["httpd-foreground"]

# Metadata params
ARG BUILD_DATE
ARG VERSION="2.4.56"
ARG VCS_URL="https://github.com/scolagreco/docker-apache24.git"
ARG VCS_REF

# Metadata
LABEL maintainer="Stefano Colagreco <stefano@colagreco.it>" \
        org.label-schema.name="Alpine - Apache 2.4" \
        org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.version=$VERSION \
        org.label-schema.vcs-url=$VCS_URL \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.description="Docker Image Alpine Linux con installato Apache."


FROM scolagreco/alpine-base:v3.12.1
MAINTAINER Stefano Colagreco <stefano@colagreco.it>

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $HTTPD_PREFIX/bin:$PATH

WORKDIR $HTTPD_PREFIX

ENV HTTPD_VERSION 2.4.46

COPY httpd.tar.bz2 .

RUN set -x \
        && addgroup -g 82 -S www-data \
        && adduser -u 82 -D -S -G www-data www-data \
	&& mkdir -p "$HTTPD_PREFIX" \
        && chown www-data:www-data "$HTTPD_PREFIX" \
	&& runDeps=' \
		apr-dev \
		apr-util-dev \
		perl \
	' \
	&& apk add --no-cache --virtual .build-deps \
		$runDeps \
		ca-certificates \
		gcc \
		gnupg \
		libc-dev \
		# mod_session_crypto
		openssl \
		openssl-dev \
		# mod_proxy_html mod_xml2enc
		libxml2-dev \
		# mod_lua
		lua-dev \
		make \
		# mod_http2
		nghttp2-dev \
		pcre-dev \
		tar \
		# mod_deflate
		zlib-dev \
	\
	&& mkdir -p src \
	&& tar -xf httpd.tar.bz2 -C src --strip-components=1 \
	&& rm httpd.tar.bz2 \
	&& cd src \
	\
	&& ./configure \
		--prefix="$HTTPD_PREFIX" \
		--with-mpm=event \
		--enable-mods-shared=reallyall \
	&& make -j "$(getconf _NPROCESSORS_ONLN)" \
	&& make install \
	\
	&& cd .. \
	&& rm -r src man manual \
	\
	&& sed -ri \
		-e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
		-e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
		"$HTTPD_PREFIX/conf/httpd.conf" \
	\
	&& runDeps="$runDeps $( \
		scanelf --needed --nobanner --recursive /usr/local \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --virtual .httpd-rundeps $runDeps \
	&& apk del .build-deps

COPY httpd-foreground /usr/local/bin/

EXPOSE 80
CMD ["httpd-foreground"]

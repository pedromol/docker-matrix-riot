FROM alpine:3.11

# Maintainer
MAINTAINER Andreas Peters <support@aventer.biz>

# install homeserver template
COPY adds/start.sh /start.sh

# startup configuration
ENTRYPOINT ["/start.sh"]

# Git branch to download
ARG BV_VEC=v1.5.7
ENV BV_VEC=${BV_VEC:-master}

# To rebuild the image, add `--build-arg REBUILD=$(date)` to your docker build
# command.
ARG REBUILD=0

# update and upgrade
# installing riot.im with nodejs/npm
RUN chmod a+x /start.sh \
    && apk update \
    && apk add \
        curl \
        libevent \
        libffi \
        libjpeg-turbo \
        libressl \
        nodejs \
        npm \
        sqlite-libs \
	    git \
        unzip \
        || exit 1 ; \
    npm install -g webpack http-server yarn \
    && git clone --branch $BV_VEC --depth 1 https://github.com/vector-im/riot-web.git /riot-web \    
    && cd /riot-web \
    && git checkout $BV_VEC \
    && yarn install \
    && rm -rf /riot-web/node_modules/phantomjs-prebuilt/phantomjs \
    && echo "riot:  $BV_VEC " > /synapse.version \
    && yarn build \
    || exit 1 \
    ; \
    mv /riot-web/webapp / ; \
    echo "$BV_VEC" | tr -d v > /webapp/version ; \
    rm -rf /riot-web ; \
    rm -rf /root/.npm ; \
    rm -rf /tmp/* ; \
    rm -rf /usr/local/share/.cache ;\
    rm -rf /usr/lib/node_modules/webpack ;\
    apk del \
        unzip \
        libevent \
        libffi \
        libjpeg-turbo \
        libressl \
        npm \
        sqlite-libs \
	git \
	curl \
        ; \
    rm -rf /var/lib/apk/* /var/cache/apk/*


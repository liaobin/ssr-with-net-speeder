FROM debian:wheezy
MAINTAINER leevix <leevixdev@163.com>

ENV BUILD_ENV build-essential wget unzip
ENV BUILD_DEP python python-m2crypto

ENV SSR_DIR /usr/local/shadowsocks
ENV SSR_URL https://github.com/breakwa11/shadowsocks/archive/manyuser.zip
ENV LIBSODIUM_URL https://github.com/jedisct1/libsodium/archive/stable.zip

ENV SSR_HOST 0.0.0.0
ENV SSR_PORT 8388
ENV SSR_METHOD aes-256-cfb
ENV SSR_PWD mypassword
ENV SSR_PROTOCOL auth_sha1_v2_compatible
ENV SSR_OBFS http_simple_compatible
ENV SSR_TIMEOUT 300

RUN apt-get update && \
    apt-get -y install ${BUILD_ENV} ${BUILD_DEP} && \
    cd /tmp && \
    wget --no-check-certificate ${LIBSODIUM_URL} -O libsodium-src.zip && \
    unzip libsodium-src.zip && \
    cd libsodium-stable && \
    ./configure && make && make install && \
    echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf && \
    ldconfig && \
    cd ../ && \
    wget --no-check-certificate ${SSR_URL} -O shadowsocks-src.zip && \
    unzip shadowsocks-src.zip && \
    mv shadowsocks-manyuser/shadowsocks ${SSR_DIR} && \
    rm -rf shadowsocks* libsodium* && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get -y remove --purge ${BUILD_ENV} && \
    apt-get -y autoremove

EXPOSE ${SSR_PORT}
EXPOSE ${SSR_PORT}/udp

CMD python ${SSR_DIR}/server.py -s ${SSR_HOST} \
                                -p ${SSR_PORT} \
                                -m ${SSR_METHOD} \
                                -k ${SSR_PWD} \
                                -O ${SSR_PROTOCOL} \
                                -o ${SSR_OBFS} \
                                -t ${SSR_TIMEOUT} \
                                --fast-open
  

FROM prosody/prosody:${PROSODY_IMAGE_VERSION:-0.11.7}

RUN apt-get update -qq; \
	apt-get install -qq --no-install-suggests --no-install-recommends \
        build-essential \
        ca-certificates \
        cron \
        curl \
        libldap2-dev \
        libsasl2-dev \
        libssl-dev \
        lua-ldap \
        mercurial \
        python3-dev \
        python3-pip \
        supervisor

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    pip3 install setuptools python-dotenv && \
    pip3 install python-ldap && \
    hg clone https://hg.prosody.im/prosody-modules/ /opt/prosody/modules

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
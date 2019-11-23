FROM ubuntu:16.04
LABEL developer="Wes Young <wes@csirtgadgets.org>"
LABEL docker_maintainer="Scott Finlon (@sfinlon)"

EXPOSE 5000

ENV DOCKER_BUILD=yes

ENV CIF_VERSION=3.0.7

ENV SUDO_USER root
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

ENV CIF_ANSIBLE_ES=localhost:9200

COPY supervisord.conf /usr/local/etc/supervisord.conf
COPY entrypoint /

RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections ; \
    mkdir -p /etc/resolvconf/resolv.conf.d ; \
    mkdir -p /var/log/cif ; \
    chmod 755 /entrypoint ; \
    mkdir -p /var/lib/cif ; \
    mkdir -p /etc/cif ; \
    mkdir -p /etc/cron.d ; \
    useradd cif

RUN apt-get update && apt-get install -y sudo resolvconf supervisor curl \
    wget python-pip build-essential git python-dev python2.7 python-pip \
    python-dev aptitude python-pip libffi-dev libssl-dev sqlite3 \
    software-properties-common jq && \
    cd /tmp && wget https://github.com/csirtgadgets/bearded-avenger/archive/${CIF_VERSION}.tar.gz -O ba.tar.gz && tar -zxf ba.tar.gz ; \
    wget https://github.com/csirtgadgets/bearded-avenger-deploymentkit/archive/${CIF_VERSION}.tar.gz -O dk.tar.gz && tar -zxf dk.tar.gz

WORKDIR /tmp/bearded-avenger-${CIF_VERSION}

RUN pip install --upgrade pip

RUN pip install -r dev_requirements.txt

RUN CIF_ENABLE_INSTALL=1 python setup.py install

RUN pip install 'setuptools>=18.3,<34.0' 'ansible>=2.4,<2.5' ; \
    ansible-galaxy install csirtgadgets.cif,0.0.14

COPY ansible /ansible
RUN pip install 'setuptools>=18.3,<34.0' 'ansible>=2.4,<2.5' && \
    ansible-galaxy install -vfr /ansible/requirements.yaml && \
    cd /tmp/bearded-avenger-deploymentkit-${CIF_VERSION}/ubuntu16 && \
    cp /ansible/site.yml . && \
    ansible-playbook -i "localhost," -c local site.yml -vv --skip-tags tokens

WORKDIR /tmp
RUN rm -Rf /tmp/bearded-avenger* /tmp/ba.tar.gz /tmp/dk.tar.gz

WORKDIR /home/cif

COPY setup-cif-env.py /usr/local/bin/setup-cif-env.py
COPY elasticsearch-token-setup.sh /usr/local/bin/elasticsearch-token-setup.sh

ENTRYPOINT ["/entrypoint", "-n"]

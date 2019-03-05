FROM registry.redhat.io/rhel7:7.6
USER root

RUN INSTALL_PKGS="yum install make gcc perl pcre-devel zlib-devel wget openssl-devel" && \
    yum install -y --setopt=tsflags=nodocs \
      --disablerepo=* \
      --enablerepo=rhel-7-server-rpms \
      --enablerepo=rhel-server-rhscl-7-rpms \
      --enablerepo=rhel-7-server-optional-rpms \
      --enablerepo=rhel-7-server-extras-rpms \
      --enablerepo=google-chrome \
     $INSTALL_PKGS && \
    yum clean all -y && \
    rm -rf /var/cache/yum
COPY . /tmp/src
RUN cd /tmp/src && make TARGET=linux2628 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1

FROM registry.redhat.io/openshift3/ose-haproxy-router
COPY --from=0 /tmp/src/haproxy /usr/sbin
USER haproxy

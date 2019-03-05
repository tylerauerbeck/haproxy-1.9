FROM registry.redhat.io/openshift3/ose-haproxy-router:latest 
USER root

RUN INSTALL_PKGS="yum install make gcc perl pcre-devel zlib-devel wget openssl-devel" && \
    yum install -y --setopt=tsflags=nodocs \
      --disablerepo=* \
      --enablerepo=rhel-7-server-rpms \
      --enablerepo=rhel-server-rhscl-7-rpms \
      --enablerepo=rhel-7-server-optional-rpms \
      --enablerepo=rhel-7-server-extras-rpms \
     $INSTALL_PKGS && \
    yum remove -y haproxy18 && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY . /tmp/src
RUN cd /tmp/src && make TARGET=linux2628 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 && make install PREFIX=/usr && setcap 'cap_net_bind_service=ep' /usr/sbin/haproxy && chown -R :0 /var/lib/haproxy && chmod -R g+w /var/lib/haproxy && cp /tmp/src/haproxy-config.template /var/lib/haproxy/conf

USER 1001
EXPOSE 80 443
WORKDIR /var/lib/haproxy/conf
ENV TEMPLATE_FILE=/var/lib/haproxy/conf/haproxy-config.template \
    RELOAD_SCRIPT=/var/lib/haproxy/reload-haproxy
ENTRYPOINT ["/usr/bin/openshift-router"]

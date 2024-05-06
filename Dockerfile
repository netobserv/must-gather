
FROM quay.io/centos/centos:stream9

RUN set -x; \
    OC_TAR_URL="https://mirror.openshift.com/pub/openshift-v4/$(uname -m)/clients/ocp/latest/openshift-client-linux.tar.gz" && \
    curl -L -q -o /tmp/oc.tar.gz "$OC_TAR_URL" && \
    tar -C /usr/bin/ -xvf /tmp/oc.tar.gz oc && \
    ln -sf /usr/bin/oc /usr/bin/kubectl && \
    rm -f /tmp/oc.tar.gz

# Copy all collection scripts to /usr/bin
COPY collection-scripts/* /usr/bin/

ENTRYPOINT /usr/bin/gather

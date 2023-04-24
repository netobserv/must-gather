FROM quay.io/openshift/origin-must-gather:4.12.0 as builder

FROM quay.io/centos/centos:stream8

COPY --from=builder /usr/bin/oc /usr/bin/oc

# Copy all collection scripts to /usr/bin
COPY collection-scripts/* /usr/bin/

ENTRYPOINT /usr/bin/gather

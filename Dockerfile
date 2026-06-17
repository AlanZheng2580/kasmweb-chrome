FROM kasmweb/chrome:1.19.0

USER root

RUN install -d -o root -g root -m 0755 \
    /opt/kasm/offline-extensions/updates \
    /etc/opt/chrome/policies/managed

COPY --chown=root:root --chmod=0644 kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml
COPY --chown=root:root --chmod=0644 offline-extensions/*.crx /opt/kasm/offline-extensions/
COPY --chown=root:root --chmod=0644 offline-extensions/updates/*.xml /opt/kasm/offline-extensions/updates/
COPY --chown=root:root --chmod=0644 chrome-policies/managed/*.json /etc/opt/chrome/policies/managed/

USER 1000

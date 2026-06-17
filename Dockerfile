FROM kasmweb/chrome:1.19.0

USER root

COPY extensions.json /opt/kasm/extensions.json
COPY blacklist.json /opt/kasm/blacklist.json
COPY kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml
COPY extension-configs/ /opt/kasm/extension-configs/
COPY offline-extensions/ /opt/kasm/offline-extensions/
COPY chrome-policies/managed/ /etc/opt/chrome/policies/managed/

USER 1000

FROM kasmweb/chrome:1.19.0

USER root

RUN apt-get update && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY extensions.json /opt/kasm/extensions.json
COPY blacklist.json /opt/kasm/blacklist.json
COPY kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml
COPY extension-configs/ /opt/kasm/extension-configs/
COPY scripts/configure.sh /opt/kasm/configure.sh

RUN chmod +x /opt/kasm/configure.sh \
    && /opt/kasm/configure.sh \
    && chown -R 1000:1000 /etc/opt/chrome/policies \
    && sed -i '1a /opt/kasm/configure.sh || true' /dockerstartup/custom_startup.sh

USER 1000

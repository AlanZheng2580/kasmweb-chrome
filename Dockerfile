FROM kasmweb/chrome:1.18.0

# USER root
# 
# RUN apt-get update && apt-get install -y --no-install-recommends jq \
#     && rm -rf /var/lib/apt/lists/*
# 
# COPY extensions.json /opt/kasm/extensions.json
# COPY extension-configs/ /opt/kasm/extension-configs/
# COPY scripts/install-extensions.sh /opt/kasm/install-extensions.sh
# 
# RUN chmod +x /opt/kasm/install-extensions.sh \
#     && /opt/kasm/install-extensions.sh
# 
# USER 1000

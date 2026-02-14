FROM debian:trixie
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl nano vim \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY scripts/download-frp.sh /tmp/download-frp.sh
RUN chmod +x /tmp/download-frp.sh && /tmp/download-frp.sh
RUN /tmp/download-frp.sh
RUN mv ~/Workspace/frp/*/frp* /usr/local/bin/
RUN mkdir -p /etc/frp

CMD ["frpc", "-c", "/etc/frp/frpc.toml"]
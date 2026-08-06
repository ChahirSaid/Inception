# FROM debian:bookworm

# RUN apt-get update && apt-get install -y \
# 	curl \
# 	ca-certificates \
# 	&& rm -rf /var/lib/apt/lists/*

# # RUN curl -L https://github.com/portainer/portainer/releases/download/2.39.5/portainer-2.39.5-linux-amd64.tar.gz \
# # 	-o /usr/local/bin/portainer \
# # 	&& chmod +x /usr/local/bin/portainer
# RUN curl -L https://github.com/portainer/portainer/releases/download/2.39.5/portainer-2.39.5-linux-amd64.tar.gz \
# 	-o /tmp/portainer.tar.gz \
# 	&& tar -xzf /tmp/portainer.tar.gz -C /tmp \
# 	&& mv /tmp/portainer/portainer /usr/local/bin/portainer \
# 	&& chmod +x /usr/local/bin/portainer \
# 	&& rm -rf /tmp/portainer /tmp/portainer.tar.gz

# RUN mkdir -p /data

# WORKDIR /opy/portainer

# EXPOSE 9443

# ENTRYPOINT ["/usr/local/bin/portainer"]


FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	curl \
	ca-certificates \
	tar \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/portainer/portainer/releases/download/2.39.5/portainer-2.39.5-linux-amd64.tar.gz \
	-o /tmp/portainer.tar.gz \
	&& tar -xzf /tmp/portainer.tar.gz -C /opt \
	&& mv /opt/portainer /opt/portainer-ce \
	&& ln -s /opt/portainer-ce/portainer /usr/local/bin/portainer \
	&& chmod +x /usr/local/bin/portainer \
	&& rm /tmp/portainer.tar.gz

EXPOSE 9443

ENTRYPOINT ["/usr/local/bin/portainer"]
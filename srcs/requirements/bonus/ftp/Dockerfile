FROM debian:bookworm

RUN apt-get update && apt-get install -y vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/ftp.sh /usr/local/bin/ftp.sh
RUN chmod +x /usr/local/bin/ftp.sh

EXPOSE 21 

ENTRYPOINT ["/usr/local/bin/ftp.sh"]
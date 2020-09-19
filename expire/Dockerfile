FROM alpine:3.12

WORKDIR /root
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc && \
  chmod +x mc && \
  mv mc /usr/local/bin

COPY crontab.txt expire.sh /root/
RUN chmod +x /root/expire.sh
RUN /usr/bin/crontab /root/crontab.txt

ENTRYPOINT ["/usr/sbin/crond", "-f", "-l", "8"]

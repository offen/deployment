# Copyright 2021 - Offen Authors <hioffen@posteo.de>
# SPDX-License-Identifier: MIT

FROM alpine:3.13

RUN addgroup -g 10001 -S expire && \
  adduser -u 10000 -S -G expire -h /home/expire expire

WORKDIR /home/expire
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc && \
  chmod +x mc && \
  mv mc /sbin/mc

COPY crontab.txt expire.sh /home/expire/
RUN chmod +x expire.sh && mv expire.sh /usr/bin/expire
RUN /usr/bin/crontab /home/expire/crontab.txt

ENTRYPOINT ["/usr/sbin/crond", "-f", "-l", "8"]

USER expire

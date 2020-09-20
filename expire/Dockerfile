# Copyright 2020 - Offen Authors <hioffen@posteo.de>
# SPDX-License-Identifier: MIT

FROM alpine:3.12

WORKDIR /root
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc && \
  chmod +x mc && \
  mv mc /usr/bin/mc

COPY crontab.txt expire.sh /root/
RUN chmod +x expire.sh && mv expire.sh /usr/bin/expire
RUN /usr/bin/crontab /root/crontab.txt

ENTRYPOINT ["/usr/sbin/crond", "-f", "-l", "8"]

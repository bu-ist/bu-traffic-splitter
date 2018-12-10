FROM nginx:1.13

ENV DNS_RESOLVER="auto"
ENV DNS_RESOLVER_TIMEOUT "30s"
ENV DEFAULT_URL=""
ENV ALTERNATE_MASK=""
ENV ALTERNATE_URL=""
ENV INTERCEPT_URL=""
ENV ALTERNATE_REF=""
ENV DEBUG=""

RUN mkdir /template

COPY nginx-default.conf /template/nginx-default.conf
COPY nginx.conf /etc/nginx/nginx.conf

COPY run.sh /run.sh
RUN chmod +x /run.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/run.sh"]
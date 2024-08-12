FROM nginx:stable-alpine

ENV NGINXUSER=appuser
ENV NGINXGROUP=appgroup

RUN adduser -g ${NGINXGROUP} -s /bin/sh -D ${NGINXUSER}

RUN mkdir -p /var/www/html

ADD ./nginx/*.conf /etc/nginx/conf.d/

RUN sed -i "s/user = www-data/user = ${NGINXUSER}/g" /etc/nginx/nginx.conf
RUN sed -i "s/group = www-data/group = ${NGINXGROUP}/g" /etc/nginx/nginx.conf
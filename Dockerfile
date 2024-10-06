# Usar uma imagem base oficial do Alpine
FROM alpine:latest

ARG USER_UID=1000
ARG USER_GID=$USER_UID
ENV USER=wandington

RUN addgroup --gid $USER_GID ${USER} \
    && adduser --uid $USER_UID --ingroup ${USER} --disabled-password --gecos "" ${USER}

RUN apk update --no-cache && apk add vim nginx icecast curl

RUN touch /run/nginx/nginx.pid \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
#   && mkdir /etc/nginx/http.d \
    && chown -R ${USER}:${USER} /run/nginx/nginx.pid \
        /var/lib/nginx \
        /var/log/nginx \
        /etc/nginx/http.d
		
COPY nginx/default.conf /etc/nginx/http.d/
COPY icecast/icecast.xml /etc/icecast.xml

RUN chown -R ${USER}:${USER} /usr/share/icecast && chown -R ${USER}:${USER} /var/log/icecast

USER ${USER}

EXPOSE 8000 80

CMD sh -c "nginx -g 'daemon off;' & icecast -c /etc/icecast.xml & wait -n"

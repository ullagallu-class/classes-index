FROM ubuntu:latest
RUN apt update && apt install -y nginx && rm -rf /var/lib/apt/lists/*
RUN rm -rf /var/www/html/* /usr/share/nginx/html/*
COPY index.html /usr/share/nginx/html/index.html
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN echo 'server { \
    listen 80; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ =404; \
    } \
    access_log /dev/stdout; \
    error_log /dev/stderr; \
}' > /etc/nginx/sites-available/default
EXPOSE 80
CMD ["/bin/bash", "-c", "/entrypoint.sh && nginx -g 'daemon off;'"]
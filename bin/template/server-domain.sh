#!/bin/sh

cat > "${CONF_PATH}" << EOT
# ${CONF_PATH}

server {
    listen              [::]:80;
    server_name         ${DOMAIN} ${FULLDOMAIN};

    return 301 https://${SERVER_NAME}\$request_uri;
}

server {
    listen              [::]:443 spdy ssl;
    server_name         ${SERVER_NAME_ALT};

    include             includes/headers.conf;
    include             includes/headers-hsts.conf;
    include             includes/https-ocsp-stapling-responder.conf;
    ssl_certificate     certificates/${DOMAIN}/${SUBDOMAIN}/pem;
    ssl_certificate_key certificates/${DOMAIN}/${SUBDOMAIN}/www/key;

    return 301 https://${SERVER_NAME_ALT}\$request_uri;
}

server {
    listen              [::]:443 spdy ssl;
    server_name         ${SERVER_NAME};

    include             includes/headers.conf;
    include             includes/headers-hsts.conf;
    root                /var/www/${DOMAIN}/${SUBDOMAIN};
    ssl_certificate     certificates/${DOMAIN}/${SUBDOMAIN}/pem;
    ssl_certificate_key certificates/${DOMAIN}/${SUBDOMAIN}/key;

    location / {
        include         includes/protect-system-files.conf;
        include         includes/static-files-hsts.conf;
    }
}
EOT

#!/bin/sh

cat > "${CONF_PATH}" << EOT
# ${CONF_PATH}

server {
    listen              [::]:80;
    server_name         ${FULLDOMAIN};

    return 301 https://${FULLDOMAIN}\$request_uri;
}

server {
    listen              [::]:443 spdy ssl;
    server_name         ${FULLDOMAIN};

    include             includes/headers.conf;
    include             includes/headers-hsts.conf;
    include             includes/https-ocsp-stapling-responder.conf;
    root                /var/www/${DOMAIN}/${SUBDOMAIN};
    ssl_certificate     certificates/${DOMAIN}/${SUBDOMAIN}/pem;
    ssl_certificate_key certificates/${DOMAIN}/${SUBDOMAIN}/key;

    locaton / {
        include         includes/protect-system-files.conf;
        include         includes/static-files-hsts.conf;
    }
}
EOT

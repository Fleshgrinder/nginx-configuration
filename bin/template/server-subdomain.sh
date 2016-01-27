#!/bin/sh

#! ---------------------------------------------------------------------------------------------------------------------
# This file is part of fleshgrinder/nginx-configuration.
#
# fleshgrinder/nginx-configuration is free software: you can redistribute it and/or modify it under the terms of the GNU
# Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
#
# fleshgrinder/nginx-configuration is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public
# License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with fleshgrinder/nginx-configuration.
# If not, see <https://www.gnu.org/licenses/agpl-3.0.html>.
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# Template for server configuration.
#
# @author Richard Fussenegger <richard@fussenegger.info>
# @copyright 2015 (c) Richard Fussenegger
# @license https://www.gnu.org/licenses/agpl-3.0.html AGPLv3
# ----------------------------------------------------------------------------------------------------------------------

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

    include             includes/headers.ngx;
    include             includes/headers-hsts.ngx;
    include             includes/https-ocsp-stapling-responder.ngx;
    root                /var/www/${DOMAIN}/${SUBDOMAIN};
    ssl_certificate     certificates/${DOMAIN}/${SUBDOMAIN}/pem;
    ssl_certificate_key certificates/${DOMAIN}/${SUBDOMAIN}/key;

    locaton / {
        include         includes/protect-system-files.ngx;
        include         includes/static-files-hsts.ngx;
    }
}
EOT

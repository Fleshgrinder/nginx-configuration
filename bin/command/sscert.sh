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
# Generate self-signed certificate which is valid for ten years.
#
# @author Richard Fussenegger <richard@fussenegger.info>
# @copyright 2015 (c) Richard Fussenegger
# @license https://www.gnu.org/licenses/agpl-3.0.html AGPLv3
# ----------------------------------------------------------------------------------------------------------------------

readonly CERT_DIR="${NGINX_DIR}/certificates/_"

mkdir --parents -- "${CERT_DIR}"

if openssl req -batch -nodes -newkey rsa:2048 -sha256 -keyout "${CERT_DIR}/key" -x509 -days 24855 -subj "/C=AT" -out "${CERT_DIR}/pem"; then
    log_ok 'Successfully generated self-signed certificate and key.'
    cat << EOT

CRT_PATH: ${BLUE}${CERT_DIR}/pem${NORMAL}
KEY_PATH: ${BLUE}${CERT_DIR}/key${NORMAL}

The default server configuration is already in-place.
EOT
else
    die 'Failed to generate self-signed certificate and key.'
fi

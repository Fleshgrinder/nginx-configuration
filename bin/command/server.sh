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
# Generate new nginx server configuration.
#
# Examples:
#   $ sudo sh bin/nginx-conf server example.com
#   $ sudo sh bin/nginx-conf server example.com test
#   $ sudo sh bin/nginx-conf server -w example.com
#
# @author Richard Fussenegger <richard@fussenegger.info>
# @copyright 2015 (c) Richard Fussenegger
# @license https://www.gnu.org/licenses/agpl-3.0.html AGPLv3
# ----------------------------------------------------------------------------------------------------------------------

while getopts 'hw' OPT
do
    case "${OPT}" in
        h) usage && exit 0 ;;
        w) WWW=false ;;
        *) usage >&2 && exit ${EC_INVALID_OPT} ;;
    esac
done

[ "${1}" = '--' ] && shift $(( $OPTIND - 1 ))

[ $# -lt 1 ] && usage >&2 && exit ${EC_MISSING_ARG}

readonly DOMAIN="${1}"
readonly SUBDOMAIN="${2:-www}"
readonly FULLDOMAIN="${SUBDOMAIN}.${DOMAIN}"
readonly CONF_PATH="${NGINX_DIR}/sites/${DOMAIN}/${SUBDOMAIN}.conf"
readonly WWW=${WWW:-true}

log "Generating server configuration for ${BLUE}${FULLDOMAIN}${NORMAL} ..."

mkdir --parents -- "$(dirname -- "${CONF_PATH}")"

if [ "${SUBDOMAIN}" != 'www' ]
then
    . "${TPL_DIR}/server-subdomain.sh"
elif [ ${WWW} = false ]
then
    readonly SERVER_NAME="${DOMAIN}"
    readonly SERVER_NAME_ALT="${FULLDOMAIN}"
    . "${TPL_DIR}/server-domain.sh"
else
    readonly SERVER_NAME="${FULLDOMAIN}"
    readonly SERVER_NAME_ALT="${DOMAIN}"
    . "${TPL_DIR}/server-domain.sh"
fi

log_ok 'Successfully generated server configuration.'
cat << EOT

PATH: ${BLUE}${CONF_PATH}${NORMAL}

The configuration was written to above location, make your changes and be sure
to execute '${YELLOW}nginx -t${NORMAL}' before you apply the new configuration.
EOT

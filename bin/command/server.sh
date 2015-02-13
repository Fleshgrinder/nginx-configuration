#!/bin/sh

#! -----------------------------------------------------------------------------
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or distribute
# this software, either in source code form or as a compiled binary, for any
# purpose, commercial or non-commercial, and by any means.
#
# In jurisdictions that recognize copyright laws, the author or authors of this
# software dedicate any and all copyright interest in the software to the public
# domain. We make this dedication for the benefit of the public at large and to
# the detriment of our heirs and successors. We intend this dedication to be an
# overt act of relinquishment in perpetuity of all present and future rights to
# this software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Generate new nginx server configuration.
#
# Examples:
#   $ sudo sh bin/nginx-conf server example.com
#   $ sudo sh bin/nginx-conf server example.com test
#   $ sudo sh bin/nginx-conf server -w example.com
#
# AUTHOR:    Richard Fussenegger <richard@fussenegger.info>
# COPYRIGHT: Copyright (c) 2008-15 Richard Fussenegger
# LICENSE:   http://unlicense.org/ PD
# ------------------------------------------------------------------------------

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

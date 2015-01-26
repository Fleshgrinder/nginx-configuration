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
# Generate new server configuration.
#
# AUTHOR:    Richard Fussenegger <richard@fussenegger.info>
# COPYRIGHT: 2008-15 Richard Fussenegger
# LICENSE:   http://unlicense.org/ PD
# ------------------------------------------------------------------------------

# Check return status of every command.
set -e


# ------------------------------------------------------------------------------ Variables


# For more information on shell colors and other text formatting see:
# http://stackoverflow.com/a/4332530/1251219
readonly RED=$(tput bold; tput setaf 1)
readonly GREEN=$(tput bold; tput setaf 2)
readonly YELLOW=$(tput bold; tput setaf 3)
readonly NORMAL=$(tput sgr0)


# ------------------------------------------------------------------------------ Functions


# Print usage text.
usage()
{
    cat << EOT
Usage: ${0##*/} [OPTION]... HOSTNAME
Generate new server configuration.

    -h  Display this help and exit.

Report bugs to richard@fussenegger.info
GitHub repository https://github.com/Fleshgrinder/nginx-configuration
For complete documentation, see README.md
EOT
}


# ------------------------------------------------------------------------------


# Check for possibly passed options.
while getopts 'h' OPT
do
    case "${OPT}" in
        h|[?]) usage && exit 0 ;;
        *) usage 2>&1 && exit 1 ;;
    esac

    # We have to remove found options from the input for later evaluations of
    # passed arguments in subscripts that are not interested in these options.
    shift $(( $OPTIND - 1 ))
done

# Remove possibly passed end of options marker.
if [ "${1}" = "--" ]
    then shift $(( $OPTIND - 1 ))
fi

# Make sure the script was called correctly, we need the hostname.
if [ "${#}" -lt 1 ]
    then usage 2>&1 && exit 1
fi

printf -- 'Generating server configuration for %s ...\n' "${YELLOW}${1}${NORMAL}"

cat > "/etc/nginx/sites/${1}.conf" << EOT
server {
    listen              [::]:80;
    server_name         ${1} www.${1};

    return 301 https://www.${1}\$request_uri;
}

server {
    listen              [::]:443 spdy ssl;
    server_name         ${1};

    include             includes/headers.conf;
    include             includes/headers-hsts.conf;
    ssl_certificate     certificates/${1}/www/pem;
    ssl_certificate_key certificates/${1}/www/key;

    return 301 https://www.${1}\$request_uri;
}

server {
    listen              [::]:443 spdy ssl;
    server_name         www.${1};

    include             includes/headers.conf;
    include             includes/headers-hsts.conf;
    root                /var/www/${1}/www;
    ssl_certificate     certificates/${1}/www/pem;
    ssl_certificate_key certificates/${1}/www/key;

    location / {

    }
}
EOT

if [ ! -d "/etc/nginx/certificates/${1}/www" ]
    then mkdir --parents -- "/etc/nginx/certificates/${1}/www"
fi

if [ ! -d "/var/www/${1}" ]
    then mkdir --parents -- "/var/www/${1}"
fi

printf -- '[%sok%s] Successfully generated.\n' "${GREEN}" "${NORMAL}"

exit 0

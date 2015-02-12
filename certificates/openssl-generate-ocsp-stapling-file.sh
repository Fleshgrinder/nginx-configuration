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
# Generate OCSP DER file for given hostname.
#
# AUTHOR:    Richard Fussenegger <richard@fussenegger.info>
# COPYRIGHT: Copyright (c) 2008-15 Richard Fussenegger
# LICENSE:   http://unlicense.org/ PD
# ------------------------------------------------------------------------------

readonly __FILENAME__="${0##*/}"
readonly __DIRNAME__="$(cd -- "$(dirname -- "${0}")"; pwd)"

readonly EC_INVALID_OPTION=64
readonly EC_MISSING_ARGUMENT=65
readonly EC_CA_CER_NOT_FOUND=66
readonly EC_ISSUER_CER_NOT_FOUND=67
readonly EC_SERVER_CER_NOT_FOUND=68
readonly EC_OCSP_URI_FAIL=69
readonly EC_GEN_FAILED=70

readonly RED=$(tput bold; tput setaf 1)
readonly GREEN=$(tput bold; tput setaf 2)
readonly YELLOW=$(tput bold; tput setaf 3)
readonly BLUE=$(tput bold; tput setaf 4)
readonly NORMAL=$(tput sgr0)

readonly STARTSSL_BUNDLE='startssl.com/certs/ca-bundle.pem'
readonly STARTSSL_ISSUER='startssl.com/certs/sub.class1.server.ca.pem'

die()
{
    printf -- '[%sfail%s] %s\n' "${RED}" "${NORMAL}" "${1}"
    exit ${2}
}

log()
{
    printf -- '[%sinfo%s] %s\n' "${YELLOW}" "${NORMAL}" "${1}"
}

usage()
{
    cat << EOT
Usage: ${__FILENAME__} [OPTION]... SERVER_NAME [SUBDOMAIN]
Generate OCSP DER file for nginx ocsp_stapling_file directive.

    -h, -?     Display this help and exit.
    -c <path>  Path to the trusted CA certificate, default '${YELLOW}./${STARTSSL_BUNDLE}${NORMAL}'.
    -i <path>  Path to the issuer certificate bundle, default '${YELLOW}./${STARTSSL_ISSUER}${NORMAL}'.
    -o <path>  Output file, default '${YELLOW}./certificates/<SERVER_NAME>/ocsp.der${NORMAL}'.
    -s <path>  Path to the server certificate, default '${YELLOW}./certificates/<SERVER_NAME>/pem${NORMAL}'.

The [SUBDOMAIN] argument is optional and defaults to an empty string. It is used
to build path to the server certificate and key and to pass the correct host to
the OCSP responder. Please refer to the README.d file for more information on
the directory structure of the certificates.

Report bugs to richard@fussenegger.info
GitHub repository: https://github.com/Fleshgrinder/nginx-configuration
For complete documentation, see: README.md
EOT
}

while getopts 'c:hi:o:s:' OPT
do
    case "${OPT}" in
        c) CA_CER="${OPTARG}" ;;
        h|[?]) usage && exit 0 ;;
        i) ISSUER_CER="${OPTARG}" ;;
        o) OUTPUT_DER="${OPTARG}" ;;
        s) SERVER_CER="${OPTARG}" ;;
        *) usage >&2 && exit ${EC_INVALID_OPTION} ;;
    esac
done

[ "${1}" = '--' ] && shift $(( $OPTIND - 1 ))

[ -z "${1}" ] && die 'Server name argument is mandatory.' ${EC_MISSING_ARGUMENT}

SERVER_NAME="${1}"
SUBDOMAIN="${2}"

CA_CER="${CA_CER:-${__DIRNAME__}/${STARTSSL_BUNDLE}}"
ISSUER_CER="${ISSUER_CER:-${__DIRNAME__}/${STARTSSL_ISSUER}}"

if [ -n "${SUBDOMAIN}" ]
then
    DOMAIN="${SUBDOMAIN}.${SERVER_NAME}"
    OUTPUT_DER="${OUTPUT_DER:-${__DIRNAME__}/${SERVER_NAME}/${SUBDOMAIN}/ocsp.der}"
    SERVER_CER="${SERVER_CER:-${__DIRNAME__}/${SERVER_NAME}/${SUBDOMAIN}/pem}"
else
    DOMAIN="${SERVER_NAME}"
    OUTPUT_DER="${OUTPUT_DER:-${__DIRNAME__}/${SERVER_NAME}/ocsp.der}"
    SERVER_CER="${SERVER_CER:-${__DIRNAME__}/${SERVER_NAME}/pem}"
fi

[ ! -f "${CA_CER}" ] && die "Could not find trusted CA certificate '${YELLOW}${CA_CER}${NORMAL}'" ${EC_CA_CER_NOT_FOUND}
[ ! -f "${ISSUER_CER}" ] && die "Could not find issuer certificate bundle '${YELLOW}${ISSUER_CER}${NORMAL}'" ${EC_ISSUER_CER_NOT_FOUND}
[ ! -f "${SERVER_CER}" ] && die "Could not find server certificate '${YELLOW}${SERVER_CER}${NORMAL}'" ${EC_SERVER_CER_NOT_FOUND}

OCSP_URI=$(openssl x509 -in "${SERVER_CER}" -noout -ocsp_uri)
[ $? -ne 0 ] && die '' ${EC_OCSP_URI_FAIL}

HOST="${OCSP_URI#*//}"
HOST="${HOST%%/*}"

if openssl ocsp -issuer "${ISSUER_CER}" -cert "${SERVER_CER}" -url "${OCSP_URI}" -CAfile "${CA_CER}" -VAfile "${CA_CER}" -respout "${OUTPUT_DER}" -header 'Host' "${HOST}" -no_nonce
then
    cat << EOT

[${GREEN} ok ${NORMAL}] Successfully generated OCSP DER file for ${BLUE}${DOMAIN}${NORMAL}.

Add the following to the server block of this domain:

    server {
        ssl_stapling       on;
        ssl_stapling_file  ${OUTPUT_DER#/etc/nginx/*};
    }

EOT
    exit 0
else
    die "OCSP DER file generation failed." ${EC_GEN_FAILED}
fi

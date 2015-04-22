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
# Generate OCSP DER file for nginx ocsp_stapling_file directive.
#
# @author Richard Fussenegger <richard@fussenegger.info>
# @copyright 2015 (c) Richard Fussenegger
# @license https://www.gnu.org/licenses/agpl-3.0.html AGPLv3
# ----------------------------------------------------------------------------------------------------------------------

readonly EC_CA_CER_NOT_FOUND=66
readonly EC_ISSUER_CER_NOT_FOUND=67
readonly EC_SERVER_CER_NOT_FOUND=68
readonly EC_OCSP_URI_FAIL=69
readonly EC_GEN_FAILED=70

readonly CERT_DIR=$(dirname -- "${__DIRNAME__}")/certificates
readonly STARTSSL_BUNDLE='startssl.com/certs/ca-bundle.pem'
readonly STARTSSL_ISSUER='startssl.com/certs/sub.class1.server.ca.pem'

while getopts 'c:hi:o:s:' OPT
do
    case "${OPT}" in
        c) CA_CER="${OPTARG}" ;;
        h) usage && exit 0 ;;
        i) ISSUER_CER="${OPTARG}" ;;
        o) OUTPUT_DER="${OPTARG}" ;;
        s) SERVER_CER="${OPTARG}" ;;
        *) usage >&2 && exit ${EC_INVALID_OPTION} ;;
    esac
done

[ "${1}" = '--' ] && shift $(( $OPTIND - 1 ))

[ -z "${1}" ] && die 'Server name argument is mandatory.' ${EC_MISSING_ARGUMENT}

readonly SERVER_NAME="${1}"
readonly SUBDOMAIN="${2}"

readonly CA_CER="${CA_CER:-${CERT_DIR}/${STARTSSL_BUNDLE}}"
readonly ISSUER_CER="${ISSUER_CER:-${CERT_DIR}/${STARTSSL_ISSUER}}"

if [ -n "${SUBDOMAIN}" ]
then
    readonly DOMAIN="${SUBDOMAIN}.${SERVER_NAME}"
    readonly OUTPUT_DER="${OUTPUT_DER:-${CERT_DIR}/${SERVER_NAME}/${SUBDOMAIN}/ocsp.der}"
    readonly SERVER_CER="${SERVER_CER:-${CERT_DIR}/${SERVER_NAME}/${SUBDOMAIN}/pem}"
else
    readonly DOMAIN="${SERVER_NAME}"
    readonly OUTPUT_DER="${OUTPUT_DER:-${CERT_DIR}/${SERVER_NAME}/ocsp.der}"
    readonly SERVER_CER="${SERVER_CER:-${CERT_DIR}/${SERVER_NAME}/pem}"
fi

[ ! -f "${CA_CER}" ] && die "Could not find trusted CA certificate '${YELLOW}${CA_CER}${NORMAL}'" ${EC_CA_CER_NOT_FOUND}
[ ! -f "${ISSUER_CER}" ] && die "Could not find issuer certificate bundle '${YELLOW}${ISSUER_CER}${NORMAL}'" ${EC_ISSUER_CER_NOT_FOUND}
[ ! -f "${SERVER_CER}" ] && die "Could not find server certificate '${YELLOW}${SERVER_CER}${NORMAL}'" ${EC_SERVER_CER_NOT_FOUND}

readonly OCSP_URI=$(openssl x509 -in "${SERVER_CER}" -noout -ocsp_uri)
[ $? -ne 0 ] && die '' ${EC_OCSP_URI_FAIL}

HOST="${OCSP_URI#*//}"
readonly HOST="${HOST%%/*}"

if openssl ocsp -issuer "${ISSUER_CER}" -cert "${SERVER_CER}" -url "${OCSP_URI}" -CAfile "${CA_CER}" -VAfile "${CA_CER}" -respout "${OUTPUT_DER}" -header 'Host' "${HOST}" -no_nonce
then
    log_ok "Successfully generated OCSP DER file for ${BLUE}${DOMAIN}${NORMAL}"
    cat << EOT

Add the following to the server block of this domain:

    server {
        ssl_stapling       on;
        ssl_stapling_file  ${OUTPUT_DER#/etc/nginx/*};
    }

EOT
else
    die "OCSP DER file generation failed." ${EC_GEN_FAILED}
fi

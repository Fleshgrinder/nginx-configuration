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
# Usage help text for OCSP file command.
#
# @author Richard Fussenegger <richard@fussenegger.info>
# @copyright 2015 (c) Richard Fussenegger
# @license https://www.gnu.org/licenses/agpl-3.0.html AGPLv3
# ----------------------------------------------------------------------------------------------------------------------

cat << EOT
[OPTION]... SERVER_NAME [SUBDOMAIN]
Generate OCSP DER file for nginx ocsp_stapling_file directive.

    -h, -?     Display this help and exit.
    -c <path>  Path to the trusted CA certificate, default '${YELLOW}./${STARTSSL_BUNDLE}${NORMAL}'.
    -i <path>  Path to the issuer certificate bundle, default '${YELLOW}./${STARTSSL_ISSUER}${NORMAL}'.
    -o <path>  Output file, default '${YELLOW}./certificates/<SERVER_NAME>/ocsp.der${NORMAL}'.
    -s <path>  Path to the server certificate, default '${YELLOW}./certificates/<SERVER_NAME>/pem${NORMAL}'.

The [SUBDOMAIN] argument is optional and defaults to an empty string. It is used
to build the path to the server certificate/key and to pass the correct host to
the OCSP responder. Please refer to the README file for more information on the
directory structure of the certificates.
EOT

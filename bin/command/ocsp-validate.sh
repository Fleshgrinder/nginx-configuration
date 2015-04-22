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
# Validate OCSP stapling.
#
# @author Richard Fussenegger <richard@fussenegger.info>
# @copyright 2015 (c) Richard Fussenegger
# @license https://www.gnu.org/licenses/agpl-3.0.html AGPLv3
# ----------------------------------------------------------------------------------------------------------------------

openssl s_client -connect "${1}:443" -servername "${1}" -tls1 -tlsextdebug -status -CApath startssl.com/certs/ | grep OCSP

cat << EOT

Please note that it might take some time for all workers to fetch the OSCP
stapling file if you just (re)started your server. Simply execute this script
various times (depending on your worker count).

EOT

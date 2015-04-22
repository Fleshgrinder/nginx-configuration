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
# Usage help text for server command.
#
# @author Richard Fussenegger <richard@fussenegger.info>
# @copyright 2015 (c) Richard Fussenegger
# @license https://www.gnu.org/licenses/agpl-3.0.html AGPLv3
# ----------------------------------------------------------------------------------------------------------------------

cat << EOT
[OPTIONS]... DOMAIN [SUBDOMAIN]
Generate new server configuration.

    -h  Display this help and exit.
    -w  Create a www to no-www configuration instead of the default, which is
        no-www to www because of security concerns regarding cookies. Note that
        this option has no effect if a subdomain different to '${BLUE}www${NORMAL}' is passed as
        the second argument.

The domain argument is mandatory, the subdomain is optional (default '${BLUE}www${NORMAL}').
EOT

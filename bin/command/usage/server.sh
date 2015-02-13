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
# Usage help text for server command.
#
# AUTHOR:    Richard Fussenegger <richard@fussenegger.info>
# COPYRIGHT: Copyright (c) 2008-15 Richard Fussenegger
# LICENSE:   http://unlicense.org/ PD
# ------------------------------------------------------------------------------

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

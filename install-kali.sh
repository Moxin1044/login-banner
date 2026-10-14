#!/bin/sh
# Compatibility wrapper for install-kali.sh.
# The unified installer auto-detects the distribution; this name is kept so
# existing docs, muscle memory and scripts keep working.
exec "$(dirname "$0")/install.sh" "$@"

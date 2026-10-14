#!/bin/sh
# @Moxin1044 2026-10-15
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Moxin1044
# Compatibility wrapper for install-arch.sh.
# The unified installer auto-detects the distribution; this name is kept so
# existing docs, muscle memory and scripts keep working.
exec "$(dirname "$0")/install.sh" "$@"

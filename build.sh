#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2026 Christian Kilb <christian@kilb.tech>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Builds the installable widget archives into dist/:
#
#   plasma-smart-tasks-<version>.plasmoid   the file to download and install
#   plasma-smart-tasks-<version>.zip        byte-for-byte the same package
#
# Both are zip archives: KPackage in Plasma 6 can only open zip packages, and the
# .plasmoid extension is what "Add Widgets… > Get New Widgets… > Install Widget From
# Local File…" expects.

set -euo pipefail
cd "$(dirname "$0")"

VERSION=$(python3 -c "import json; print(json.load(open('package/metadata.json'))['KPlugin']['Version'])")
NAME="plasma-smart-tasks-$VERSION"

rm -rf dist
mkdir -p dist

# metadata.json and contents/ have to sit at the root of the archive.
( cd package && zip --quiet --recurse-paths "../dist/$NAME.zip" . )
cp "dist/$NAME.zip" "dist/$NAME.plasmoid"

echo "Built:"
ls -l dist
echo
echo "Install with:"
echo "  kpackagetool6 --type Plasma/Applet --install dist/$NAME.plasmoid"
echo "or use System Settings > Panel > Add Widgets > Get New Widgets > Install Widget From Local File"

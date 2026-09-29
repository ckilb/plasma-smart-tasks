/*
    SPDX-FileCopyrightText: 2026 Christian Kilb <christian@kilb.tech>

    SPDX-License-Identifier: GPL-2.0-or-later

    QML-only stand-in for the SmartLauncher::Item type of Plasma's built-in Task
    Manager widget (plasma-desktop/applets/taskmanager/smartlauncheritem.cpp).

    The real item is driven by two things that have no public QML API:

      * the kactivitymanagerd "recent documents" scoring plugin, which is what puts a
        count badge on a pinned launcher icon, and
      * KJob progress reporting, which draws a progress bar on a launcher icon.

    This stub keeps the same API so the rest of the QML works unchanged, and simply
    reports "nothing to show": no badge, no progress ring, and attention is then driven
    purely by the window's own "demands attention" state, which still works.
*/

import QtQuick

QtObject {
    id: item

    property url launcherUrl

    readonly property int count: 0
    readonly property bool countVisible: false
    readonly property int progress: 0
    readonly property bool progressVisible: false
    readonly property bool urgent: false
}

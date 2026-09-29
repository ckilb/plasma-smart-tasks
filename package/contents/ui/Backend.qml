/*
    SPDX-FileCopyrightText: 2026 Christian Kilb <christian@kilb.tech>

    SPDX-License-Identifier: GPL-2.0-or-later

    QML-only stand-in for the C++ Backend class that ships with Plasma's built-in
    Task Manager widget (plasma-desktop/applets/taskmanager/backend.cpp).

    A widget installed from a local file cannot ship compiled C++ code, so the parts
    of the backend that are implementable in QML are implemented here:

      * globalRect()          - the only function that matters for window management
                                (icon geometry for minimise animations, thumbnails)
      * isApplication()       - used when deciding whether a drop creates launchers

    The launcher "jump list"/Places/recent-document menus are driven by KService and
    KFilePlacesModel and have no QML equivalent; those functions return empty lists so
    the widget degrades gracefully instead of failing to load.
*/

import QtQuick

QtObject {
    id: backend

    // Mirrors Backend::MiddleClickAction from the C++ backend, and the choice order
    // of the "middleClickAction" entry in contents/config/main.xml.
    enum MiddleClickAction {
        None,
        Close,
        NewInstance,
        ToggleMinimized,
        ToggleGrouping,
        BringToCurrentDesktop
    }

    // Emitted by the C++ backend when a launch action asks for a new launcher.
    signal addLauncher(url launcherUrl)

    // Emitted by the C++ backend from the "All Places" entry of the Places submenu.
    signal showAllPlaces()

    function globalRect(item: Item): rect {
        if (!item || item.width <= 0 || item.height <= 0) {
            return Qt.rect(0, 0, 0, 0);
        }

        const topLeft = item.mapToGlobal(0, 0);
        return Qt.rect(Math.round(topLeft.x), Math.round(topLeft.y),
                       Math.round(item.width), Math.round(item.height));
    }

    function isApplication(url: url): bool {
        if (!url || !url.toString()) {
            return false;
        }

        const path = url.toString();
        return path.startsWith("file://") && path.endsWith(".desktop");
    }

    function applicationCategories(launcherUrl: url): list<string> {
        return [];
    }

    function tryDecodeApplicationsUrl(launcherUrl: url): url {
        // The applications:/ KIO slave resolves menu IDs, so the URL can be passed
        // through as-is for drag and drop.
        return launcherUrl;
    }

    function parentPid(pid: real): int {
        return -1;
    }

    function placesActions(launcherUrl: url, showAllPlaces: bool, parent: var): var {
        return [];
    }

    function recentDocumentActions(launcherUrl: url, parent: var): var {
        return [];
    }

    function jumpListActions(launcherUrl: url, parent: var): var {
        return [];
    }

    function setActionGroup(action: var): void {
    }
}

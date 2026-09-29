# Smart Tasks — icon-only Plasma task manager with titles where they matter

A fork of Plasma's built-in Icons-Only Task Manager that keeps a panel compact and still
lets you tell windows apart: **every window gets its own button**, and a button only shows
text when its application has more than one window.

| State | How it looks |
| --- | --- |
| App not running (pinned launcher) | icon |
| App with one window | icon |
| App with two or more windows | one button per window, each icon **+ its window title** |

So a single-window app costs exactly one icon, while three browser or editor windows become
three labelled buttons you can pick from with a single click — no hovering, no grouping, no
text on tasks that don't need it.

![One window: icon only. Several windows of the same application: one labelled button per window.](docs/behaviour.png)

## Why this exists

Plasma ships two task widgets, and both are all-or-nothing:

* **Task Manager** — every window gets icon *and* text, always.
* **Icons-Only Task Manager** — never any text, so windows of the same app are
  indistinguishable (they are grouped into one button, or shown as identical icons).

They are actually the same QML code base; the only difference is a hardcoded flag:

```qml
readonly property bool iconsOnly: Plasmoid.pluginName === "org.kde.plasma.icontasks"
```

There is no configuration option for "text only when needed", and the config schemas in
Plasma 6.7 (and current master) contain no text/label toggle at all. Upstream wishlist
items for this area have been open for years
([bug 391572](https://bugs.kde.org/show_bug.cgi?id=391572),
[bug 448912](https://bugs.kde.org/show_bug.cgi?id=448912)).

Smart Tasks fills that gap: it keeps the icon-only layout and adds the window title exactly
where the icon alone carries no information — on applications that have several windows.

## Requirements

* Plasma 6.0 or newer (developed and tested on Plasma 6.7.5)
* X11 or Wayland — nothing to compile, the widget is pure QML

## Install

### From this repository (recommended)

Download the `.plasmoid` file from the [latest release](../../releases), then either

* right-click your panel → **Add Widgets…** → **Get New Widgets…** →
  **Install Widget From Local File…** and pick the `.plasmoid` file, or
* install it from a terminal:

  ```sh
  kpackagetool6 --type Plasma/Applet --install plasma-smart-tasks-1.0.0.plasmoid
  ```

Then remove the old task widget from your panel and add **Smart Tasks** in its place.

> The `.plasmoid` is a zip archive — that is what KPackage in Plasma 6 can open (gzipped
> tars are no longer accepted), and `./build.sh` also writes the identical file as `.zip`.

### From source

```sh
git clone https://github.com/ckilb/plasma-smart-tasks.git
cd plasma-smart-tasks
./build.sh
kpackagetool6 --type Plasma/Applet --install dist/plasma-smart-tasks-1.0.0.plasmoid
```

### Uninstall

```sh
kpackagetool6 --type Plasma/Applet --remove io.github.ckilb.smarttasks
```

## Settings

The widget has the same pages as the built-in task manager, minus the options that only
make sense with permanent text:

* **Appearance** → *Show window titles for apps with more than one window* — the switch for
  the behaviour described above. Turn it off and you get exactly the stock icon-only widget.
* **Appearance** → *Spacing between icons*, *Fill free space on panel*, multi-row view.
* **Behavior** → *Group:* is fixed to "Do not group" while smart labels are on, because
  grouping would merge the very windows the labels are meant to distinguish.

Pinned launchers, icon spacing and the like are per-widget settings, so a freshly added
widget starts with its own defaults.

## How it works

Three small changes on top of the stock widget:

```qml
// main.qml — how many windows does each application have right now?
readonly property var windowCounts: { /* counts rows per AppId */ }

// Task.qml — a window's title is only shown when its app has several windows
readonly property bool labelWanted: tasksRoot.smartLabels && isWindow && !model.IsStartup
    && tasksRoot.windowCountFor(appId, model.LauncherUrlWithoutIcon) > 1

// Task.qml — labelled tasks may grow by the width of a title, others stay square icons
Layout.maximumWidth: ... LayoutMetrics.preferredMaxWidth(labelWanted)
```

A single task delegate cannot see its siblings, so the per-application window count is
computed once in `main.qml` and re-evaluated whenever tasks come and go. The label itself
reuses the stock label element, so it shows the window title, elides or wraps like the
regular Task Manager, and is dropped again when the panel runs out of room.

## Differences from the built-in widget

The widget is installed as a user package, which means it cannot ship compiled C++ code.
Two C++ classes of the built-in applet are therefore replaced by QML equivalents:

| Built-in | Replacement | Consequence |
| --- | --- | --- |
| `Backend` (jump lists, places, recent documents, icon geometry, drag & drop) | `contents/ui/Backend.qml` | icon geometry for minimise animations/window previews and launcher drag & drop still work; the *jump list*, *Places* and *Recent Files* submenus of the right-click menu are empty |
| `SmartLauncherItem` (activity-manager badge counts, KJob progress) | `contents/ui/SmartLauncherItem.qml` | no count badge and no progress ring on launcher icons; attention is still driven by the window's own state |

Everything else — pin/unpin, window controls, moving windows between desktops and
activities, closing, tooltips, previews, audio indicators, middle-click actions — is
unchanged.

## Development

```
package/
├── metadata.json
└── contents/
    ├── config/          main.xml (settings schema), config.qml (settings pages)
    └── ui/              QML, with code/LayoutMetrics.js and code/TaskTools.js
```

The QML is derived from `plasma-desktop/applets/taskmanager` (Plasma 6.7.5, GPL-2.0-or-later).
Files that differ from upstream:

| File | Change |
| --- | --- |
| `ui/Task.qml` | `labelWanted`, label visibility, `preferredMaxWidth(labelWanted)` |
| `ui/main.qml` | `iconsOnly: true`, `smartLabels`, `windowCounts`/`windowCountFor()`, grouping disabled while smart labels are on |
| `ui/code/LayoutMetrics.js` | `preferredMaxWidth(needsLabel)`, `smartLabelSpace()` |
| `ui/ConfigAppearance.qml`, `ui/ConfigBehavior.qml` | new checkbox, text-only options hidden |
| `ui/Backend.qml`, `ui/SmartLauncherItem.qml` | QML-only replacements for the C++ classes above |
| `ui/TaskBadgeOverlay.qml`, `ui/ContextMenu.qml` | minor adaptations (no private C++ module) |

Because the upstream QML uses Plasma-internal modules, the private
`plasma.applet.org.kde.plasma.taskmanager` import was replaced by direct imports of the
widget's own JavaScript files, as Plasma 5 did before those files were compiled in.

Upstreaming the behaviour would be a matter of adding the `smartLabels` config entry and the
label condition above — the feature is deliberately a small, self-contained diff.

## License

GPL-2.0-or-later, like the Plasma code it is derived from. See [LICENSE](LICENSE).

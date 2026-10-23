import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    readonly property color fg: "#d4be98"
    readonly property color dim: "#7c6f64"
    readonly property color accent: "#7daea3"
    readonly property int cellWidth: 26

    // Desktop ids that hold at least one window.
    property var occupied: ({})

    TaskManager.VirtualDesktopInfo { id: desktops }

    TaskManager.ActivityInfo { id: activityInfo }

    TaskManager.TasksModel {
        id: tasks
        groupMode: TaskManager.TasksModel.GroupDisabled
        filterByVirtualDesktop: false
        filterByScreen: false
        filterByActivity: true
        activity: activityInfo.currentActivity
        onCountChanged: recount.restart()
        onDataChanged: recount.restart()
    }

    Timer {
        id: recount
        interval: 50
        onTriggered: {
            const o = {};
            for (let i = 0; i < probe.count; i++) {
                const it = probe.itemAt(i);
                if (!it) continue;
                if (it.allDesktops) {
                    for (const d of desktops.desktopIds) o[d] = true;
                } else {
                    for (const d of it.desktops) o[d] = true;
                }
            }
            root.occupied = o;
        }
    }

    // Invisible per-window probes, used only to read each window's desktops.
    Item {
        visible: false
        Repeater {
            id: probe
            model: tasks
            delegate: Item {
                readonly property var desktops: model.VirtualDesktops || []
                readonly property bool allDesktops: model.IsOnAllVirtualDesktops === true
                onDesktopsChanged: recount.restart()
                onAllDesktopsChanged: recount.restart()
            }
        }
    }

    fullRepresentation: RowLayout {
        spacing: 0
        Layout.minimumWidth: desktops.numberOfDesktops * root.cellWidth
        Layout.preferredWidth: Layout.minimumWidth

        Repeater {
            model: desktops.desktopIds
            delegate: MouseArea {
                id: cell
                required property var modelData
                required property int index
                readonly property bool current: modelData === desktops.currentDesktop
                readonly property bool busy: root.occupied[modelData] === true
                Layout.fillHeight: true
                Layout.preferredWidth: root.cellWidth
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: desktops.requestActivate(modelData)
                onWheel: wheel => {
                    const ids = desktops.desktopIds;
                    const i = ids.indexOf(desktops.currentDesktop);
                    const step = wheel.angleDelta.y < 0 ? 1 : -1;
                    const next = Math.max(0, Math.min(ids.length - 1, i + step));
                    if (next !== i) desktops.requestActivate(ids[next]);
                }

                Text {
                    anchors.centerIn: parent
                    text: cell.index + 1
                    font.family: "JetBrainsMono Nerd Font"
                    font.pointSize: 10
                    font.weight: cell.current ? Font.Bold : Font.Medium
                    color: cell.current ? root.accent : (cell.busy || cell.containsMouse ? root.fg : root.dim)
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: 3
                    color: root.accent
                    opacity: cell.current ? 1 : (cell.busy ? 0.45 : 0)
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }
            }
        }
    }
}

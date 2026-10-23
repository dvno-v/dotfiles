import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    TaskManager.VirtualDesktopInfo { id: desktops }
    TaskManager.ActivityInfo { id: activityInfo }

    TaskManager.TasksModel {
        id: tasks
        groupMode: TaskManager.TasksModel.GroupDisabled
        filterByVirtualDesktop: true
        filterByActivity: true
        virtualDesktop: desktops.currentDesktop
        activity: activityInfo.currentActivity
        onActiveTaskChanged: root.refresh()
        onDataChanged: root.refresh()
        onCountChanged: root.refresh()
    }

    property string appName: "Desktop"

    function refresh() {
        const idx = tasks.activeTask;
        const name = idx && idx.valid ? tasks.data(idx, TaskManager.AbstractTasksModel.AppName) : "";
        appName = name && name.length ? name : "Desktop";
    }

    Component.onCompleted: refresh()

    fullRepresentation: Item {
        Layout.minimumWidth: label.implicitWidth + 16
        Layout.preferredWidth: Layout.minimumWidth
        Layout.maximumWidth: 260

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            x: 8
            width: Math.min(implicitWidth, 244)
            elide: Text.ElideRight
            text: root.appName
            font.family: "JetBrainsMono Nerd Font"
            font.pointSize: 10
            font.weight: Font.Bold
            color: "#d4be98"
        }
    }
}

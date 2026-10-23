import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation
    toolTipMainText: "Night Cat"
    toolTipSubText: "Click to pause or resume"
    fullRepresentation: Item {
        implicitWidth: 44
        implicitHeight: 24
        Layout.minimumWidth: 44
        Layout.preferredWidth: 44
        Layout.maximumWidth: 44
        Layout.minimumHeight: 20
        Cat {
            anchors.fill: parent
        }
    }
}

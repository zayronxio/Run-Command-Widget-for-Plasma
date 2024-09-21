/*
    SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2023 Himprakash Deka <himprakashd@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.5
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.iconthemes as KIconThemes
import org.kde.config as KConfig
import org.kde.ksvg 1.0 as KSvg
import org.kde.kcmutils as KCM

KCM.SimpleKCM {

    property string cfg_menuLabel: menuLabel.text
    property string cfg_command: command.text
    property string cfg_icon: Plasmoid.configuration.icon
    property string def_icon: "new-command-alarm"
    property alias cfg_textBold: checkedBoldText.checked

    Kirigami.FormLayout {
        Button {
            id: iconButton

            Kirigami.FormData.label: i18n("Icon:")

            implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
            implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2
            hoverEnabled: true

            Accessible.name: i18nc("@action:button", "Change Overview Button's icon")
            Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", cfg_icon)
            Accessible.role: Accessible.ButtonMenu

            ToolTip.delay: Kirigami.Units.toolTipDelay
            ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", cfg_icon)
            ToolTip.visible: iconButton.hovered && cfg_icon.length > 0

            KIconThemes.IconDialog {
                id: iconDialog
                onIconNameChanged: cfg_icon = iconName || def_icon
            }

            onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

            KSvg.FrameSvgItem {
                id: previewFrame
                anchors.centerIn: parent
                imagePath: Plasmoid.formFactor === PlasmaCore.Types.Vertical || Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                        ? "widgets/panel-background" : "widgets/background"
                width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: cfg_icon
                }
            }

            Menu {
                id: iconMenu

                // Appear below the button
                y: +parent.height

                MenuItem {
                    text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                    icon.name: "document-open-folder"
                    Accessible.description: i18nc("@info:whatsthis", "Choose an icon for Application Launcher")
                    onClicked: iconDialog.open()
                }
                MenuItem {
                    text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
                    icon.name: "edit-clear"
                    enabled: cfg_icon !== def_icon
                    onClicked: cfg_icon = def_icon
                }
                MenuItem {
                    text: i18nc("@action:inmenu", "Remove icon")
                    icon.name: "delete"
                    enabled: cfg_icon !== "" && menuLabel.text && Plasmoid.formFactor !== PlasmaCore.Types.Vertical
                    onClicked: cfg_icon = ""
                }
            }
        }

        Kirigami.ActionTextField {
            id: command
            Kirigami.FormData.label: i18nc("@label:textbox", "Command:")
            text: Plasmoid.configuration.command
            placeholderText: i18nc("@info:placeholder", "Type the command to execute")
            onTextEdited: {
                cfg_command = command.text
            }
            rightActions: [
                Action {
                    icon.name: "edit-clear"
                    enabled: command.text !== ""
                    text: i18nc("@action:button", "Reset menu label")
                    onTriggered: {
                        command.clear()
                        cfg_command = ''
                    }
                }
            ]
        }

        Kirigami.ActionTextField {
            id: menuLabel
            enabled: Plasmoid.formFactor !== PlasmaCore.Types.Vertical
            Kirigami.FormData.label: i18nc("@label:textbox", "Text label:")
            text: Plasmoid.configuration.menuLabel
            placeholderText: i18nc("@info:placeholder", "Type here to add a text label")
            onTextEdited: {
                cfg_menuLabel = menuLabel.text

                // This is to make sure that we always have a icon if there is no text.
                // If the user remove the icon and remove the text, without this, we'll have no icon and no text.
                // This is to force the icon to be there.
                if (!menuLabel.text) {
                    cfg_icon = cfg_icon || def_icon
                }
            }
            rightActions: [
                Action {
                    icon.name: "edit-clear"
                    enabled: menuLabel.text !== ""
                    text: i18nc("@action:button", "Reset menu label")
                    onTriggered: {
                        menuLabel.clear()
                        cfg_menuLabel = ''
                        cfg_icon = cfg_icon || def_icon
                    }
                }
            ]
        }

        CheckBox {
            id: checkedBoldText
            text: "Bold Text"
        }

        Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 25
            visible: Plasmoid.formFactor === PlasmaCore.Types.Vertical
            text: i18nc("@info", "A text label cannot be set when the Panel is vertical.")
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
        }
    }
}

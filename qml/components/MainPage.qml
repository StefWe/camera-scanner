import QtQuick 2.6
import Ubuntu.Components 1.3
import QtQml.Models 2.1
import QtGraphicalEffects 1.0

Page {
    property alias imageModel: imageModel

    header: CommonHeader {
        id: mainHeader
    }

    ListModel {
        id: imageModel
        //ListElement {imgout: "calendaris.png"}
        //ListElement {imgout: "/home/phablet/.cache/doc-scanner.dslul/1479221316289.jpg_out.png"}
    }

    DelegateModel {
        id: visualModel
        model: imageModel

        delegate: MouseArea {
            id: delegateRoot
            property int visualIndex: DelegateModel.itemsIndex
            width: gridview.cellWidth
            height: gridview.cellHeight
            drag.smoothed: true
            //drag.target: icon

            Item {
                id: icon
                width: gridview.cellWidth
                height: gridview.cellHeight
                anchors {
                    horizontalCenter: parent.horizontalCenter;
                    verticalCenter: parent.verticalCenter
                }

                Drag.active: delegateRoot.drag.active
                Drag.source: delegateRoot
                Drag.hotSpot.x: 36
                Drag.hotSpot.y: 36

                states: [
                    State {
                        when: icon.Drag.active
                        ParentChange {
                            target: icon
                            parent: mainView
                        }

                        AnchorChanges {
                            target: icon;
                            anchors.horizontalCenter: undefined;
                            anchors.verticalCenter: undefined
                        }
                    }
                ]

                Image {
                    id: mainImg
                    anchors {
                        fill: parent
                        leftMargin: mainView.gridmargin
                        rightMargin: mainView.gridmargin
                        topMargin: 1.5*mainView.gridmargin
                        bottomMargin: 1.5*mainView.gridmargin
                    }
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    source: Qt.resolvedUrl(model.imgout)

                    // Prevent blurry SVGs
                    sourceSize.width: 2*mainView.mingridwidth
                    sourceSize.height: 3*mainView.mingridwidth

                    /* Overlay for when image is pressed */
                    Rectangle {
                        id: overlay
                        anchors.fill: parent
                        color: "#000"
                        border.color: UbuntuColors.orange
                        border.width: 0
                        opacity: delegateRoot.pressed ? 0.3 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: UbuntuAnimation.SlowDuration
                            }
                        }
                    }
                }

                DropShadow {
                    anchors.fill: mainImg
                    horizontalOffset: 5
                    verticalOffset: 5
                    radius: 18
                    samples: 25
                    transparentBorder: true
                    color: "#80000000"
                    source: mainImg
                }
            }

            DropArea {
                anchors { fill: parent; margins: 15 }

                onEntered: {
                    visualModel.items.move(drag.source.visualIndex, delegateRoot.visualIndex)
                    imageModel.move(drag.source.visualIndex, delegateRoot.visualIndex, 1)
                }
            }

            onPressAndHold: {
                overlay.border.width = 10
                mouse.accepted = false
                delegateRoot.drag.target = icon
                deleteIcon.visible = true
            }

            onReleased: {
                if(icon.Drag.target === deleteDragTarget) {
                    imageModel.remove(model.index)
                }

                overlay.border.width = 0
                delegateRoot.drag.target = undefined
                deleteIcon.visible = false
            }
        }
    }

    Item {
        id: topPanel
        anchors {
            left: parent.left
            right: parent.right
            top: mainHeader.bottom
            topMargin: units.gu(2)
        }

        height: units.gu(5)

        DropArea {
            id: deleteDragTarget
            anchors.fill: parent

            Icon {
                id: deleteIcon
                name: "delete"
                visible: false
                color: UbuntuColors.red
                anchors.horizontalCenter: parent.horizontalCenter
                height: parent.height
                }

            states: [
                State {
                    when: deleteDragTarget.containsDrag
                    PropertyChanges {
                        target: deleteIcon
                        color: UbuntuColors.coolGrey
                    }
                }
            ]
        }
    }

    GridView {
        id: gridview

        anchors {
            top: topPanel.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: units.gu(2)
            leftMargin: mainView.gridmargin
            rightMargin: mainView.gridmargin
        }

        height: mainView.height/2
        clip: true
        cellWidth: width / Math.floor(width/mainView.mingridwidth)
        cellHeight: cellWidth*1.4

        displaced: Transition {
            NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
        }

        model: visualModel
    }

    Loader {
        id: emptyStateLoader
        anchors.fill: parent
        active: imageModel.count === 0
        source: Qt.resolvedUrl("EmptyDocument.qml")
    }
}
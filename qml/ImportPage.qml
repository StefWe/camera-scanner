/*
 * Copyright (C) 2016 Stefano Verzegnassi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License 3 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see http://www.gnu.org/licenses/.
 */

import QtQuick 2.6
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3

import ImageProcessing 1.0

Page {
    id: picker
	property var activeTransfer

	property var url
	property var handler
	property var contentType

    signal cancel()
    signal imported(string fileUrl)

    header: PageHeader {
        id: importHeader
        title: i18n.tr("Import Image")
    }

    ContentPeerPicker {

        anchors {
            fill: parent
            topMargin: importHeader.height
        }

        visible: parent.visible
        showTitle: false
        contentType: picker.contentType
        handler: picker.handler

        onPeerSelected: {
            peer.selectionType = ContentTransfer.Multiple
            picker.activeTransfer = peer.request()
            picker.activeTransfer.stateChanged.connect(function() {
                if (picker.activeTransfer.state === ContentTransfer.Charged) {
					console.log("Charged");
					console.log(picker.activeTransfer.items[0].url)

                    for (var i=0; i<picker.activeTransfer.items.length; i++) {
                        var item = picker.activeTransfer.items[i];

                        //Add current image to being processed
                        ImageProcessing.addImage(item.url);
                    }

                    picker.activeTransfer = null
                    pageStack.pop()
                }
            })
        }

        onCancelPressed: {
            pageStack.pop();
        }
    }

    ContentTransferHint {
        id: transferHint
        anchors.fill: parent
        activeTransfer: picker.activeTransfer
    }

    Component {
        id: resultComponent
        ContentItem {}
	}
}

/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12

Item {
    id: logicComponent
    property alias model: filterModel

    property QtObject sourceModel: undefined
    property string filter: ""
    property string property: ""

    Connections {
        onFilterChanged: invalidateFilter()
        onPropertyChanged: invalidateFilter()
        onSourceModelChanged: invalidateFilter()
    }

    Component.onCompleted: invalidateFilter()

    ListModel {
        id: filterModel
    }

    function invalidateFilter() {
        if (sourceModel === undefined)
            return;

        filterModel.clear();

        if (!isFilteringPropertyOk())
            return

        var length = sourceModel.count
        for (var i = 0; i < length; ++i) {
            var item = sourceModel.get(i);
            if (isAcceptedItem(item)) {
                filterModel.append(item)
            }
        }
    }

    function isAcceptedItem(item) {
        if (item[this.property] === undefined)
            return false

        if (item[this.property].match(this.filter) === null) {
            return false
        }

        return true
    }

    function isFilteringPropertyOk() {
        if(this.property === undefined || this.property === "") {
            return false
        }
        return true
    }
}

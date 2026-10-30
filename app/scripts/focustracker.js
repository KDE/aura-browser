// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

// Connect to browser for communciating text field focus state

(function () {
    "use strict";

    const textInputTypes = ["", "text", "search", "email", "password", "url", "tel", "number", "date", "datetime-local", "month", "time", "week"];

    function isEditable(element) {
        if (!element) {
            return false;
        }
        if (element.isContentEditable) {
            return true;
        }
        switch (element.tagName) {
        case "TEXTAREA":
            return !element.readOnly && !element.disabled;
        case "INPUT":
            return textInputTypes.includes((element.getAttribute("type") || "").toLowerCase()) && !element.readOnly && !element.disabled;
        default:
            return element.getAttribute("role") === "textbox";
        }
    }

    function activeElement() {
        let element = document.activeElement;
        while (element && element.shadowRoot && element.shadowRoot.activeElement) {
            element = element.shadowRoot.activeElement;
        }
        return element;
    }

    new QWebChannel(qt.webChannelTransport, function (channel) {
        const page = channel.objects.page;

        function update() {
            const editing = isEditable(activeElement());
            if (page.editing !== editing) {
                page.editing = editing;
            }
        }

        document.addEventListener("focusin", update, true);
        document.addEventListener("focusout", function () {
            setTimeout(update, 0);
        }, true);
        update();
    });
})();

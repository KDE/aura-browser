// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

.pragma library

// Site host (ex. kde.org instead of https://www.kde.org/plasma-bigscreen)
function siteHost(url) {
    return parse(url)?.hostname.replace(/^www\./, "") ?? "";
}

function originHost(url) {
    return parse(url)?.host ?? "";
}

// What to load for text typed in the address box
function urlFromInput(text, searchUrl) {
    const input = text.trim();
    if (/^(https?|file|about|data):/i.test(input)) {
        return input;
    }
    if (looksLikeHost(input)) {
        return "https://" + input;
    }
    return searchUrl + encodeURIComponent(input);
}

// "localhost", then an optional port, then a path or the end
const localhostPattern = /^localhost(:\d+)?(\/|$)/i;
// A name with a dot, a top-level domain of two characters at least, then an optional port, then a path or the end
const domainPattern = /^[^/]+\.[a-z0-9-]{2,}(:\d+)?(\/|$)/i;

// Whether text is a host with an optional port and path, such as "localhost:8080" or "kde.org/plasma-bigscreen"
function looksLikeHost(text) {
    return !/\s/.test(text) && (localhostPattern.test(text) || domainPattern.test(text));
}

function parse(url) {
    const text = url?.toString() ?? "";
    if (text.length === 0) {
        return null;
    }
    try {
        return new URL(text);
    } catch (e) {
        return null;
    }
}

// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "webprofile.h"

#include "adblockinterceptor.h"
#include "browsersettings.h"

#include <QRegularExpression>
#include <QStandardPaths>
#include <QWebEngineCookieStore>

using namespace Qt::StringLiterals;

WebProfile::WebProfile(QObject *parent)
    : QQuickWebEngineProfile(u"Profile"_s, parent)
    , m_interceptor(new AdblockInterceptor(this))
{
    setDownloadPath(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation));

    auto settings = BrowserSettings::self();
    m_interceptor->setEnabled(settings->adblockEnabled());
    connect(settings, &BrowserSettings::AdblockEnabledChanged, this, [this, settings] {
        m_interceptor->setEnabled(settings->adblockEnabled());
    });
    setUrlRequestInterceptor(m_interceptor);
}

void WebProfile::clearSiteData()
{
    cookieStore()->deleteAllCookies();
    clearHttpCache();
    for (const QWebEnginePermission &permission : listAllPermissions()) {
        permission.reset();
    }
}

#include "moc_webprofile.cpp"

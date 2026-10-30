// SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "adblockinterceptor.h"

#include <QDebug>
#include <QFile>
#include <QThread>

using namespace Qt::StringLiterals;

AdblockInterceptor::AdblockInterceptor(QObject *parent)
    : QWebEngineUrlRequestInterceptor(parent)
{
    m_parseThread = QThread::create([this] {
        QFile file(u":/third-party/easylist.txt"_s);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qWarning() << "Could not read ad block filters:" << file.errorString();
            return;
        }
        const QByteArray filters = file.readAll();
        m_client.parse(filters.constData());
        m_ready = true;
    });
    m_parseThread->start(QThread::LowPriority);
}

AdblockInterceptor::~AdblockInterceptor()
{
    m_parseThread->wait();
    delete m_parseThread;
}

void AdblockInterceptor::setEnabled(bool enabled)
{
    m_enabled = enabled;
}

void AdblockInterceptor::interceptRequest(QWebEngineUrlRequestInfo &info)
{
    if (!m_enabled || !m_ready || info.resourceType() == QWebEngineUrlRequestInfo::ResourceTypeMainFrame) {
        return;
    }

    const QByteArray url = info.requestUrl().toEncoded();
    const QByteArray domain = info.firstPartyUrl().host().toUtf8();
    if (m_client.matches(url.constData(), FONoFilterOption, domain.constData())) {
        info.block(true);
    }
}

#include "moc_adblockinterceptor.cpp"

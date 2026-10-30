// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QQuickWebEngineProfile>
#include <qqmlregistration.h>

class AdblockInterceptor;

// Web profile shared by all tabs
class WebProfile : public QQuickWebEngineProfile
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit WebProfile(QObject *parent = nullptr);

    Q_INVOKABLE void clearSiteData();

private:
    AdblockInterceptor *m_interceptor;
};

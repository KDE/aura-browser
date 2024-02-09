/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include <QDebug>
#include <QFile>
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
#include <QtWebEngine/QQuickWebEngineProfile>
#else
#include <QtWebEngineQuick/QQuickWebEngineProfile>
#endif
#include "globalSettings.h"

GlobalSettings::GlobalSettings(QObject *parent) :
    QObject(parent)
{
}

bool GlobalSettings::firstRun() const
{
    return m_settings.value(QStringLiteral("firstRun"), true).toBool();
}

void GlobalSettings::setFirstRun(bool firstRun)
{
    if (GlobalSettings::firstRun() == firstRun) {
        return;
    }

    m_settings.setValue(QStringLiteral("firstRun"), firstRun);
    Q_EMIT firstRunChanged();
}

int GlobalSettings::virtualMouseSpeed() const
{
    return m_settings.value(QStringLiteral("virtualMouseSpeed"), 10).toInt();
}

void GlobalSettings::setVirtualMouseSpeed(int virtualMouseSpeed)
{
    if (GlobalSettings::virtualMouseSpeed() == virtualMouseSpeed) {
        return;
    }

    m_settings.setValue(QStringLiteral("virtualMouseSpeed"), virtualMouseSpeed);
    Q_EMIT virtualMouseSpeedChanged(virtualMouseSpeed);
}

int GlobalSettings::virtualScrollSpeed() const
{
    return m_settings.value(QStringLiteral("virtualScrollSpeed"), 15).toInt();
}

void GlobalSettings::setVirtualScrollSpeed(int virtualScrollSpeed)
{
    if (GlobalSettings::virtualScrollSpeed() == virtualScrollSpeed) {
        return;
    }

    m_settings.setValue(QStringLiteral("virtualScrollSpeed"), virtualScrollSpeed);
    Q_EMIT virtualScrollSpeedChanged(virtualScrollSpeed);
}

double GlobalSettings::virtualMouseSize() const
{
    return m_settings.value(QStringLiteral("virtualMouseSize"), 1).toDouble();
}

void GlobalSettings::setVirtualMouseSize(double virtualMouseSize)
{
    if (GlobalSettings::virtualMouseSize() == virtualMouseSize) {
        return;
    }

    m_settings.setValue(QStringLiteral("virtualMouseSize"), virtualMouseSize);
    Q_EMIT virtualMouseSizeChanged(virtualMouseSize);
}

void GlobalSettings::clearDefaultProfileCache()
{
    auto *profile = QQuickWebEngineProfile::defaultProfile();
    profile->clearHttpCache();
    qDebug() << "in Clear Cache";
}

bool GlobalSettings::soundEffects() const
{
    return m_settings.value(QStringLiteral("soundEffects"), true).toBool();
}

void GlobalSettings::setSoundEffects(bool soundEffects)
{
    if (GlobalSettings::soundEffects() == soundEffects) {
        return;
    }

    m_settings.setValue(QStringLiteral("soundEffects"), soundEffects);
    Q_EMIT soundEffectsChanged();
}

QString GlobalSettings::defaultSearchEngine() const
{
    return QStringLiteral("Google");
}

void GlobalSettings::setDefaultSearchEngine(QString defaultSearchEngine)
{
    if (GlobalSettings::defaultSearchEngine() == defaultSearchEngine) {
        return;
    }
    m_settings.setValue(QStringLiteral("defaultSearchEgnine"), defaultSearchEngine);
    Q_EMIT defaultSearchEngineChanged();
}

bool GlobalSettings::adblockEnabled() const
{
    return m_settings.value(QStringLiteral("adblockEnabled"), true).toBool();
}

void GlobalSettings::setAdblockEnabled(bool adblockEnabled)
{
    if (GlobalSettings::adblockEnabled() == adblockEnabled) {
        return;
    }

    m_settings.setValue(QStringLiteral("adblockEnabled"), adblockEnabled);
    Q_EMIT adBlockEnabledChanged();
}

/*
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#ifndef GLOBALSETTINGS_H
#define GLOBALSETTINGS_H

#include <QSettings>
#include <QCoreApplication>
#include <QDebug>

#define SettingPropertyKey(type, name, setOption, signalName, settingKey, defaultValue) \
    inline type name() const { return m_settings.value(settingKey, defaultValue).value<type>(); } \
    inline void setOption (const type &value) { m_settings.setValue(settingKey, value); emit signalName(); qDebug() << "emitted"; }

class QSettings;
class GlobalSettings : public QObject

{
    Q_OBJECT
    Q_PROPERTY(bool firstRun READ firstRun WRITE setFirstRun NOTIFY firstRunChanged)
    Q_PROPERTY(int virtualMouseSpeed READ virtualMouseSpeed WRITE setVirtualMouseSpeed NOTIFY virtualMouseSpeedChanged)
    Q_PROPERTY(int virtualScrollSpeed READ virtualScrollSpeed WRITE setVirtualScrollSpeed NOTIFY virtualScrollSpeedChanged)
    Q_PROPERTY(double virtualMouseSize READ virtualMouseSize WRITE setVirtualMouseSize NOTIFY virtualMouseSizeChanged)
    Q_PROPERTY(bool soundEffects READ soundEffects WRITE setSoundEffects NOTIFY soundEffectsChanged)
    Q_PROPERTY(QString defaultSearchEngine READ defaultSearchEngine WRITE setDefaultSearchEngine NOTIFY defaultSearchEngineChanged)
    Q_PROPERTY(bool adblockEnabled READ adblockEnabled WRITE setAdblockEnabled NOTIFY adBlockEnabledChanged)

public:
    explicit GlobalSettings(QObject *parent=0);
    
    bool firstRun() const;
    int virtualMouseSpeed() const;
    int virtualScrollSpeed() const;
    double virtualMouseSize() const;
    bool soundEffects() const;
    QString defaultSearchEngine() const;
    bool adblockEnabled() const;

public Q_SLOTS:
    void setFirstRun(bool firstRun);
    void setVirtualMouseSpeed(int virtualMouseSpeed);
    void setVirtualScrollSpeed(int virtualScrollSpeed);
    void setVirtualMouseSize(double virtualMouseSize);
    void setSoundEffects(bool soundEffects);
    void setDefaultSearchEngine(QString defaultSearchEngine);
    void clearDefaultProfileCache();
    void setAdblockEnabled(bool adblockEnabled);

Q_SIGNALS:
    void firstRunChanged();
    void virtualMouseSpeedChanged(int virtualMouseSpeed);
    void virtualScrollSpeedChanged(int virtualScrollSpeed);
    void virtualMouseSizeChanged(int virtualMouseSize);
    void soundEffectsChanged();
    void focusOnVKeyboard();
    void focusOffVKeyboard();
    void defaultSearchEngineChanged();
    void adBlockEnabledChanged();

private:
    QSettings m_settings;
};

#endif // GLOBALSETTINGS_H

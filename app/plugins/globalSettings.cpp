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

#include <QDebug>
#include <QFile>
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
    emit firstRunChanged();
}

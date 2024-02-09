/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "keyfilter.h"
#include <QKeyEvent>
#include <QDebug>

KeyFilter::KeyFilter(QObject *parent) : QObject(parent)
{
}

void KeyFilter::startFilter()
{
    if (m_filtering) {
        return;
    }

    m_filtering = true;
    Q_EMIT filterStarted();
}

void KeyFilter::stopFilter()
{
    if (!m_filtering) {
        return;
    }

    m_filtering = false;
    Q_EMIT filterStopped();
}

bool KeyFilter::isFiltering()
{
    return m_filtering;
}

bool KeyFilter::eventFilter(QObject *obj, QEvent *event)
{
    if (!m_filtering) {
        return false;
    }

    if (event->type() == QEvent::KeyPress) {
        QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
        if (keyEvent->key() == Qt::Key_Left || keyEvent->key() == Qt::Key_Right || keyEvent->key() == Qt::Key_Up || keyEvent->key() == Qt::Key_Down || keyEvent->key() == Qt::Key_Return){
            Q_EMIT keyPress(event);
        }

    } else if (event->type() == QEvent::KeyRelease) {
        QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
        if (keyEvent->key() == Qt::Key_Left || keyEvent->key() == Qt::Key_Right || keyEvent->key() == Qt::Key_Up || keyEvent->key() == Qt::Key_Down || keyEvent->key() == Qt::Key_Return) {
            Q_EMIT keyRelease(event);
        }
    }

    return QObject::eventFilter(obj, event);
}

/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include <QCoreApplication>
#include <QGuiApplication>
#include <QKeyEvent>
#include <QQuickItem>
#include "virtualKeypress.h"

VirtualKeyPress::VirtualKeyPress()
{
}

VirtualKeyPress::~VirtualKeyPress()
{
}

void VirtualKeyPress::emitKey(QString stringkey)
{
    qDebug() << "inEmitKey:" << stringkey;
    QKeySequence seq = QKeySequence(stringkey);
    qDebug() << seq.count();
    uint keyCode = seq[0];
    Qt::Key key = Qt::Key(keyCode);
    QQuickItem* receiver = qobject_cast<QQuickItem*>(QGuiApplication::focusObject());
    if(!receiver) {
        return;
    }
    QKeyEvent pressEvent = QKeyEvent(QEvent::KeyPress, key, Qt::NoModifier, stringkey, false, 1);
    QKeyEvent releaseEvent = QKeyEvent(QEvent::KeyRelease, key, Qt::NoModifier, stringkey, false, 1);
    QGuiApplication::sendEvent(receiver, &pressEvent);
//    QCoreApplication::sendEvent(receiver, &pressEvent);
//    QCoreApplication::sendEvent(receiver, &releaseEvent);
    QGuiApplication::sendEvent(receiver, &releaseEvent);
}

/*
 *  Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
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

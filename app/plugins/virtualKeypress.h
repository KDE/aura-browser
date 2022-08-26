/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef VIRTUALKEYPRESS_H
#define VIRTUALKEYPRESS_H

#include <QObject>

class VirtualKeyPress : public QObject
{
    Q_OBJECT

public:
    VirtualKeyPress();
    ~VirtualKeyPress();

public slots:
    void emitKey(QString stringkey);

};

#endif

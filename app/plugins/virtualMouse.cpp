/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "virtualMouse.h"

FakeCursor::FakeCursor()
    : step(1), _visible(true), device(QTest::createTouchDevice())
{
}

FakeCursor::~FakeCursor()
{
}

void FakeCursor::move(int d){
    QWindow * w = QGuiApplication::allWindows()[0];
    switch (d) {
    case Up: if(_pos.ry() > 1) { _pos.ry() -= step; } break;
    case Down: if(_pos.ry() < w->height() - 5) { _pos.ry() += step; } break;
    case Left: if(_pos.rx() > 1) { _pos.rx() -= step; } break;
    case Right: if(_pos.rx() < w->width() - 20) { _pos.rx() += step; } break;
    }
    emit posChanged();
}

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
    case Left: _pos.rx() -= step; break;
    case Right: _pos.rx() += step; break;
    }
    emit posChanged();
}

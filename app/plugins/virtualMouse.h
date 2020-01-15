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

#include <QTest>
#include <QGuiApplication>
#include <QObject>
#include <QCursor>

class FakeCursor : public QObject {
  Q_OBJECT
  Q_PROPERTY(QPoint pos READ pos WRITE setPos NOTIFY posChanged)
  Q_PROPERTY(bool visible READ visible NOTIFY visibleChanged)
  enum Direction { Up = 0, Down, Left, Right };
  QPoint _pos;
  qreal step;
  bool _visible;

signals:
  void posChanged();
  void visibleChanged();

public:
  FakeCursor();
  virtual ~FakeCursor();
  void setPos(QPoint p) {
          if (p != _pos) {
              _pos = p;
              emit posChanged();
            }
        }
  bool visible() const { return _visible; }
  QPoint pos() const { return _pos; }


public slots:
      void move(int d);
      void setStep(qreal s) { if (s) step = s; }
      void toggleVisible() { _visible = !_visible; emit visibleChanged(); }
      void click() {
          QWindow * w = QGuiApplication::allWindows()[0];
          QTest::mouseClick(QGuiApplication::allWindows()[0], Qt::LeftButton, Qt::NoModifier, _pos);
      }

private:
      QTouchDevice *device;
      //QCursor cursor;
};

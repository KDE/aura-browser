/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include <QTest>
#include <QGuiApplication>
#include <QObject>
#include <QEvent>
#include "keyfilter.h"

class FakeCursor : public QObject {
  Q_OBJECT
  Q_PROPERTY(QPoint pos READ pos WRITE setPos NOTIFY posChanged)
  Q_PROPERTY(bool visible READ visible NOTIFY visibleChanged)
  enum Direction { Up = 0, Down, Left, Right };
  QPoint _pos;
  qreal step;
  bool _visible;

Q_SIGNALS:
  void posChanged();
  void visibleChanged();

public:
  FakeCursor();
  virtual ~FakeCursor();
  void setPos(QPoint p) {
          if (p != _pos) {
              _pos = p;
              Q_EMIT posChanged();
            }
        }
  bool visible() const { return _visible; }
  QPoint pos() const { return _pos; }


public Q_SLOTS:
      void move(int d);
      void setStep(qreal s) { if (s) step = s; }
      void toggleVisible() { _visible = !_visible; Q_EMIT visibleChanged(); }
      void click() {
          QWindow * w = QGuiApplication::allWindows()[0];
          QTest::touchEvent(w, device).press(0, _pos);
          QTest::touchEvent(w, device).release(0, _pos);
      }
      void closeEvent();
      void moveEvent(QEvent *event);

private:
      QPointingDevice *device;
};

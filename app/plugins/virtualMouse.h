/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include <QTest>
#include <QGuiApplication>
#include <QObject>
#include <QCursor>
#if QT_VERSION_MAJOR >= 6
#include <QInputDevice>
#endif

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
#if QT_VERSION_MAJOR < 6
      QTouchDevice *device;
#else
      QInputDevice *device;
#endif
      //QCursor cursor;
};

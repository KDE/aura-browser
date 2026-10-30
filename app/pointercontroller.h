// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QElapsedTimer>
#include <QObject>
#include <QPointF>
#include <QPointer>
#include <QQuickItem>
#include <QTimer>
#include <qqmlregistration.h>

class PointerController : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QQuickItem *target READ target WRITE setTarget NOTIFY targetChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(int speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(QPointF position READ position WRITE setPosition NOTIFY positionChanged)
    Q_PROPERTY(bool pressed READ pressed NOTIFY pressedChanged)
    Q_PROPERTY(bool moving READ moving NOTIFY movingChanged)

public:
    explicit PointerController(QObject *parent = nullptr);
    ~PointerController() override;

    QQuickItem *target() const;
    void setTarget(QQuickItem *target);

    bool enabled() const;
    void setEnabled(bool enabled);

    int speed() const;
    void setSpeed(int speed);

    QPointF position() const;
    void setPosition(const QPointF &position);

    bool pressed() const;
    bool moving() const;

    // Move pointer to centre
    Q_INVOKABLE void center();

Q_SIGNALS:
    void targetChanged();
    void enabledChanged();
    void speedChanged();
    void positionChanged();
    void pressedChanged();
    void movingChanged();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
    void updateWindow();
    bool handlesKeys() const;
    void step();
    void stop();
    void sendMouseEvent(QEvent::Type type, Qt::MouseButton button);
    void sendWheelEvent(const QPointF &delta);

    QPointer<QQuickItem> m_target;
    QPointer<QQuickWindow> m_window;
    bool m_enabled = false;
    int m_speed = 5;
    QPointF m_position;
    bool m_pressed = false;

    Qt::Edges m_heldDirections;
    QPointF m_scrollRemainder;

    QTimer m_stepTimer;
    QElapsedTimer m_heldTimer;
    QElapsedTimer m_frameTimer;
};

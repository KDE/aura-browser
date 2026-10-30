// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "pointercontroller.h"

#include <QGuiApplication>
#include <QKeyEvent>
#include <QPointingDevice>
#include <QQuickWindow>

#include <cmath>

constexpr qreal BASE_SPEED = 300;
constexpr qreal SPEED_STEP = 70;

constexpr qreal MAXIMUM_ACCELERATION = 3.5;
constexpr qreal ACCELERATION_TIME = 1.2;

static Qt::Edge directionForKey(int key)
{
    switch (key) {
    case Qt::Key_Left:
        return Qt::LeftEdge;
    case Qt::Key_Right:
        return Qt::RightEdge;
    case Qt::Key_Up:
        return Qt::TopEdge;
    case Qt::Key_Down:
        return Qt::BottomEdge;
    default:
        return Qt::Edge(0);
    }
}

PointerController::PointerController(QObject *parent)
    : QObject(parent)
{
    m_stepTimer.setInterval(16);
    m_stepTimer.setTimerType(Qt::PreciseTimer);
    connect(&m_stepTimer, &QTimer::timeout, this, &PointerController::step);
}

PointerController::~PointerController()
{
    if (m_window) {
        m_window->removeEventFilter(this);
    }
}

QQuickItem *PointerController::target() const
{
    return m_target;
}

void PointerController::setTarget(QQuickItem *target)
{
    if (m_target == target) {
        return;
    }

    if (m_target) {
        disconnect(m_target, nullptr, this, nullptr);
    }
    m_target = target;
    if (m_target) {
        connect(m_target, &QQuickItem::windowChanged, this, &PointerController::updateWindow);
    }
    updateWindow();
    center();
    Q_EMIT targetChanged();
}

bool PointerController::enabled() const
{
    return m_enabled;
}

void PointerController::setEnabled(bool enabled)
{
    if (m_enabled == enabled) {
        return;
    }
    m_enabled = enabled;
    if (!m_enabled) {
        stop();
    }
    Q_EMIT enabledChanged();
}

int PointerController::speed() const
{
    return m_speed;
}

void PointerController::setSpeed(int speed)
{
    if (m_speed == speed) {
        return;
    }
    m_speed = speed;
    Q_EMIT speedChanged();
}

QPointF PointerController::position() const
{
    return m_position;
}

void PointerController::setPosition(const QPointF &position)
{
    if (m_position == position) {
        return;
    }
    m_position = position;
    Q_EMIT positionChanged();
}

bool PointerController::pressed() const
{
    return m_pressed;
}

bool PointerController::moving() const
{
    return m_stepTimer.isActive();
}

void PointerController::center()
{
    if (m_target) {
        setPosition(QPointF(m_target->width() / 2, m_target->height() / 2));
    }
}

void PointerController::updateWindow()
{
    QQuickWindow *window = m_target ? m_target->window() : nullptr;
    if (m_window == window) {
        return;
    }
    if (m_window) {
        m_window->removeEventFilter(this);
    }
    m_window = window;
    if (m_window) {
        m_window->installEventFilter(this);
    }
}

bool PointerController::handlesKeys() const
{
    return m_enabled && m_target && m_target->isVisible() && m_target->hasActiveFocus();
}

bool PointerController::eventFilter(QObject *watched, QEvent *event)
{
    if (watched != m_window) {
        return false;
    }

    switch (event->type()) {
    case QEvent::KeyPress: {
        auto keyEvent = static_cast<QKeyEvent *>(event);
        const int key = keyEvent->key();

        if (const Qt::Edge direction = directionForKey(key)) {
            if (!handlesKeys()) {
                return false;
            }
            // Held keys are tracked from the first press to the release
            if (!keyEvent->isAutoRepeat() && !m_heldDirections.testFlag(direction)) {
                m_heldDirections |= direction;
                if (!m_stepTimer.isActive()) {
                    m_heldTimer.start();
                    m_frameTimer.start();
                    m_stepTimer.start();
                    step();
                    Q_EMIT movingChanged();
                }
            }
            return true;
        }

        if (key == Qt::Key_Return || key == Qt::Key_Enter || key == Qt::Key_Select) {
            if (!handlesKeys()) {
                return false;
            }
            if (!keyEvent->isAutoRepeat() && !m_pressed) {
                m_pressed = true;
                sendMouseEvent(QEvent::MouseButtonPress, Qt::LeftButton);
                Q_EMIT pressedChanged();
            }
            return true;
        }
        return false;
    }
    case QEvent::KeyRelease: {
        auto keyEvent = static_cast<QKeyEvent *>(event);
        const int key = keyEvent->key();

        if (const Qt::Edge direction = directionForKey(key)) {
            if (!m_heldDirections.testFlag(direction)) {
                return false;
            }
            if (!keyEvent->isAutoRepeat()) {
                m_heldDirections &= ~Qt::Edges(direction);
                if (!m_heldDirections) {
                    stop();
                }
            }
            return true;
        }

        if (key == Qt::Key_Return || key == Qt::Key_Enter || key == Qt::Key_Select) {
            if (!m_pressed) {
                return false;
            }
            if (!keyEvent->isAutoRepeat()) {
                m_pressed = false;
                sendMouseEvent(QEvent::MouseButtonRelease, Qt::LeftButton);
                Q_EMIT pressedChanged();
            }
            return true;
        }
        return false;
    }
    case QEvent::FocusOut:
        stop();
        return false;
    default:
        return false;
    }
}

void PointerController::step()
{
    if (!m_target || !m_heldDirections || !handlesKeys()) {
        stop();
        return;
    }

    const qreal frameTime = std::min<qreal>(m_frameTimer.restart() / 1000.0, 0.05);
    const qreal heldTime = m_heldTimer.elapsed() / 1000.0;
    const qreal acceleration = 1 + (MAXIMUM_ACCELERATION - 1) * std::min<qreal>(heldTime / ACCELERATION_TIME, 1.0);
    // The first press nudges the pointer a little, for precise positioning
    const qreal distance = frameTime > 0 ? (BASE_SPEED + SPEED_STEP * (m_speed - 1)) * acceleration * frameTime : 4;

    QPointF direction;
    direction.rx() = (m_heldDirections.testFlag(Qt::RightEdge) ? 1 : 0) - (m_heldDirections.testFlag(Qt::LeftEdge) ? 1 : 0);
    direction.ry() = (m_heldDirections.testFlag(Qt::BottomEdge) ? 1 : 0) - (m_heldDirections.testFlag(Qt::TopEdge) ? 1 : 0);
    if (direction.isNull()) {
        return;
    }
    const QPointF delta = direction / std::hypot(direction.x(), direction.y()) * distance;

    const QPointF wanted = m_position + delta;
    const QPointF bounded(std::clamp<qreal>(wanted.x(), 0, m_target->width() - 1), std::clamp<qreal>(wanted.y(), 0, m_target->height() - 1));

    // Pushing past an edge scrolls whatever is under the pointer
    const QPointF overflow = wanted - bounded;
    if (!overflow.isNull()) {
        sendWheelEvent(overflow);
    }

    if (bounded != m_position) {
        setPosition(bounded);
        sendMouseEvent(QEvent::MouseMove, Qt::NoButton);
    }
}

void PointerController::stop()
{
    m_heldDirections = {};
    m_scrollRemainder = {};
    if (m_stepTimer.isActive()) {
        m_stepTimer.stop();
        Q_EMIT movingChanged();
    }
    if (m_pressed) {
        m_pressed = false;
        sendMouseEvent(QEvent::MouseButtonRelease, Qt::LeftButton);
        Q_EMIT pressedChanged();
    }
}

void PointerController::sendMouseEvent(QEvent::Type type, Qt::MouseButton button)
{
    if (!m_target || !m_window) {
        return;
    }

    const QPointF scenePosition = m_target->mapToScene(m_position);
    const QPointF globalPosition = m_window->mapToGlobal(scenePosition);
    const Qt::MouseButtons buttons = (m_pressed && type != QEvent::MouseButtonRelease) ? Qt::LeftButton : Qt::NoButton;

    QMouseEvent event(type, scenePosition, scenePosition, globalPosition, button, buttons, Qt::NoModifier, QPointingDevice::primaryPointingDevice());
    QCoreApplication::sendEvent(m_window, &event);
}

void PointerController::sendWheelEvent(const QPointF &delta)
{
    if (!m_target || !m_window) {
        return;
    }

    // Wheel events carry whole pixels so keep the fractions for the next step
    const QPointF total = delta + m_scrollRemainder;
    const QPoint pixels = total.toPoint();
    m_scrollRemainder = total - pixels;
    if (pixels.isNull()) {
        return;
    }

    const QPointF scenePosition = m_target->mapToScene(m_position);
    const QPointF globalPosition = m_window->mapToGlobal(scenePosition);

    // Scrolling toward the bottom is a negative wheel delta
    QWheelEvent event(scenePosition, globalPosition, -pixels, -pixels, Qt::NoButton, Qt::NoModifier, Qt::NoScrollPhase, false);
    QCoreApplication::sendEvent(m_window, &event);
}

#include "moc_pointercontroller.cpp"

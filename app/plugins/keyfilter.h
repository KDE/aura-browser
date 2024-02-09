/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef KEYFILTER_H
#define KEYFILTER_H

#include <QObject>
#include <QEvent>
#include <QKeyEvent>

class KeyFilter : public QObject
{
    Q_OBJECT

public:
    explicit KeyFilter(QObject *parent = nullptr);

public Q_SLOTS:
    void startFilter();
    void stopFilter();
    bool isFiltering();

protected:
    bool eventFilter(QObject *obj, QEvent *event) override;

Q_SIGNALS:
    void keyPress(QEvent *event);
    void keyRelease(QEvent *event);
    void filterStarted();
    void filterStopped();

private:
    bool m_filtering = false;
};

#endif // KEYFILTER_H
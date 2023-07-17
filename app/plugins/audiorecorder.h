/*
    SPDX-FileCopyrightText: 2016 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef AUDIORECORDER_H
#define AUDIORECORDER_H

#include <QObject>
#include <QFile>

#if QT_VERSION_MAJOR < 6
#include <QAudioInput>
#else
#include <QAudioSource>
#endif

class AudioRecorder : public QObject
{
    Q_OBJECT

public:
    explicit AudioRecorder(QObject *parent = nullptr);

public Q_SLOTS:
    void start();
    void stop();

private:
    QFile destinationFile;
#if QT_VERSION_MAJOR < 6
    QAudioInput *m_audioInput;
#else
    QAudioSource *m_audioInput;
#endif
    QIODevice *device;
};

#endif // AUDIORECORDER_H

/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "audiorecorder.h"
#include <QDebug>
#include <QAudioFormat>

AudioRecorder::AudioRecorder(QObject *parent):
    QObject(parent)
{
}

void AudioRecorder::start()
{
    destinationFile.setFileName(QStringLiteral("/tmp/aura_in.raw"));
    destinationFile.open( QIODevice::WriteOnly | QIODevice::Truncate );
    QAudioFormat format;
    format.setSampleRate(16000);
    format.setChannelCount(1);
#if QT_VERSION_MAJOR < 6
    format.setCodec(QStringLiteral("audio/PCM"));
    format.setSampleSize(16);
    format.setByteOrder(QAudioFormat::LittleEndian);
    format.setSampleType(QAudioFormat::SignedInt);

    QAudioDeviceInfo info(QAudioDeviceInfo::defaultOutputDevice());
    if (!info.isFormatSupported(format)) {
        format = info.nearestFormat(format);
        format.setSampleRate(16000);
        qDebug() << "Raw audio format not supported by backend. Trying the nearest format.";
    }

    m_audioInput = new QAudioInput(format, this);
#else
    format.setSampleFormat(QAudioFormat::Int16);

    m_audioInput = new QAudioSource(format, this);
#endif
    m_audioInput->start(&destinationFile);
}

void AudioRecorder::stop()
{
    m_audioInput->stop();
    destinationFile.close();
    delete m_audioInput;
}

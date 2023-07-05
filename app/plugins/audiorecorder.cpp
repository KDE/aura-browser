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
    format.setCodec(QStringLiteral("audio/PCM"));
    format.setSampleRate(16000);
    format.setSampleSize(16);
    format.setChannelCount(1);
    format.setByteOrder(QAudioFormat::LittleEndian);
    format.setSampleType(QAudioFormat::SignedInt);

    QAudioDeviceInfo info(QAudioDeviceInfo::defaultOutputDevice());
    if (!info.isFormatSupported(format)) {
        format = info.nearestFormat(format);
        format.setSampleRate(16000);
        qDebug() << "Raw audio format not supported by backend. Trying the nearest format.";
    }

    m_audioInput = new QAudioInput(format, this);
    m_audioInput->start(&destinationFile);
}

void AudioRecorder::stop()
{
    m_audioInput->stop();
    destinationFile.close();
    delete m_audioInput;
}

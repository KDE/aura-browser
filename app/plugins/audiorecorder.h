#ifndef AUDIORECORDER_H
#define AUDIORECORDER_H

#include <QObject>
#include <QAudioInput>
#include <QFile>

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
    QAudioInput *m_audioInput;
    QIODevice *device;
};

#endif // AUDIORECORDER_H

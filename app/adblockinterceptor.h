// SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QWebEngineUrlRequestInterceptor>

#include <atomic>

#include "third-party/ad-block/ad_block_client.h"

class AdblockInterceptor : public QWebEngineUrlRequestInterceptor
{
    Q_OBJECT

public:
    explicit AdblockInterceptor(QObject *parent = nullptr);
    ~AdblockInterceptor() override;

    void setEnabled(bool enabled);
    void interceptRequest(QWebEngineUrlRequestInfo &info) override;

private:
    AdBlockClient m_client;
    QThread *m_parseThread = nullptr;
    std::atomic<bool> m_ready = false;
    std::atomic<bool> m_enabled = true;
};

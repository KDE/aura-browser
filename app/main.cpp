/*
 *  Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <qtwebengineglobal.h>
#include "plugins/virtualMouse.h"
#include "plugins/virtualKeypress.h"
#include "plugins/globalSettings.h"
#include <QQmlContext>

static QObject *globalSettingsSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new GlobalSettings;
}

int main(int argc, char *argv[])
{
    qputenv("QT_VIRTUALKEYBOARD_DESKTOP_DISABLE", QByteArray("0"));
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    QCoreApplication::setOrganizationName("AuraBrowser");
    QCoreApplication::setApplicationName("AuraBrowser");
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    QtWebEngine::initialize();
    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/qml/images/logo-small.png"));

    QQmlApplicationEngine engine;
    FakeCursor fakeCursor;
    engine.rootContext()->setContextProperty("Cursor", &fakeCursor);
    QQmlContext* ctx = engine.rootContext();
    VirtualKeyPress virtualKeyPress;
    ctx->setContextProperty("keyEmitter", &virtualKeyPress);
    auto offlineStoragePath = QUrl::fromLocalFile(engine.offlineStoragePath());
    engine.rootContext()->setContextProperty("offlineStoragePath", offlineStoragePath);
    qmlRegisterSingletonType<GlobalSettings>("Aura", 1, 0, "GlobalSettings", globalSettingsSingletonProvider);
    qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/qml/NavigationSoundEffects.qml")), "Aura", 1, 0, "NavigationSoundEffects");
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}

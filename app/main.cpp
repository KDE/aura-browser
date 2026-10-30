// SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "browsersettings.h"
#include "version.h"

#include <KAboutData>
#include <KCrash>
#include <KDBusService>
#include <KLocalizedQmlContext>
#include <KLocalizedString>

#include <QCommandLineParser>
#include <QDir>
#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QtWebEngineQuick>

using namespace Qt::StringLiterals;

static QStringList urlsFromArguments(const QStringList &arguments, const QString &workingDirectory)
{
    QStringList urls;
    for (const QString &argument : arguments) {
        const QUrl url = QUrl::fromUserInput(argument, workingDirectory, QUrl::AssumeLocalFile);
        if (url.isValid()) {
            urls.append(url.toString());
        }
    }
    return urls;
}

int main(int argc, char *argv[])
{
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        qputenv("QT_QUICK_CONTROLS_STYLE", "org.kde.desktop");
    }

    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    QtWebEngineQuick::initialize();

    QGuiApplication application(argc, argv);

    KLocalizedString::setApplicationDomain("aura-browser");
    KAboutData aboutData(u"aura-browser"_s,
                         i18n("Aura Browser"),
                         QStringLiteral(AURA_VERSION_STRING),
                         i18n("Browse the web from your couch"),
                         KAboutLicense::GPL_V2,
                         i18n("© 2022-2026 KDE Community"));
    aboutData.addAuthor(i18n("Aditya Mehra"), QString(), u"aix.m@outlook.com"_s);
    aboutData.addAuthor(i18n("Devin Lin"), QString(), u"devin@kde.org"_s);
    aboutData.setLicense(KAboutLicense::GPL_V2, KAboutLicense::OrLaterVersions);
    aboutData.setDesktopFileName(u"org.kde.aura-browser"_s);
    KAboutData::setApplicationData(aboutData);
    QGuiApplication::setWindowIcon(QIcon::fromTheme(u"org.kde.aura-browser"_s, QIcon(u":/org.kde.aura-browser.svg"_s)));

    KCrash::initialize();

    QCommandLineParser parser;
    aboutData.setupCommandLine(&parser);
    parser.addPositionalArgument(u"urls"_s, i18n("Web pages to open"), u"[urls...]"_s);
    parser.process(application);
    aboutData.processCommandLine(&parser);

    KDBusService service(KDBusService::Unique);

    QQmlApplicationEngine engine;
    KLocalization::setupLocalizedContext(&engine);
    engine.loadFromModule("org.kde.aura", "Main");

    if (engine.rootObjects().isEmpty()) {
        return 1;
    }

    QObject *window = engine.rootObjects().constFirst();
    auto openUrls = [window](const QStringList &urls) {
        for (const QString &url : urls) {
            QMetaObject::invokeMethod(window, "openUrl", Q_ARG(QString, url));
        }
    };

    openUrls(urlsFromArguments(parser.positionalArguments(), QDir::currentPath()));

    QObject::connect(&service,
                     &KDBusService::activateRequested,
                     &engine,
                     [&parser, window, openUrls](const QStringList &arguments, const QString &workingDirectory) {
                         if (auto quickWindow = qobject_cast<QQuickWindow *>(window)) {
                             // show() would leave full screen for a normal window
                             quickWindow->setWindowStates(quickWindow->windowStates() & ~Qt::WindowMinimized);
                             quickWindow->setVisible(true);
                             quickWindow->raise();
                             quickWindow->requestActivate();
                         }
                         if (arguments.isEmpty()) {
                             return;
                         }
                         parser.parse(arguments);
                         openUrls(urlsFromArguments(parser.positionalArguments(), workingDirectory));
                     });

    QObject::connect(&application, &QCoreApplication::aboutToQuit, BrowserSettings::self(), [] {
        BrowserSettings::self()->save();
    });

    return application.exec();
}

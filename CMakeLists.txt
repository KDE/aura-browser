cmake_minimum_required(VERSION 3.16.0)

project(aura-browser)
set(PROJECT_VERSION "5.27.8")
set(PROJECT_VERSION_MAJOR 5)

set(QT_MIN_VERSION "5.15.2")
set(KF5_MIN_VERSION "5.102.0")
set(KDE_COMPILERSETTINGS_LEVEL "5.84.0")

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMInstallIcons)
include(FeatureSummary)

find_package(Qt${QT_MAJOR_VERSION} ${QT_MIN_VERSION} REQUIRED COMPONENTS 
    Core
    Qml
    Quick 
    Test
    Widgets
    QuickControls2
    Multimedia
)
if (QT_MAJOR_VERSION STREQUAL "6")
    find_package(Qt${QT_MAJOR_VERSION} ${QT_MIN_VERSION} REQUIRED COMPONENTS WebEngineQuick)
else ()
    find_package(Qt${QT_MAJOR_VERSION} ${QT_MIN_VERSION} REQUIRED COMPONENTS WebEngine)
endif()

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED 
    Kirigami2
    I18n
)

find_package(Threads)

add_subdirectory(app)
add_subdirectory(icons)

install(FILES org.kde.invent.aura_browser.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

ki18n_install(po)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

cmake_minimum_required(VERSION 3.24)

project(aura-browser VERSION 6.0.80)

set(QT_MIN_VERSION "6.11.0")
set(KF_MIN_VERSION "6.14.0")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(ECMSetupVersion)
include(ECMQmlModule)
include(ECMDeprecationSettings)
include(FeatureSummary)

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX AURA
    VERSION_HEADER ${CMAKE_CURRENT_BINARY_DIR}/version.h
)

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    WebChannelQuick
    WebEngineQuick
)

find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS
    Config
    CoreAddons
    Crash
    DBusAddons
    I18n
    Kirigami
)

include(ECMFindQmlModule)
ecm_find_qmlmodule(org.kde.bigscreen.ui 1.0)

ecm_set_disabled_deprecation_versions(QT 6.11.0
    KF 6.14.0
)

add_subdirectory(app)
add_subdirectory(icons)

install(FILES org.kde.aura-browser.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

ki18n_install(po)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB ALL_CLANG_FORMAT_SOURCE_FILES app/*.cpp app/*.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})

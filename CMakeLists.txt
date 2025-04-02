cmake_minimum_required(VERSION 3.16.0)

project(aura-browser)
set(PROJECT_VERSION "6.0.80")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_GLIBCXX_USE_CXX11_ABI=1")

set(QT_MIN_VERSION "6.6.0")
set(KF6_MIN_VERSION "5.240.0")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMInstallIcons)
include(FeatureSummary)
include(ECMDeprecationSettings)

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS
    Core
    Qml
    Quick
    Test
    Widgets
    QuickControls2
    Multimedia
    WebEngineQuick
)

find_package(KF6 ${KF6_MIN_VERSION} REQUIRED
    Kirigami
    I18n
)

find_package(Threads)

ecm_set_disabled_deprecation_versions(QT 6.8.1
    KF 6.9.0
)

add_subdirectory(app)
add_subdirectory(icons)

install(FILES org.kde.invent.aura_browser.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

ki18n_install(po)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

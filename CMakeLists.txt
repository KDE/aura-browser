cmake_minimum_required(VERSION 3.16.0)

project(aura-browser)
set(PROJECT_VERSION "5.25.80")
set(PROJECT_VERSION_MAJOR 5)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(QT_MIN_VERSION "5.15.2")
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(AUTORCC_OPTIONS "/app/qml.qrc")

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} "${CMAKE_SOURCE_DIR}/cmake")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)
include(ECMInstallIcons)
include(FeatureSummary)

find_package(Qt5 ${QT_MIN_VERSION} REQUIRED COMPONENTS 
    Core
    Qml
    Quick 
    WebEngine 
    Test
    Widgets
    QuickControls2
    Multimedia
)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED 
    Kirigami2
)

add_subdirectory(app)
add_subdirectory(icons)
add_definitions(-w)

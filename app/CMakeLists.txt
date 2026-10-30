qt_add_executable(aura-browser
    main.cpp

    adblockinterceptor.cpp
    adblockinterceptor.h
    pointercontroller.cpp
    pointercontroller.h
    webprofile.cpp
    webprofile.h

    third-party/ad-block/ad_block_client.cc
    third-party/ad-block/no_fingerprint_domain.cc
    third-party/ad-block/filter.cc
    third-party/ad-block/protocol.cc
    third-party/ad-block/context_domain.cc
    third-party/ad-block/cosmetic_filter.cc
    third-party/bloom-filter-cpp/BloomFilter.cpp
    third-party/bloom-filter-cpp/BloomFilter.h
    third-party/hashset-cpp/hash_set.cc
    third-party/hashset-cpp/hashFn.cc
)

kconfig_add_kcfg_files(aura-browser GENERATE_MOC browsersettings.kcfgc)

ecm_add_qml_module(aura-browser
    URI org.kde.aura
    GENERATE_PLUGIN_SOURCE
    NO_IMPORT_SCAN
    DEPENDENCIES
        QtQuick
        QtWebEngine
        QtWebChannel
        org.kde.bigscreen.ui
        org.kde.kirigami
)

ecm_target_qml_sources(aura-browser SOURCES
    qml/AddressDialog.qml
    qml/BrowserControls.qml
    qml/BrowserPage.qml
    qml/HomePage.qml
    qml/Main.qml
    qml/PointerCursor.qml
    qml/SettingsPage.qml
    qml/SiteCard.qml
    qml/SiteTile.qml
    qml/TabsPage.qml
    qml/WebView.qml
    qml/utils.js
)

qt_add_resources(aura-browser "resources"
    PREFIX "/"
    FILES
        scripts/focustracker.js
        third-party/easylist.txt
)

qt_add_resources(aura-browser "icon"
    PREFIX "/"
    BASE "../icons"
    FILES ../icons/org.kde.aura-browser.svg
)

target_include_directories(aura-browser PRIVATE ${PROJECT_BINARY_DIR})

target_link_libraries(aura-browser PRIVATE
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::WebEngineQuick
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::CoreAddons
    KF6::Crash
    KF6::DBusAddons
    KF6::I18n
    KF6::I18nQml
)

install(TARGETS aura-browser ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

set(DesktopNoDisplay "false")
set(DesktopMimeType "text/html;text/xml;application/xhtml_xml;x-scheme-handler/http;x-scheme-handler/https;")
set(DesktopExec "aura-browser %u")
configure_file(org.kde.aura-browser.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/org.kde.aura-browser.desktop)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.kde.aura-browser.desktop DESTINATION ${KDE_INSTALL_APPDIR})

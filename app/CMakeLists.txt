add_executable(aura-browser ${aura_browser_SRCS}
    main.cpp
    plugins/virtualMouse.cpp
    plugins/virtualKeypress.cpp
    plugins/globalSettings.cpp
    plugins/audiorecorder.cpp
    third-party/ad-block/ad_block_client.cc
    third-party/ad-block/no_fingerprint_domain.cc
    third-party/ad-block/filter.cc
    third-party/ad-block/protocol.cc
    third-party/ad-block/context_domain.cc
    third-party/ad-block/cosmetic_filter.cc
    third-party/bloom-filter-cpp/BloomFilter.cpp
    third-party/hashset-cpp/hash_set.cc
    third-party/hashset-cpp/hashFn.cc
    qml.qrc
)

target_link_libraries(aura-browser
    Qt5::Quick
    Qt5::Widgets
    Qt5::Core 
    Qt5::Qml
    Qt5::QuickControls2
    Qt5::WebEngine 
    Qt5::Test
    Qt5::Multimedia
    KF5::Kirigami2
    KF5::I18n
    ${CMAKE_THREAD_LIBS_INIT}
)

install(TARGETS aura-browser ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

set(DesktopNoDisplay "false")
set(DesktopMimeType "text/html;text/xml;application/xhtml_xml;x-scheme-handler/http;x-scheme-handler/https;")
set(DesktopExec "aura-browser %u")
configure_file(org.kde.aura-browser.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/org.kde.aura-browser.desktop)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.kde.aura-browser.desktop DESTINATION ${KDE_INSTALL_APPDIR})

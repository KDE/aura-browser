add_executable(aura-browser ${aura_browser_SRCS}
    main.cpp
    plugins/virtualMouse.cpp plugins/virtualMouse.h
    plugins/virtualKeypress.cpp plugins/virtualKeypress.h
    plugins/globalSettings.cpp plugins/globalSettings.h
    plugins/audiorecorder.cpp plugins/audiorecorder.h
    third-party/ad-block/ad_block_client.cc
    third-party/ad-block/no_fingerprint_domain.cc
    third-party/ad-block/filter.cc
    third-party/ad-block/protocol.cc
    third-party/ad-block/context_domain.cc
    third-party/ad-block/cosmetic_filter.cc
    third-party/bloom-filter-cpp/BloomFilter.cpp third-party/bloom-filter-cpp/BloomFilter.h
    third-party/hashset-cpp/hash_set.cc
    third-party/hashset-cpp/hashFn.cc
    qml.qrc
)

target_link_libraries(aura-browser
    Qt::Quick
    Qt::Widgets
    Qt::Core 
    Qt::Qml
    Qt::QuickControls2
    #Qt::WebEngine
    Qt::Test
    Qt::Multimedia
    KF5::Kirigami2
    KF5::I18n
    ${CMAKE_THREAD_LIBS_INIT}
)
if (QT_MAJOR_VERSION STREQUAL "6")
    target_link_libraries(aura-browser Qt::WebEngineQuick)
else ()
    target_link_libraries(aura-browser Qt::WebEngine)
endif()

install(TARGETS aura-browser ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

set(DesktopNoDisplay "false")
set(DesktopMimeType "text/html;text/xml;application/xhtml_xml;x-scheme-handler/http;x-scheme-handler/https;")
set(DesktopExec "aura-browser %u")
configure_file(org.kde.aura-browser.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/org.kde.aura-browser.desktop)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.kde.aura-browser.desktop DESTINATION ${KDE_INSTALL_APPDIR})

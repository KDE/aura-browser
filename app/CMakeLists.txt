add_executable(aura-browser ${aura_browser_SRCS}
    main.cpp
    plugins/virtualMouse.cpp plugins/virtualMouse.h
    plugins/virtualKeypress.cpp plugins/virtualKeypress.h
    plugins/globalSettings.cpp plugins/globalSettings.h
    plugins/keyfilter.cpp plugins/keyfilter.h
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
    Qt::WebEngineQuick
    Qt::Test
    Qt::Multimedia
    KF6::Kirigami
    KF6::I18n
    KF6::I18nQml
    ${CMAKE_THREAD_LIBS_INIT}
)

install(TARGETS aura-browser ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

set(DesktopNoDisplay "false")
set(DesktopMimeType "text/html;text/xml;application/xhtml_xml;x-scheme-handler/http;x-scheme-handler/https;")
set(DesktopExec "aura-browser %u")
configure_file(org.kde.aura-browser.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/org.kde.aura-browser.desktop)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.kde.aura-browser.desktop DESTINATION ${KDE_INSTALL_APPDIR})

qt5_add_resources(aura_browser_SRCS qml.qrc)
add_executable(AuraBrowser ${aura_browser_SRCS}
    main.cpp
    plugins/virtualMouse.cpp
    plugins/virtualKeypress.cpp
    plugins/globalSettings.cpp
    plugins/audiorecorder.cpp
)

target_link_libraries(AuraBrowser 
    Qt5::Quick
    Qt5::Widgets
    Qt5::Core 
    Qt5::Qml
    Qt5::QuickControls2
    Qt5::WebEngine 
    Qt5::Test
    Qt5::Multimedia
    KF5::Kirigami2
)

install(TARGETS AuraBrowser ${INSTALL_TARGETS_DEFAULT_ARGS})

set(DesktopNoDisplay "false")
set(DesktopMimeType "application/vnd.debian.binary-package;application/x-rpm;")
set(DesktopExec "AuraBrowser %F")
configure_file(org.aura.browser.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/org.aura.browser.desktop)
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/org.aura.browser.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

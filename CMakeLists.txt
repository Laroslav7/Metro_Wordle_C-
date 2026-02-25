cmake_minimum_required(VERSION 3.16)

project(MetroWordleC VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appMetroWordleC
    main.cpp
    MetroWordleBackend.cpp
    MetroWordleBackend.h
)

qt_add_qml_module(appMetroWordleC
    URI MetroWordleC
    QML_FILES
        Main.qml
)

qt_add_resources(appMetroWordleC "metro_assets"
    PREFIX "/"
    FILES
        BackGround/LockScreen.png
        bathroom_tiles/Create.png
        bathroom_tiles/Date.png
        bathroom_tiles/Desktop.png
        bathroom_tiles/Explorer.png
        bathroom_tiles/Galery.png
        bathroom_tiles/Game.png
        bathroom_tiles/Again.png
        bathroom_tiles/info.png
        bathroom_tiles/Mail.png
        bathroom_tiles/Music.png
        bathroom_tiles/Random.png
        bathroom_tiles/Seting.png
        bathroom_tiles/Store.png
        bathroom_tiles/user.png
        bathroom_tiles/Video.png
        bathroom_tiles/weather.png
)

set_target_properties(appMetroWordleC PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appMetroWordleC
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appMetroWordleC
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

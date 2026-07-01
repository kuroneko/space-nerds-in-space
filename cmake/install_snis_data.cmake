#
# This cmake script is executed during install in order to deploy the SNIS assets and to build the desktop icon
#

file(MAKE_DIRECTORY "$ENV{DESTDIR}${SNIS_DATA_DIR}")
execute_process(COMMAND ${CMAKE_INSTALL_PREFIX}/bin/snis_update_assets --force --destdir $ENV{DESTDIR}${CMAKE_INSTALL_PREFIX} --srcdir ${CMAKE_SOURCE_DIR}/share/snis)

if(CMAKE_SYSTEM_NAME MATCHES Linux)
    set(DESKTOP_PATH "${CMAKE_INSTALL_PREFIX}/share/applications")
    file(MAKE_DIRECTORY $ENV{DESTDIR}${DESKTOP_PATH})
    configure_file(../share/applications/io.github.smcameron.space-nerds-in-space.desktop.tmpl
        "$ENV{DESTDIR}${DESKTOP_PATH}/io.github.smcameron.space-nerds-in-space.desktop"
        FILE_PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
        @ONLY)
    file(INSTALL
        ../share/applications/io.github.smcameron.space-nerds-in-space.svg
        DESTINATION $ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/share/applications
        FILE_PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)
    execute_process(COMMAND update-desktop-database $ENV{DESTDIR}${DESKTOP_PATH})
endif()
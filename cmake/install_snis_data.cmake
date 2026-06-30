#
# This cmake script is executed during install in order to deploy the SNIS assets and to build the desktop icon
#
make_directory("${CMAKE_INSTALL_PREFIX}/share/snis")
execute_process(COMMAND ${CMAKE_INSTALL_PREFIX}/bin/snis_update_assets --force --destdir ${CMAKE_INSTALL_PREFIX} --srcdir ${CMAKE_CURRENT_SOURCE_DIR}/../share/snis)

set(DESKTOP_PATH "${CMAKE_INSTALL_PREFIX}/share/applications")

make_directory(${DESKTOP_PATH})
configure_file(../share/applications/io.github.smcameron.space-nerds-in-space.desktop.tmpl 
    "${DESKTOP_PATH}/io.github.smcameron.space-nerds-in-space.desktop"
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
    @ONLY)
file(INSTALL
    ../share/applications/io.github.smcameron.space-nerds-in-space.svg
    DESTINATION ${CMAKE_INSTALL_PREFIX}/share/applications
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)
execute_process(COMMAND update-desktop-database ${DESKTOP_PATH})

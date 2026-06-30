cmake_minimum_required(VERSION 3.20)
project(SNIS LANGUAGES C)

option(SNIS_WITH_VOICE_CHAT "Enable Voice Chat Support" ON)
set(SNIS_DATA_DIR "${CMAKE_INSTALL_PREFIX}/share/snis" CACHE PATH "SNIS Data Directory")

find_package(SDL2 REQUIRED)
find_package(PNG REQUIRED)
find_package(Lua REQUIRED)

include(FindPkgConfig)
pkg_check_modules(xcrypt REQUIRED libxcrypt)
pkg_check_modules(vorbisfile REQUIRED vorbisfile)
pkg_check_modules(portaudio REQUIRED portaudio-2.0)

if(SNIS_WITH_VOICE_CHAT)
	pkg_check_modules(opus REQUIRED opus)
endif()

# Search for the math library 'm'
find_library(MATH_LIBRARY m)

# included/embeded libraries.
add_subdirectory(ssgl)

add_library(glad STATIC extern/glad/src/gl.c)
target_include_directories(glad PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/extern/glad/include>)

# so many of SNIS's bits assume this'll be set, just use ACD to set it.
add_compile_definitions(PREFIX=${CMAKE_INSTALL_PREFIX})

add_library(sniscommon OBJECT
	arbitrary_spin.c
	bline.c
	c-is-the-locale.c
	commodities.c
	corporations.c
	infinite-taunt.c
	mathutils.c
	mesh.c
	mtwist.c
	names.c
	net_utils.c
	open-simplex-noise.c
	planetary_atmosphere.c
	planetary_properties.c
	planetary_ring_data.c
	pthread_util.c
	replacement_assets.c
	rootcheck.c
	rts_unit_data.c
	scipher.c
	shield_strength.c
	snis_alloc.c
	snis_asset_dir.c
	snis_bin_dir.c
	snis_damcon_systems.c
	snis_faction.c
	snis_licenses.c
	snis_marshal.c
	snis_opcode_def.c
	snis_ship_type.c
	snis_socket_io.c
	snis_tweak.c
	stacktrace.c
	starbase_metadata.c
	string-utils.c
	mikktspace/mikktspace.c
	)
target_link_libraries(sniscommon ${MATH_LIBRARY})

add_library(snisclientcommon OBJECT
	docking_port.c
	entity.c
	joystick.c
	liang-barsky.c
	material.c
	matrix.c
	my_point.c
	oriented_bounding_box.c
	pronunciation.c
	quat.c
	read_menu_file.c
	shape_collision.c
	snis_button.c
	snis_client_forker.c
	snis_debug_client.c
	snis_font.c
	snis_gauge.c
	snis_keyboard.c
	snis_label.c
	snis_preferences.c
	snis_process_options.c
	snis_pull_down_menu.c
	snis_sliders.c
	snis_strip_chart.c
	snis_text_input.c
	snis_text_window.c
	snis_typeface.c
	snis_ui_element.c
	snis_voice_chat.c
	starmap_adjacency.c
	stl_parser.c
	solarsystem_config.c
	thrust_attachment.c
	ui_colors.c
	vec4.c
	workqueue.c
	xdg_base_dir_spec.c)
target_link_libraries(snisclientcommon PUBLIC sniscommon)
target_include_directories(snisclientcommon PUBLIC ${opus_INCLUDE_DIRS})
target_link_libraries(snisclientcommon PUBLIC sniscommon ${opus_LIBRARIES} SDL2::SDL2)

add_executable(snis_client
	joystick_config.c
	ogg_to_pcm.c
	snis_client.c
	wwviaudio.c

	# SDL objs
	graph_dev_opengl.c
	opengl_cap.c
	png_utils.c
	shader.c
	snis_graph.c
	snis_xwindows_hacks.c
	turret_aimer.c
)
target_compile_definitions(snis_client PRIVATE DATADIR="${SNIS_DATA_DIR}")
target_include_directories(snis_client PRIVATE ${vorbisfile_INCLUDE_DIRS} ${portaudio_INCLUDE_DIRS} ${PNG_INCLUDE_DIRS})
target_link_libraries(snis_client PRIVATE snisclientcommon sniscommon ssglclient ${vorbisfile_LIBRARIES} ${portaudio_LIBRARIES} ${PNG_LIBRARIES} glad SDL2::SDL2main)

add_executable(snis_server
	snis_server.c
	starbase-comms.c
	power-model.c
	quat.c
	vec4.c
	matrix.c
	snis_event_callback.c
	space-part.c
	fleet.c
	docking_port.c
	elastic_collision.c
	snis_nl.c
	spelled_numbers.c
	snis_server_tracker.c
	snis_bridge_update_packet.c
	solarsystem_config.c
	a_star.c
	key_value_parser.c
	nonuniform_random_sampler.c
	oriented_bounding_box.c
	shape_collision.c
	graph_dev_mesh_stub.c
	turret_aimer.c
	snis_hash.c
	snis_debug_server.c
	ship_registration.c
	talking_stick.c
	transport_contract.c)
target_include_directories(snis_server PRIVATE ${LUA_INCLUDE_DIR} ${xcrypt_INCLUDE_DIRS})
target_link_libraries(snis_server PUBLIC sniscommon ssglclient ${LUA_LIBRARIES} ${xcrypt_LIBRARIES})

add_executable(snis_multiverse
	snis_multiverse.c
	snis_marshal.c
	snis_socket_io.c
	mathutils.c
	mtwist.c
	stacktrace.c
	snis_hash.c
	quat.c
	string-utils.c
	key_value_parser.c
	snis_bridge_update_packet.c
	pthread_util.c
	rootcheck.c
	starmap_adjacency.c
	replacement_assets.c
	snis_asset_dir.c
	snis_bin_dir.c
	snis_licenses.c
	net_utils.c
	commodities.c)
target_include_directories(snis_multiverse PRIVATE ${xcrypt_INCLUDE_DIRS})
target_link_libraries(snis_multiverse PUBLIC ssglclient ${xcrypt_LIBRARIES} ${MATH_LIBRARY})

add_executable(snis_arduino
	snis_arduino.c
	snis-device-io.c
	string-utils.c
)

# snis_update_assets
# mesh_viewer
# mask_clouds

configure_file(snis_launcher.tmpl ${CMAKE_CURRENT_BINARY_DIR}/snis_launcher @ONLY NEWLINE_STYLE UNIX)

install(TARGETS snis_server snis_client snis_multiverse snis_arduino)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/snis_launcher DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
	PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
)
cmake_minimum_required(VERSION 3.20)
project(SNIS LANGUAGES C)

if (UNIX)
	set(SNIS_BUILD_SERVERS_DEFAULT ON)
else()
	set(SNIS_BUILD_SERVERS_DEFAULT OFF)
endif()

option(SNIS_INSTALL_UTILS "Install Utilities" ON)
option(SNIS_BUILD_SERVERS "Build the SNIS servers" ${SNIS_BUILD_SERVERS_DEFAULT})
option(SNIS_WITH_VOICE_CHAT "Enable Voice Chat Support" ON)
option(SNIS_USE_GLES "Use OpenGL ES instead of OpenGL" OFF)
option(SNIS_PROFILE "Profile SNIS" OFF)

include(FetchContent)
FetchContent_Declare(
		tracy
		GIT_REPOSITORY https://github.com/wolfpld/tracy.git
		GIT_TAG master
		GIT_SHALLOW TRUE
		GIT_PROGRESS TRUE
)
if(SNIS_PROFILE)
	enable_language(CXX)
	set(TRACY_ENABLE ON)
	FetchContent_MakeAvailable(tracy)
endif()

find_package(SDL2 REQUIRED)
find_package(PNG REQUIRED)

if(SNIS_BUILD_SERVERS)
	find_package(Lua REQUIRED)
	if(Lua_FOUND AND NOT TARGET Lua::Lua)
	  add_library(Lua::Lua INTERFACE IMPORTED)
	  set_target_properties(
		Lua::Lua
		PROPERTIES
		  INTERFACE_INCLUDE_DIRECTORIES "${LUA_INCLUDE_DIR}"
		  INTERFACE_LINK_LIBRARIES "${LUA_LIBRARIES}"
	  )
	endif()

	include(FindPkgConfig)
	if(CMAKE_SYSTEM_NAME MATCHES Linux)
		pkg_check_modules(xcrypt REQUIRED IMPORTED_TARGET libxcrypt)
		set(CRYPT_LIB_NAME PkgConfig::xcrypt)
	else()
		set(CRYPT_LIB_NAME "")
	endif()
endif()

find_package(OpenSSL COMPONENTS Crypto REQUIRED)
pkg_check_modules(vorbisfile REQUIRED IMPORTED_TARGET vorbisfile)
pkg_check_modules(portaudio REQUIRED IMPORTED_TARGET portaudio-2.0)
pkg_check_modules(curl REQUIRED IMPORTED_TARGET libcurl)

if(SNIS_WITH_VOICE_CHAT)
	pkg_check_modules(opus REQUIRED IMPORTED_TARGET opus)
endif()

# Search for the math library 'm'
find_library(MATH_LIBRARY m)

# build build_info.h - legacy - needs fixing.
include (cmake/generate_build_info.cmake)
GenerateBuildInfo()

# included/embeded libraries.
add_subdirectory(ssgl)

# if we're building for GLES, use the GLES only version of glad.
if(SNIS_USE_GLES)
  add_library(glad STATIC extern/glad-es/src/gles2.c)
  target_include_directories(glad PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/extern/glad-es/include>)
else()
  add_library(glad STATIC extern/glad/src/gl.c)
  target_include_directories(glad PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/extern/glad/include>)
endif()

# so many of SNIS's bits assume these will be set, just use add_compile_definitions to set it.
add_compile_definitions(PREFIX=${CMAKE_INSTALL_PREFIX})
set(SNIS_DATA_DIR "${CMAKE_INSTALL_PREFIX}/share/snis")
add_compile_definitions(DATADIR="${SNIS_DATA_DIR}")
# also, globally include the shared generated directory where our build_info goes.
include_directories(${CMAKE_BINARY_DIR}/generated)

# similarly, just splatter USE_GLES over everything if we're targetting GLES.
if(SNIS_USE_GLES)
  add_compile_definitions(USE_GLES=1)
endif()

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
	snis_profile.c
)
target_link_libraries(sniscommon PUBLIC ${MATH_LIBRARY})
if(SNIS_PROFILE)
	target_link_libraries(sniscommon PUBLIC Tracy::TracyClient)
	target_compile_definitions(sniscommon PUBLIC ENABLE_PROFILING=1)
endif()

add_library(snisclientcommon OBJECT
	docking_port.c
	entity.c
	joystick.c
	liang-barsky.c
	material.c
	matrix.c
	my_point.c
	ogg_to_pcm.c
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
	wwviaudio.c
	xdg_base_dir_spec.c)
target_link_libraries(snisclientcommon PUBLIC sniscommon)
target_link_libraries(snisclientcommon PUBLIC sniscommon PkgConfig::opus PkgConfig::vorbisfile SDL2::SDL2)
if(SNIS_WITH_VOICE_CHAT)
	target_compile_definitions(snisclientcommon PUBLIC WITHVOICEHCAT=1)
endif()

add_executable(snis_client
	joystick_config.c
	png_utils.c
	shader.c
    snis_client.c
   	snis_graph.c	
	snis_xwindows_hacks.c
)
if(SNIS_USE_GLES)
	target_sources(snis_client PUBLIC graph_dev_gles.c gles_cap.c)
else()
	target_sources(snis_client PUBLIC graph_dev_opengl.c opengl_cap.c)
endif()

#target_compile_definitions(snis_client PRIVATE DATADIR="${SNIS_DATA_DIR}")
target_link_libraries(snis_client PRIVATE
	 snisclientcommon sniscommon ssglclient
	 PkgConfig::portaudio
	 PNG::PNG
	 glad
	 SDL2::SDL2main)

if(SNIS_BUILD_SERVERS)
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
	target_link_libraries(snis_server PUBLIC sniscommon ssglclient Lua::Lua ${CRYPT_LIB_NAME})

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
	target_link_libraries(snis_multiverse PUBLIC ssglclient ${MATH_LIBRARY} ${CRYPT_LIB_NAME})
endif()

add_executable(snis_arduino
	snis_arduino.c
	snis-device-io.c
	string-utils.c
)

add_executable(snis_update_assets
	util/snis_update_assets.c
	string-utils.c
	util/progress_image.h
)
target_link_libraries(snis_update_assets PRIVATE
	SDL2::SDL2 SDL2::SDL2main
	OpenSSL::Crypto
	PkgConfig::curl)

if(UNIX)
	configure_file(snis_launcher.tmpl ${CMAKE_CURRENT_BINARY_DIR}/snis_launcher @ONLY NEWLINE_STYLE UNIX)
	configure_file(util/update_assets_from_launcher.sh.tmpl ${CMAKE_CURRENT_BINARY_DIR}/update_assets_from_launcher.sh @ONLY NEWLINE_STYLE UNIX)
endif()

if(SNIS_INSTALL_UTILS)
	add_executable(mesh_viewer
		shader.c
		snis_graph.c
		png_utils.c
		turret_aimer.c
		quat.c
		mathutils.c
		mesh.c
		mtwist.c
		material.c
		entity.c
		snis_alloc.c
		matrix.c
		stacktrace.c
		stl_parser.c
		snis_typeface.c
		snis_font.c
		string-utils.c
		ui_colors.c
		liang-barsky.c
		bline.c
		vec4.c
		open-simplex-noise.c
		replacement_assets.c
		snis_xwindows_hacks.c
		workqueue.c
		pthread_util.c
		mikktspace/mikktspace.c

		mesh_viewer.c)
	target_link_libraries(mesh_viewer PRIVATE
		glad PNG::PNG SDL2::SDL2 SDL2::SDL2main
		${MATH_LIBRARY})
	if(SNIS_USE_GLES)
		target_sources(mesh_viewer PUBLIC graph_dev_gles.c gles_cap.c)
	else()
		target_sources(mesh_viewer PUBLIC graph_dev_opengl.c opengl_cap.c)
	endif()

	# mask_clouds
	add_executable(mask_clouds 
		util/mask_clouds.c
		png_utils.c)
	target_link_libraries(mask_clouds PRIVATE PNG::PNG)

	add_executable(cloud-mask-normalmap
		util/cloud-mask-normalmap.c
		png_utils.c)
	target_link_libraries(cloud-mask-normalmap PRIVATE PNG::PNG)

	add_executable(sample_image_colors
		util/sample_image_colors.c
		png_utils.c)
	target_link_libraries(sample_image_colors PRIVATE PNG::PNG)

	add_executable(generate_solarsystem_positions
		util/generate_solarsystem_positions.c
		string-utils.c)
	target_link_libraries(generate_solarsystem_positions PRIVATE ${MATH_LIBRARY})

	add_executable(nebula_noise
		nebula_noise.c
		open-simplex-noise.c
		png_utils.c)
	target_link_libraries(nebula_noise PRIVATE
		PNG::PNG
		${MATH_LIBRARY})

	add_executable(generate_skybox
		generate_skybox.c
		open-simplex-noise.c
		png_utils.c
		mathutils.c
		quat.c
		mtwist.c)
	target_link_libraries(generate_skybox PRIVATE
		PNG::PNG
		${MATH_LIBRARY})

	add_executable(earthlike
		earthlike.c
		mtwist.c
		mathutils.c
		quat.c
		open-simplex-noise.c
		png_utils.c
		crater.c
		pthread_util.c)
	target_link_libraries(earthlike PRIVATE
		PNG::PNG
		${MATH_LIBRARY})
endif()


# Install binaries and scripts
install(TARGETS snis_client snis_arduino snis_update_assets)
if(SNIS_BUILD_SERVERS)
	install(TARGETS snis_server snis_multiverse)
endif()

if(UNIX)
	install(FILES
		${CMAKE_CURRENT_BINARY_DIR}/snis_launcher
		${CMAKE_CURRENT_BINARY_DIR}/update_assets_from_launcher.sh
		DESTINATION bin
		PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
	)
endif()

if(SNIS_INSTALL_UTILS)
	install(TARGETS mesh_viewer mask_clouds cloud-mask-normalmap sample_image_colors 
		generate_solarsystem_positions nebula_noise generate_skybox earthlike)
endif()

# Install data
install(FILES
	man/snis_client.6
	man/snis_server.6
	man/snis_text_to_speech.sh.6
	ssgl/ssgl_server.6
	man/snis_multiverse.6
	man/snis_update_assets.6
	DESTINATION man/man6
	PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)
install(FILES
	man/earthlike.1
	man/snis_test_audio.1
	man/lsssgl.1
	DESTINATION man/man1
	PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)
configure_file(cmake/install_snis_data.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/install_snis_data.cmake @ONLY)
install(SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/install_snis_data.cmake)


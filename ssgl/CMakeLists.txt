cmake_minimum_required(VERSION 3.20)
project(ssgl LANGUAGES C)

add_library(ssglclient STATIC
		 ssgl_sleep.c
		 ssgl_sanitize.c
		 ssgl_recv_game_servers.c
		 ssgl_connect_to_lobby.c
		 ssgl_socket_io.c
		 ssgl_get_primary_host_ip_addr.c
		 ssgl_register_gameserver.c
		 ssgl_log.c
		 ssgl_register_for_bcast_packet.c
		 ssgl_get_gamelobby_port.c
		 ssgl_string.c)
target_include_directories(ssglclient PUBLIC
				      $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)

add_library(ssglserver STATIC
	ssgl_sanitize.c
	ssgl_sleep.c
	ssgl_socket_io.c
	ssgl_log.c
	ssgl_get_primary_host_ip_addr.c
	ssgl_get_gamelobby_port.c
	ssgl_string.c)
target_include_directories(ssglserver PUBLIC
				      $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
	

add_executable(ssgl_server
	ssgl_server.c)
target_link_libraries(ssgl_server PRIVATE ssglserver)

add_executable(ssgl_gameclient_example
	ssgl_gameclient_example.c)
target_link_libraries(ssgl_gameclient_example PRIVATE ssglclient)
set_target_properties(ssgl_gameclient_example PROPERTIES OUTPUT_NAME lsssgl)

add_executable(ssgl_gameserver_example EXCLUDE_FROM_ALL
	ssgl_gameserver_example.c)
target_link_libraries(ssgl_gameserver_example PRIVATE ssglclient)

install(TARGETS ssgl_server ssgl_gameclient_example)

function(GenerateBuildInfo)
    if (SNIS_WITH_VOICE_CHAT)
        set(with_voice_chat "COMPILED WITH VOICE CHAT ENABLED")
    else()
        set(with_voice_chat "COMPILED WITHOUT VOICE CHAT ENABLED")
    endif()
    set(machine ${CMAKE_SYSTEM_PROCESSOR})
    set(os ${CMAKE_SYSTEM_NAME})

    include(TestBigEndian)
    test_big_endian(SYS_BIG_ENDIAN)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(wordsize "64-bit")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
        set(wordsize "32-bit")
    else()
        message(FATAL_ERROR "Couldn't determine processor word size")
    endif()
    if(SYS_BIG_ENDIAN)
        set(endianness "$wordsize big-endian")
    else()
        set(endianness "$wordsize little-endian")
    endif()
    if (EXISTS ${CMAKE_SOURCE_DIR}/.git)
        execute_process(COMMAND git rev-parse HEAD
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                OUTPUT_VARIABLE git_hash
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        execute_process(COMMAND git status --porcelain -uno
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                OUTPUT_VARIABLE difffiles
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        if (NOT difffiles STREQUAL "")
            execute_process(COMMAND git diff --shortstat
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                    OUTPUT_VARIABLE diffsummary
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
        else()
            set(diffsummary "")
        endif()
    else()
        set(git_hash "unknown-git-hash")
        set(diffsummary "")
    endif()
    configure_file(${CMAKE_SOURCE_DIR}/build_info.h.tmpl ${CMAKE_BINARY_DIR}/generated/build_info.h @ONLY)
endfunction()
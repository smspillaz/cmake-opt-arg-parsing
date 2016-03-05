# /OptimizedParseArguments.cmake
#
# Optimized versions of cmake_parse_arguments, caches the result of
# previous invocations.
#
# Use cmake_unit_parse_args_key to parse some arguments and get a "key"
# to fetch the argument values from later using cmake_fetch_parsed_arg. The
# key is computed from the value of the arguments when converted to a string
# and will be returned immediately if a result is already present.
#
# See /LICENCE.md for Copyright information
include (conanbuildinfo.cmake)

include ("smspillaz/cmake-include-guard/IncludeGuard")
cmake_include_guard (SET_MODULE_PATH)

include (CMakeParseArguments)

# cmake_unit_parse_args_key
#
# This is an optimization on cmake_parse_arguments which should
# help to reduce the number of times which it is called. Effectively,
# it hashes its arguments and then checks to see if we've called
# cmake_parse_arguments with this kind of hash. If we have, it uses
# the cached values.
#
# PREFIX: cmake_parse_arguments PREFIX
# OPTION_ARGS_STRING: "Option" like arguments, which are either present or
#                     not present.
# SINGLEVAR_ARGS_STRING: "Single variable" like arguments, which only have
#                        one value.
# MULTIVAR_ARGS_STRING: "Multiple variable" like arguments, which can have
#                       multiple variables.
# RETURN_KEY: A variable to store the computed key for later use with
#             cmake_fetch_parsed_arg.
function (cmake_parse_args_key PREFIX
                               OPTION_ARGS_STRING
                               SINGLEVAR_ARGS_STRING
                               MULTIVAR_ARGS_STRING
                               RETURN_KEY)

    # First get the key for this variable length arguments set
    string (MD5 CACHE_KEY "${ARGV}")

    # Lookup to see if we've parsed arguments like these before
    get_property (CACHE_KEY_IS_SET
                  GLOBAL
                  PROPERTY _CMAKE_OPT_PARSE_ARGS_CACHED_${CACHE_KEY})
    if (NOT CACHE_KEY_IS_SET)

        # Cache key was not set. Parse arguments and then store the
        # results in global properties.
        cmake_parse_arguments (${PREFIX}
                               "${OPTION_ARGS_STRING}"
                               "${SINGLEVAR_ARGS_STRING}"
                               "${MULTIVAR_ARGS_STRING}"
                               ${ARGN})

        set (VARIABLES ${OPTION_ARGS_STRING}
                       ${SINGLEVAR_ARGS_STRING}
                       ${MULTIVAR_ARGS_STRING})

        foreach (VAR ${VARIABLES})

            set_property (GLOBAL
                          PROPERTY
                          _CMAKE_OPT_PARSE_ARGS_CACHED_${CACHE_KEY}_${VAR}
                          "${${PREFIX}_${VAR}}")

        endforeach ()

        set_property (GLOBAL
                      PROPERTY _CMAKE_OPT_PARSE_ARGS_CACHED_${CACHE_KEY}
                      TRUE)

    endif ()

    set (${RETURN_KEY} ${CACHE_KEY} PARENT_SCOPE)

endfunction ()

# cmake_fetch_parsed_arg
#
# Fetch the value of a parsed argument from cmake_parse_args_key.
#
# A value named ${PREFIX}_${ARGUMENT} will be set in the PARENT_SCOPE
# after calling this function, much like cmake_parse_arguments.
#
# CACHE_KEY: The key returned by cmake_parse_args_key
# PREFIX: The argument prefix as passed to cmake_parse_args_key
# ARGUMENT: The name of the argument (not the return value).
function (cmake_fetch_parsed_arg CACHE_KEY PREFIX ARGUMENT)

    get_property (VALUE GLOBAL
                  PROPERTY
                  _CMAKE_OPT_PARSE_ARGS_CACHED_${CACHE_KEY}_${ARGUMENT})
    set (${PREFIX}_${ARGUMENT} "${VALUE}" PARENT_SCOPE)

endfunction ()

# cmake_unit_spacify
#
# Turn semi-colon separated list into space-separated string. Useful
# for turning list arguments into subprocess arguments.
#
# Pass NO_QUOTES to suppress quoting of each item.
#
# RETURN_SPACED: Variable to place spacified list into.
# LIST: List to spacify.
# [Optional] NO_QUOTES: Do not quote individual entries by default.
function (cmake_unit_spacify RETURN_SPACED)

    cmake_unit_parse_args_key (SPACIFY
                               "NO_QUOTES"
                               ""
                               "LIST"
                               PARSE_KEY ${ARGN})
    cmake_unit_fetch_parsed_arg (${PARSE_KEY} SPACIFY LIST)

    set (SPACIFIED "")
    foreach (ELEMENT ${SPACIFY_LIST})

        if (SPACIFY_NO_QUOTES)

            set (SPACIFIED "${SPACIFIED}${ELEMENT} ")

        else ()

            set (SPACIFIED "${SPACIFIED}\"${ELEMENT}\" ")

        endif ()

    endforeach ()

    string (STRIP "${SPACIFIED}" SPACIFIED)
    set (${RETURN_SPACED} "${SPACIFIED}" PARENT_SCOPE)

endfunction ()

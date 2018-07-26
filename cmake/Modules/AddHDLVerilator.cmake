# Copyright 2018 Tymoteusz Blazejczyk
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if (COMMAND add_hdl_verilator)
    return()
endif()

if (NOT DEFINED _HDL_CMAKE_ROOT_DIR)
    set(_HDL_CMAKE_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL
        "HDL CMake root directory" FORCE)
endif()

include(GetHDLDepends)

find_package(SystemC REQUIRED COMPONENTS SCV UVM)
find_package(Verilator)

if (VERILATOR_FOUND)
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/verilator/unit_tests")
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/verilator/coverage/run")

    add_custom_target(verilator-coverage
        COMMAND
            ${VERILATOR_COVERAGE_EXECUTABLE}
            --annotate-all
            --annotate "${CMAKE_BINARY_DIR}/verilator/coverage"
            "${CMAKE_BINARY_DIR}/verilator/coverage/run/*/*.coverage"
            "${CMAKE_BINARY_DIR}/systemc/unit_tests/*/*.coverage"
        COMMENT
            "Verilator coverage"
    )

    if (NOT TARGET verilator-compile-all)
        add_custom_target(verilator-compile-all ALL)
    endif()

    if (NOT TARGET verilator-analysis-all)
        add_custom_target(verilator-analysis-all)
    endif()

    if (NOT TARGET verilator-coverage-all)
        add_custom_target(verilator-coverage-all ALL)
    endif()
endif()

function(add_hdl_verilator)
    if (NOT VERILATOR_FOUND)
        return()
    endif()

    if (NOT DEFINED ARG_SYNTHESIZABLE OR NOT ARG_SYNTHESIZABLE)
        return()
    endif()

    if (DEFINED ARG_ANALYSIS)
        if (ARG_ANALYSIS MATCHES ALL OR ARG_ANALYSIS MATCHES Verilator)
            set(verilator_analysis TRUE)
        else()
            set(verilator_analysis FALSE)
        endif()
    endif()

    if (DEFINED ARG_ANALYSIS_EXCLUDE MATCHES Verilator)
        if (ARG_ANALYSIS_EXCLUDE MATCHES Verilator)
            set(verilator_analysis FALSE)
        endif()
    endif()

    if (DEFINED ARG_COMPILE)
        if (ARG_COMPILE MATCHES ALL OR ARG_COMPILE MATCHES Verilator)
            set(verilator_compile TRUE)
        else()
            set(verilator_compile FALSE)
        endif()
    endif()

    if (DEFINED ARG_COMPILE_EXCLUDE MATCHES Verilator)
        if (ARG_COMPILE_EXCLUDE MATCHES Verilator)
            set(verilator_compile FALSE)
        endif()
    endif()

    if (NOT verilator_analysis AND NOT verilator_compile)
        return()
    endif()

    if (verilator_analysis OR verilator_compile)
        set(verilator_coverage TRUE)
    else()
        set(verilator_coverage FALSE)
    endif()

    if (NOT DEFINED ARG_TARGET)
        set(ARG_TARGET ${ARG_NAME})
    endif()

    set(verilator_files "")
    set(verilator_sources "")
    set(verilator_defines "")
    set(verilator_depends "")
    set(verilator_includes "")
    set(verilator_parameters "")
    set(verilator_configurations "")

    set(verilator_library_dir
        "${CMAKE_BINARY_DIR}/verilator/libraries/${ARG_TARGET}")

    set(verilator_coverage_dir
        "${CMAKE_BINARY_DIR}/verilator/coverage/run/${ARG_TARGET}")

    set(systemc_unit_test_dir
        "${CMAKE_BINARY_DIR}/systemc/unit_tests/${ARG_TARGET}")

    list(APPEND verilator_defines ${ARG_DEFINES})
    list(APPEND verilator_parameters ${ARG_PARAMETERS})

    get_hdl_depends(${ARG_NAME} depends)

    foreach (name ${depends} ${ARG_NAME})
        get_target_property(hdl_source ${name} HDL_SOURCE)
        get_target_property(hdl_sources ${name} HDL_SOURCES)

        foreach (hdl_source ${hdl_sources} ${hdl_source})
            if (hdl_source MATCHES "\.s?v$")
                list(APPEND verilator_sources ${hdl_source})
            endif()
        endforeach()

        get_target_property(hdl_defines ${name} HDL_DEFINES)
        list(APPEND verilator_defines ${hdl_defines})

        get_target_property(hdl_includes ${name} HDL_INCLUDES)
        list(APPEND verilator_includes ${hdl_includes})

        get_target_property(hdl_files ${name} HDL_VERILATOR_FILES)
        list(APPEND verilator_files ${hdl_files})

        get_target_property(hdl_configs ${name}
            HDL_VERILATOR_CONFIGURATIONS)
        list(APPEND verilator_configurations ${hdl_configs})

        get_target_property(hdl_type ${name} HDL_TYPE)
        if (hdl_type MATCHES Qsys)
            list(APPEND verilator_depends qsys-compile-${name})
        endif()
    endforeach()

    list(REMOVE_DUPLICATES verilator_defines)
    list(REMOVE_DUPLICATES verilator_includes)
    list(REMOVE_DUPLICATES verilator_parameters)
    list(REMOVE_DUPLICATES verilator_configurations)

    set(verilator_configuration_file
        "${verilator_library_dir}/${ARG_TARGET}.vlt")

    set(verilator_config "")
    foreach (config ${verilator_configurations})
        set(verilator_config "${verilator_config}${config}\n")
    endforeach()

    configure_file("${_HDL_CMAKE_ROOT_DIR}/VerilatorConfig.cmake.in"
        "${verilator_configuration_file}")

    set(verilator_flags "")

    list(APPEND verilator_flags --top-module ${ARG_NAME})

    if (ARG_VERILATOR_ALL_WARNINGS)
        list(APPEND verilator_flags -Wall)
    endif()

    if (ARG_VERILATOR_LINT_WARNINGS)
        list(APPEND verilator_flags -Wwarn-lint)
    else()
        list(APPEND verilator_flags -Wno-lint)
    endif()

    if (ARG_VERILATOR_STYLE_WARNINGS)
        list(APPEND verilator_flags -Wwarn-style)
    else()
        list(APPEND verilator_flags -Wno-style)
    endif()

    if (NOT ARG_VERILATOR_FATAL_WARNINGS)
        list(APPEND verilator_flags -Wno-fatal)
    endif()

    foreach (verilator_parameter ${verilator_parameters})
        list(APPEND verilator_flags -G${verilator_parameter})
    endforeach()

    foreach (verilator_define ${verilator_defines})
        list(APPEND verilator_flags -D${verilator_define})
    endforeach()

    foreach (verilator_include ${verilator_includes})
        list(APPEND verilator_flags -I${verilator_include})
    endforeach()

    foreach (verilator_file ${verilator_files})
        list(APPEND verilator_flags -f ${verilator_file})
    endforeach()

    list(APPEND verilator_flags ${verilator_configuration_file})
    list(APPEND verilator_flags ${verilator_sources})

    if (verilator_analysis AND NOT TARGET verilator-analysis-${ARG_TARGET})
        set(analysis_flags "")
        list(APPEND analysis_flags --lint-only)

        add_custom_target(verilator-analysis-${ARG_TARGET}
                ${VERILATOR_EXECUTABLE}
                ${analysis_flags}
                ${verilator_flags}
            DEPENDS
                ${verilator_sources}
                ${verilator_includes}
                ${verilator_configuration_file}
            COMMENT
                "Verilator analysising ${ARG_TARGET}"
        )

        add_dependencies(verilator-analysis-all
            verilator-analysis-${ARG_TARGET})
    endif()

    if (verilator_coverage AND NOT TARGET verilator-coverage-${ARG_TARGET})
        file(MAKE_DIRECTORY "${verilator_coverage_dir}")
        file(MAKE_DIRECTORY "${systemc_unit_test_dir}")
        set(verilator_main "${verilator_coverage_dir}/${ARG_TARGET}_main.cpp")
        set(verilator_coverage_run "${verilator_coverage_dir}/${ARG_TARGET}")

        configure_file("${_HDL_CMAKE_ROOT_DIR}/verilator_coverage.cpp.in"
            "${verilator_main}")

        set(coverage_flags "")
        list(APPEND coverage_flags --cc)
        list(APPEND coverage_flags --coverage)
        list(APPEND coverage_flags --prefix ${ARG_TARGET})
        list(APPEND coverage_flags --exe)
        list(APPEND coverage_flags -o ${ARG_TARGET})
        list(APPEND coverage_flags -Mdir .)

        add_custom_command(
            OUTPUT
                "${verilator_coverage_run}"
            COMMAND
                ${VERILATOR_EXECUTABLE}
            ARGS
                ${coverage_flags}
                ${verilator_flags}
                ${verilator_main}
            COMMAND
                make
            ARGS
                -f ${ARG_TARGET}.mk
            COMMAND
                ./${ARG_TARGET}
            DEPENDS
                ${verilator_sources}
                ${verilator_includes}
                ${verilator_configuration_file}
                ${verilator_main}
            COMMENT
                "Verilator coveraging ${ARG_TARGET}"
            WORKING_DIRECTORY
                "${verilator_coverage_dir}"
        )

        add_custom_target(verilator-coverage-${ARG_TARGET} DEPENDS
            "${verilator_coverage_run}")

        add_dependencies(${ARG_NAME} verilator-coverage-${ARG_TARGET})

        add_dependencies(verilator-coverage-all
            verilator-coverage-${ARG_TARGET})
    endif()

    if (verilator_compile AND NOT TARGET verilator-compile-${ARG_TARGET})
        file(MAKE_DIRECTORY "${verilator_library_dir}")

        set(compile_flags "")
        list(APPEND compile_flags --sc)
        list(APPEND compile_flags --trace)
        list(APPEND compile_flags --coverage)
        list(APPEND compile_flags --prefix ${ARG_TARGET})
        list(APPEND compile_flags -O2)
        list(APPEND compile_flags -Mdir .)

        if (CMAKE_CXX_COMPILER_ID MATCHES GNU OR
                CMAKE_CXX_COMPILER_ID MATCHES Clang)
            set(flags -std=c++11 -O2 -fdata-sections -ffunction-sections)
            list(APPEND compile_flags -CFLAGS '${flags}')
        endif()

        set(verilator_library
            "${verilator_library_dir}/${ARG_TARGET}__ALL.a")

        add_custom_command(
            OUTPUT
                "${verilator_library}"
            COMMAND
                ${VERILATOR_EXECUTABLE}
            ARGS
                ${compile_flags}
                ${verilator_flags}
                "${verilator_main}"
            COMMAND
                make
            ARGS
                -f ${ARG_TARGET}.mk
            DEPENDS
                ${verilator_sources}
                ${verilator_includes}
                ${verilaotr_configuration_file}
            WORKING_DIRECTORY
                ${verilator_library_dir}
            COMMENT
                "Verilator compiling ${ARG_TARGET}"
        )

        add_custom_target(verilator-compile-${ARG_TARGET} DEPENDS
            "${verilator_library}")

        if (verilator_depends)
            add_dependencies(verilator-compile-${ARG_TARGET} DEPENDS
                ${verilator_depends})
        endif()

        add_dependencies(${ARG_NAME} verilator-compile-${ARG_TARGET})

        add_dependencies(verilator-compile-all
            verilator-compile-${ARG_TARGET})

        add_library(systemc-module-${ARG_TARGET} STATIC IMPORTED)

        add_dependencies(systemc-module-${ARG_TARGET}
            verilator-compile-${ARG_TARGET})

        set(systemc_module_includes
            "${verilator_library_dir}"
            "${SYSTEMC_INCLUDE_DIRS}"
            "${VERILATOR_INCLUDE_DIR}"
        )

        set(systemc_module_libraries
            systemc
            verilated
        )

        set_target_properties(systemc-module-${ARG_TARGET} PROPERTIES
            IMPORTED_LOCATION "${verilator_library}"
            INTERFACE_LINK_LIBRARIES "${systemc_module_libraries}"
            INTERFACE_INCLUDE_DIRECTORIES "${systemc_module_includes}"
            INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "${systemc_module_includes}")
    endif()
endfunction()

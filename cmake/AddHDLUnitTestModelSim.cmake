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

if (COMMAND add_hdl_unit_test_modelsim)
    return()
endif()

if (NOT DEFINED _HDL_CMAKE_ROOT_DIR)
    set(_HDL_CMAKE_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL
        "HDL CMake root directory" FORCE)
endif()

find_package(ModelSim)

include(GetHDLDepends)

function(add_hdl_unit_test_modelsim)
    if (NOT SVUNIT_FOUND)
        return()
    endif()

    if (NOT MODELSIM_FOUND)
        return()
    endif()

    set(unit_test_dir "${CMAKE_BINARY_DIR}/modelsim/unit_tests/${ARG_NAME}")

    set(modelsim_outputs "")
    set(modelsim_depends "")
    set(modelsim_waveform "${unit_test_dir}/${ARG_NAME}.wlf")
    set(modelsim_ini_file "${_HDL_CMAKE_ROOT_DIR}/modelsim.ini")

    file(MAKE_DIRECTORY "${unit_test_dir}")

    get_filename_component(modelsim_run_tcl
        "${_HDL_CMAKE_ROOT_DIR}/../scripts/modelsim_run.tcl" REALPATH)

    set(hdl_depends "")
    get_hdl_depends(${ARG_NAME} hdl_depends)

    foreach (hdl_name ${hdl_depends} ${ARG_NAME})
        get_target_property(hdl_source ${hdl_name} HDL_SOURCE)
        get_target_property(mif_files ${hdl_name} HDL_MIF_FILES)
        get_target_property(input_files ${hdl_name} HDL_INPUT_FILES)

        get_filename_component(dir "${hdl_source}" DIRECTORY)

        foreach (file ${mif_files} ${input_files})
            if (file MATCHES "${dir}")
                file(RELATIVE_PATH modelsim_file "${dir}" "${file}")
                set(modelsim_file "${unit_test_dir}/${modelsim_file}")

                get_filename_component(dir "${modelsim_file}" DIRECTORY)
                get_filename_component(name "${modelsim_file}" NAME)

                file(MAKE_DIRECTORY "${dir}")

                if (UNIX)
                    add_custom_command(
                        OUTPUT
                            "${modelsim_file}"
                        COMMAND
                            ${CMAKE_COMMAND}
                        ARGS
                            -E create_symlink "${file}" "${name}"
                        DEPENDS
                            "${file}"
                        WORKING_DIRECTORY
                            "${dir}"
                    )
                else()
                    add_custom_command(
                        OUTPUT
                            "${modelsim_file}"
                        COMMAND
                            ${CMAKE_COMMAND}
                        ARGS
                            -E copy "${file}" "${name}"
                        DEPENDS
                            "${file}"
                        WORKING_DIRECTORY
                            "${dir}"
                    )
                endif()

                list(APPEND modelsim_outputs "${modelsim_file}")
            endif()
        endforeach()

        get_target_property(qsys_inputs ${hdl_name} HDL_QUARTUS_QSYS_INPUTS)
        if (qsys_inputs)
            set(modelsim_file "${CMAKE_BINARY_DIR}/${ARG_NAME}.${hdl_name}.dep")

            add_custom_command(
                OUTPUT
                    "${modelsim_file}"
                COMMAND
                    ${CMAKE_COMMAND}
                ARGS
                    -DINPUT_FILES="${qsys_inputs}"
                    -DOUTPUT_DIRECTORY="${unit_test_dir}"
                    -P "${_HDL_CMAKE_ROOT_DIR}/AddHDLQsysInputs.cmake"
                COMMAND
                    ${CMAKE_COMMAND}
                ARGS
                    -E touch "${modelsim_file}"
            )

            list(APPEND modelsim_outputs "${modelsim_file}")
            list(APPEND modelsim_depends qsys-compile-${hdl_name})
        endif()
    endforeach()

    if (modelsim_depends)
        add_custom_target(modelsim-initialize-${ARG_NAME}_runner
            DEPENDS ${modelsim_outputs})

        add_dependencies(modelsim-compile-${ARG_NAME}_runner
            modelsim-initialize-${ARG_NAME}_runner)
    endif()

    if (modelsim_depends)
        add_dependencies(modelsim-initialize-${ARG_NAME}_runner
            ${modelsim_depends})
    endif()

    set(modelsim_flags "")
    set(modelsim_libraries "")

    if (DEFINED ARG_MODELSIM_SUPPRESS)
        list(LENGTH ARG_MODELSIM_SUPPRESS len)

        if (len GREATER 0)
            list(GET ARG_MODELSIM_SUPPRESS 0 suppress)
            list(REMOVE_AT ARG_MODELSIM_SUPPRESS 0)

            foreach (value ${ARG_MODELSIM_SUPPRESS})
                set(suppress "${suppress},${value}")
            endforeach()

            list(APPEND modelsim_flags -suppress ${suppress})
        endif()
    endif()

    foreach (modelsim_parameter ${ARG_PARAMETERS})
        list(APPEND modelsim_flags
            -G/${ARG_NAME}_runner/ut/${modelsim_parameter})
    endforeach()

    if (ARG_MODELSIM_WARNING_AS_ERROR)
        list(APPEND modelsim_flags -warning error)
    endif()

    list(APPEND modelsim_flags +nowarn3116)
    list(APPEND modelsim_flags -modelsimini "${modelsim_ini_file}")
    list(APPEND modelsim_flags -wlf "${modelsim_waveform}")
    list(APPEND modelsim_flags -do "${modelsim_run_tcl}")
    list(APPEND modelsim_flags ${ARG_MODELSIM_FLAGS})
    list(APPEND modelsim_flags -Ldir "${CMAKE_BINARY_DIR}/modelsim/libraries")

    get_hdl_depends(${ARG_NAME}_runner modelsim_libraries)

    foreach (hdl_library ${modelsim_libraries} ${ARG_NAME}_runner)
        list(APPEND modelsim_flags -L ${hdl_library})
    endforeach()

    add_test(
        NAME
            ${ARG_NAME}
        COMMAND
            ${MODELSIM_VSIM}
            -c
            ${modelsim_flags}
            ${ARG_NAME}_runner.${ARG_NAME}_runner
        WORKING_DIRECTORY
            "${unit_test_dir}"
    )

    set(modelsim_simulator "${MODELSIM_VSIM}")
    set(modelsim_target ${ARG_NAME}_runner.${ARG_NAME}_runner)
    string(REGEX REPLACE ";" " " modelsim_flags "${modelsim_flags}")

    configure_file("${_HDL_CMAKE_ROOT_DIR}/ModelSim.tcl.in"
        "${CMAKE_BINARY_DIR}/run_modelsim.tcl")

    file(
        COPY
            "${CMAKE_BINARY_DIR}/run_modelsim.tcl"
        DESTINATION
            "${unit_test_dir}"
        FILE_PERMISSIONS
            OWNER_READ
            OWNER_WRITE
            OWNER_EXECUTE
            GROUP_READ
            GROUP_EXECUTE
            WORLD_READ
            WORLD_EXECUTE
    )
endfunction()

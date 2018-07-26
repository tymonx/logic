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

function(_cmake_test_hdl_compiler_execute result_var message_var output_dir)
    set(message "")
    set(command "")
    set(compiler_works FALSE)

    foreach (argument ${ARGN} COMMAND)
        if (argument STREQUAL COMMAND)
            if (NOT command)
                continue()
            endif()

            execute_process(
                COMMAND ${command}
                WORKING_DIRECTORY "${output_dir}"
                ERROR_VARIABLE error
                OUTPUT_VARIABLE output
                RESULT_VARIABLE result
                ERROR_STRIP_TRAILING_WHITESPACE
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )

            if (output)
                set(message "${message}\n${output}")
            endif()

            if (error)
                set(message "${message}\n${error}")
            endif()

            if (result EQUAL 0)
                set(compiler_works TRUE)
            else()
                set(compiler_works FALSE)
            endif()

            set(command "")

            if (NOT compiler_works)
                break()
            endif()
        else()
            list(APPEND command ${argument})
        endif()
    endforeach()

    if (message_var)
        set(${message_var} ${message} PARENT_SCOPE)
    endif()

    if (result_var)
        set(${result_var} ${compiler_works} PARENT_SCOPE)
    endif()
endfunction()

function(_cmake_test_hdl_compiler lang)
    if(CMAKE_${lang}_COMPILER_FORCED)
        # The compiler configuration was forced by the user.
        # Assume the user has configured all compiler information.
        set(CMAKE_${lang}_COMPILER_WORKS TRUE PARENT_SCOPE)
        return()
    endif()

    include(CMakeTestCompilerCommon)

    # Remove any cached result from an older CMake version.
    # We now store this in CMake${lang}Compiler.cmake.
    unset(CMAKE_${lang}_COMPILER_WORKS CACHE)

    set(compiler_message)

    # This file is used by EnableLanguage in cmGlobalGenerator to
    # determine that that selected ${lang} compiler can actually compile
    # and link the most basic of programs. If not, a fatal error
    # is set and cmake stops processing commands and will not generate
    # any makefiles or projects.
    if(NOT CMAKE_${lang}_COMPILER_WORKS)
        PrintTestCompilerStatus("${lang}" "")

        set(output_directory
            "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/${lang}")

        file(MAKE_DIRECTORY "${output_directory}")

        if (lang STREQUAL SystemVerilog)
            set(hdl_main main.sv)

            file(WRITE "${output_directory}/main.sv"
                "module main (\n"
                "    input aclk,\n"
                "    input areset_n,\n"
                "    input i,\n"
                "    output logic o\n"
                ");\n"
                "    initial begin: init\n"
                "        $display(\"CMake\");\n"
                "    end\n"
                "\n"
                "    always_ff @(posedge aclk or negedge areset_n) begin\n"
                "        if (!areset_n) begin\n"
                "            o <= '0;\n"
                "        end\n"
                "        else begin\n"
                "            o <= i;\n"
                "        end\n"
                "    end\n"
                "endmodule\n"
            )
        elseif (lang STREQUAL Verilog)
            set(hdl_main main.v)

            file(WRITE "${output_directory}/main.v"
                "module main (\n"
                "    input aclk,\n"
                "    input areset_n,\n"
                "    input i,\n"
                "    output reg o\n"
                ");\n"
                "    initial begin: init\n"
                "        $display(\"CMake\");\n"
                "    end\n"
                "\n"
                "    always @(posedge aclk or negedge areset_n) begin\n"
                "        if (!areset_n) begin\n"
                "            o <= 1'b0;\n"
                "        end\n"
                "        else begin\n"
                "            o <= i;\n"
                "        end\n"
                "    end\n"
                "endmodule\n"
            )
        elseif (lang STREQUAL VHDL)
            set(hdl_main main.vhd)

            file(WRITE "${output_directory}/main.vhd"
                "library ieee;\n"
                "use ieee.std_logic_1164.all;\n"
                "\n"
                "entity main is port (\n"
                "    aclk : in std_logic;\n"
                "    areset_n : in std_logic;\n"
                "    i : in std_logic;\n"
                "    o : out std_logic\n"
                ");\n"
                "end entity;\n"
                "\n"
                "architecture rtl of main is begin\n"
                "    process is begin\n"
                "        report \"CMake\";\n"
                "        wait;\n"
                "    end process;\n"
                "\n"
                "    process (aclk, areset_n) is begin\n"
                "        if (areset_n = '0') then\n"
                "            o <= '0';\n"
                "        elsif (rising_edge(aclk)) then\n"
                "            o <= i;\n"
                "        end if;\n"
                "    end process;\n"
                "end architecture;\n"
            )
        endif()

        set(commands "")

        # Verilator simulation tool
        if (CMAKE_${lang}_COMPILER_ID STREQUAL Verilator)
            file(WRITE "${output_directory}/main.cpp"
                "#include \"Vmain.h\"\n"
                "#include \"verilated.h\"\n"
                "\n"
                "int main(int argc, char* argv[]) {\n"
                "    Verilated::commandArgs(argc, argv);\n"
                "    Vmain top;\n"
                "    top.eval();\n"
                "}\n"
            )

            list(APPEND commands
                COMMAND
                    ${CMAKE_${lang}_COMPILER} -Wall --cc -Mdir output
                        -o main --exe main.cpp ${hdl_main}
                COMMAND
                    make -j -C output -f Vmain.mk
                COMMAND
                    ./output/main
            )

        # GHDL simulation tool
        elseif (CMAKE_${lang}_COMPILER_ID STREQUAL GHDL)
            list(APPEND commands
                COMMAND
                    ${CMAKE_${lang}_COMPILER} -a ${hdl_main}
                COMMAND
                    ${CMAKE_${lang}_COMPILER} -e main
                COMMAND
                    ${CMAKE_${lang}_COMPILER} -r main
            )

        # Icarus Verilog simulation tool
        elseif (CMAKE_${lang}_COMPILER_ID STREQUAL Icarus)
            get_filename_component(icarus_dir "${CMAKE_${lang}_COMPILER}"
                DIRECTORY)

            find_program(icarus_vvp NAMES vvp HINTS "${icarus_dir}"
                NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)

            list(APPEND commands COMMAND ${CMAKE_${lang}_COMPILER} -o main)

            if (lang STREQUAL SystemVerilog)
                list(APPEND commands -g2009)
            endif()

            list(APPEND commands ${hdl_main})

            list(APPEND commands COMMAND ${icarus_vvp} main)

        # Mentor Graphics ModelSim simulation tool
        elseif (CMAKE_${lang}_COMPILER_ID STREQUAL ModelSim)
            get_filename_component(modelsim_dir "${CMAKE_${lang}_COMPILER}"
                DIRECTORY)

            find_program(modelsim_vlib NAMES vlib HINTS "${modelsim_dir}"
                NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)

            find_program(modelsim_vmap NAMES vmap HINTS "${modelsim_dir}"
                NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)

            find_program(modelsim_vsim NAMES vsim HINTS "${modelsim_dir}"
                NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)

            file(WRITE "${output_directory}/main.do"
                "run 0\n"
                "quit\n"
            )

            if (NOT EXISTS "${output_directory}/work/_info")
                list(APPEND commands COMMAND ${modelsim_vlib} work)
            endif()

            if (NOT EXISTS "${output_directory}/modelsim.ini")
                list(APPEND commands COMMAND ${modelsim_vmap} work work)
            endif()

            list(APPEND commands COMMAND ${CMAKE_${lang}_COMPILER} -work work)

            if (lang STREQUAL SystemVerilog)
                list(APPEND commands -sv)
            endif()

            list(APPEND commands ${hdl_main})

            list(APPEND commands COMMAND ${modelsim_vsim} -c -do main.do
                work.main)

        # Intel Quartus Prime Lite/Standard/Pro synthesis tool
        elseif (CMAKE_${lang}_COMPILER_ID STREQUAL Quartus)
            file(WRITE "${output_directory}/main.qpf"
                "PROJECT_REVISION = \"main\"\n"
            )

            string(TOUPPER "${lang}_FILE" lang_file)

            file(WRITE "${output_directory}/main.qsf"
                "set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL\n"
                "set_global_assignment -name TOP_LEVEL_ENTITY main\n"
                "set_global_assignment -name ${lang_file} ${hdl_main}\n"
            )

            if (CMAKE_${lang}_COMPILER_VERSION_INTERNAL MATCHES Pro)
                list(APPEND commands
                    COMMAND
                        ${CMAKE_${lang}_COMPILER}_syn
                        --analysis_and_elaboration
                        main
                )
            else()
                list(APPEND commands
                    COMMAND
                        ${CMAKE_${lang}_COMPILER}_map
                        --analysis_and_elaboration
                        main
                )
            endif()

        # Xilinx Vivado synthesis tool
        elseif (CMAKE_${lang}_COMPILER_ID STREQUAL Vivado)
            file(WRITE "${output_directory}/main.tcl"
                "create_project main -force\n"
                "add_files {${hdl_main}}\n"
                "synth_design -name main -top main -rtl\n"
            )

            list(APPEND commands COMMAND
                ${CMAKE_${lang}_COMPILER} -mode batch -source main.tcl)
        endif()

        _cmake_test_hdl_compiler_execute(CMAKE_${lang}_COMPILER_WORKS
            compiler_message "${output_directory}" ${commands})

        # Move result from cache to normal variable.
        unset(CMAKE_${lang}_COMPILER_WORKS CACHE)
        set(${lang}_TEST_WAS_RUN TRUE)
    endif()

    if (NOT CMAKE_${lang}_COMPILER_WORKS)
        PrintTestCompilerStatus("${lang}" " -- broken")

        file(APPEND
            "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log"
            "Determining if the ${lang} compiler works failed with "
            "the following output:\n${compiler_message}\n\n")

        message(FATAL_ERROR
            "The ${lang} compiler \"${CMAKE_${lang}_COMPILER}\" "
            "is not able to compile a simple test program.\nIt fails "
            "with the following output:\n${compiler_message}\n\n"
            "CMake will not be able to correctly generate this project.")
    else()
        if (${lang}_TEST_WAS_RUN)
            PrintTestCompilerStatus("${lang}" " -- works")

            file(APPEND
                "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log"
                "Determining if the ${lang} compiler works passed with "
                "the following output:\n${compiler_message}\n\n")
        endif()

        # Re-configure to save learned information.
        configure_file("${CMAKE_CURRENT_LIST_DIR}/CMake${lang}Compiler.cmake.in"
            "${CMAKE_PLATFORM_INFO_DIR}/CMake${lang}Compiler.cmake"
            @ONLY
        )

        include("${CMAKE_PLATFORM_INFO_DIR}/CMake${lang}Compiler.cmake")
    endif()

    set(CMAKE_${lang}_COMPILER_WORKS "${CMAKE_${lang}_COMPILER_WORKS}"
        PARENT_SCOPE)
endfunction()

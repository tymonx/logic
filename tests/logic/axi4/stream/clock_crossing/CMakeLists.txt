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

# SVUnit unit test

add_hdl_unit_test(logic_axi4_stream_clock_crossing_unit_test.sv
    NAME
        logic_axi4_stream_clock_crossing_generic_unit_test
    DEPENDS
        logic_pkg
        logic_unit_test_pkg
        logic_axi4_stream_if
        logic_axi4_stream_clock_crossing
    PARAMETERS
        TARGET=logic_pkg::TARGET_GENERIC
)

if (QUARTUS_FOUND)
    add_hdl_unit_test(logic_axi4_stream_clock_crossing_unit_test.sv
        NAME
            logic_axi4_stream_clock_crossing_intel_unit_test
        DEPENDS
            logic_pkg
            logic_unit_test_pkg
            logic_axi4_stream_if
            logic_axi4_stream_clock_crossing
        PARAMETERS
            TARGET=logic_pkg::TARGET_INTEL
        MODELSIM_SUPPRESS
            3009
            3017
            3722
    )
endif()

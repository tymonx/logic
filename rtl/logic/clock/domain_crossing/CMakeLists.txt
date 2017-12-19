# Copyright 2017 Tymoteusz Blazejczyk
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

add_hdl_source(logic_clock_domain_crossing_generic_read.sv)
add_hdl_source(logic_clock_domain_crossing_generic_write.sv)
add_hdl_source(logic_clock_domain_crossing_generic_memory.sv)

add_hdl_source(logic_clock_domain_crossing_generic_read_sync.sv
    DEPENDS
        logic_basic_synchronizer
        logic_basic_gray2binary
        logic_basic_binary2gray
)

add_hdl_source(logic_clock_domain_crossing_generic_write_sync.sv
    DEPENDS
        logic_clock_domain_crossing_generic_read_sync
)

add_hdl_source(logic_clock_domain_crossing_generic.sv
    DEPENDS
        logic_reset_synchronizer
        logic_clock_domain_crossing_generic_memory
        logic_clock_domain_crossing_generic_read
        logic_clock_domain_crossing_generic_read_sync
        logic_clock_domain_crossing_generic_write
        logic_clock_domain_crossing_generic_write_sync
    ANALYSIS TRUE
)

add_hdl_source(logic_clock_domain_crossing_intel.sv
    DEPENDS
        altera_mf
)

add_hdl_source(logic_clock_domain_crossing.sv
    DEPENDS
        logic_clock_domain_crossing_intel
        logic_clock_domain_crossing_generic
    ANALYSIS TRUE
)

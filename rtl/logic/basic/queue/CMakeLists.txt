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

add_hdl_source(logic_basic_queue_generic_read.sv)
add_hdl_source(logic_basic_queue_generic_write.sv)
add_hdl_source(logic_basic_queue_generic_memory.sv)
add_hdl_source(logic_basic_queue_generic_capacity.sv)

add_hdl_source(logic_basic_queue_generic.sv
    DEPENDS
        logic_basic_queue_generic_read
        logic_basic_queue_generic_write
        logic_basic_queue_generic_memory
        logic_basic_queue_generic_capacity
    ANALYSIS TRUE
)

add_hdl_source(logic_basic_queue_intel.sv
    DEPENDS
        altera_mf
)

add_hdl_source(logic_basic_queue_main.sv
    DEPENDS
        logic_basic_queue_intel
        logic_basic_queue_generic
)

add_hdl_source(logic_basic_queue.sv
    DEPENDS
        logic_reset_synchronizer
        logic_basic_queue_main
    ANALYSIS TRUE
)

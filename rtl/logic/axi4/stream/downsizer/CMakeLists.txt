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

add_hdl_source(logic_axi4_stream_downsizer.sv
    SOURCES
        logic_axi4_stream_downsizer_unit.sv
        logic_axi4_stream_downsizer_main.sv
    DEPENDS
        logic_axi4_stream_if
        logic_axi4_stream_buffer
        logic_reset_synchronizer
    MODELSIM_SUPPRESS
        2583
)

add_hdl_source(logic_axi4_stream_downsizer_top.sv
    DEPENDS
        logic_axi4_stream_if
        logic_axi4_stream_downsizer
    ANALYSIS
        TRUE
)

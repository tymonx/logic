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

add_hdl_unit_test(logic_axi4_stream_resizer_unit_test.sv
    NAME
        logic_axi4_stream_resizer_equal_unit_test
    DEPENDS
        logic_pkg
        logic_unit_test_pkg
        logic_axi4_stream_if
        logic_axi4_stream_resizer
    PARAMETERS
        RX_TDATA_BYTES=4
        TX_TDATA_BYTES=4
)

add_hdl_unit_test(logic_axi4_stream_resizer_unit_test.sv
    NAME
        logic_axi4_stream_resizer_up_unit_test
    DEPENDS
        logic_pkg
        logic_unit_test_pkg
        logic_axi4_stream_if
        logic_axi4_stream_resizer
    PARAMETERS
        RX_TDATA_BYTES=4
        TX_TDATA_BYTES=12
)

add_hdl_unit_test(logic_axi4_stream_resizer_unit_test.sv
    NAME
        logic_axi4_stream_resizer_down_unit_test
    DEPENDS
        logic_pkg
        logic_unit_test_pkg
        logic_axi4_stream_if
        logic_axi4_stream_resizer
    PARAMETERS
        RX_TDATA_BYTES=12
        TX_TDATA_BYTES=4
)

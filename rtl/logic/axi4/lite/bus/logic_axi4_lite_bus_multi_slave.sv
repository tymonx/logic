/* Copyright 2018 Tymoteusz Blazejczyk
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`include "logic.svh"

/* Module: logic_axi4_lite_bus_multi_slave
 *
 * Multi-master multi-slave bus.
 *
 * Parameters:
 *  SLAVES          - Number of slaves connected to the AXI4-Lite bus.
 *  MASTERS         - Number of masters connected to the AXI4-Lite bus.
 *  DATA_BYTES      - Number of bytes for wdata and rdata signals.
 *  ADDRESS_WIDTH   - Number of bits for awaddr and araddr signals.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  slave       - AXI4-Lite slave interface.
 *  master      - AXI$-Lite master interface.
 */
module logic_axi4_lite_bus_multi_slave #(
    int SLAVES = 1,
    int SLAVES_WIDTH = (SLAVES >= 2) ? $clog2(SLAVES) : 1,
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1,
    logic_axi4_lite_bus_pkg::slave_t MAP[SLAVES]
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_lite_if, slave) slave,
    `LOGIC_MODPORT(logic_axi4_lite_if, master) master[SLAVES]
);
    logic_axi4_stream_if #(
        .TDATA_BYTES(0),
        .TDEST_WIDTH(ADDRESS_WIDTH),
        .TUSER_WIDTH($bits(logic_axi4_lite_pkg::access_t)),
        .TID_WIDTH(SLAVES_WIDTH),
        .USE_TKEEP(0),
        .USE_TSTRB(0),
        .USE_TLAST(0)
    ) write_address [2] (
        .aclk(aclk),
        .areset_n(areset_n),
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(DATA_BYTES),
        .TDEST_WIDTH(0),
        .TUSER_WIDTH(0),
        .TID_WIDTH(SLAVES_WIDTH),
        .USE_TKEEP(1),
        .USE_TSTRB(0),
        .USE_TLAST(0)
    ) write_data (.*);

    logic_axi4_stream_if #(
        .TDATA_BYTES(0),
        .TDEST_WIDTH(0),
        .TUSER_WIDTH($bits(logic_axi4_lite_pkg::response_t)),
        .TID_WIDTH(0),
        .USE_TKEEP(0),
        .USE_TSTRB(0),
        .USE_TLAST(0)
    ) write_response (.*);

    logic_axi4_stream_if #(
        .TDATA_BYTES(0),
        .TDEST_WIDTH(ADDRESS_WIDTH),
        .TUSER_WIDTH($bits(logic_axi4_lite_pkg::access_t)),
        .TID_WIDTH(SLAVES_WIDTH),
        .USE_TKEEP(0),
        .USE_TSTRB(0),
        .USE_TLAST(0)
    ) read_address [2] (
        .aclk(aclk),
        .areset_n(areset_n),
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(DATA_BYTES),
        .TDEST_WIDTH(0),
        .TUSER_WIDTH($bits(logic_axi4_lite_pkg::response_t)),
        .TID_WIDTH(0),
        .USE_TKEEP(0),
        .USE_TSTRB(0),
        .USE_TLAST(0)
    ) read_data (.*);

    logic_axi4_lite_bus_to_stream
    slave_to_stream (
        .slave(slave),
        .write_address(write_address[0]),
        .write_data(write_data),
        .write_response(write_response),
        .read_address(read_address[0]),
        .read_data(read_data),
        .*
    );

    logic_axi4_lite_bus_decoder #(
        .SLAVES(SLAVES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .MAP(MAP)
    )
    write_address_decoder (
        .rx(write_address[0]),
        .tx(write_address[1]),
        .*
    );

    logic_axi4_lite_bus_decoder #(
        .SLAVES(SLAVES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .MAP(MAP)
    )
    read_address_decoder (
        .rx(read_address[0]),
        .tx(read_address[1]),
        .*
    );
endmodule

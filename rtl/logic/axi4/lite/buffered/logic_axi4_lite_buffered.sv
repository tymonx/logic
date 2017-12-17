/* Copyright 2017 Tymoteusz Blazejczyk
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

/* Module: logic_axi4_lite_buffered
 *
 * Improve timings between modules by adding register to ready signal path from
 * tx to rx ports and it keeps zero latency bus transcation on both sides.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  slave       - AXI4-Lite slave interface.
 *  master      - AXI$-Lite master interface.
 */
module logic_axi4_lite_buffered #(
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_lite_if, slave) slave,
    `LOGIC_MODPORT(logic_axi4_lite_if, master) master
);
    logic_axi4_lite_buffered_basic #(
        .WIDTH(ADDRESS_WIDTH + $bits(logic_axi4_lite_pkg::access_t))
    )
    write_address_channel (
        /* Slave */
        .slave_valid(slave.awvalid),
        .slave_ready(slave.awready),
        .slave_data({slave.awprot, slave.awaddr}),
        /* Master */
        .master_valid(master.awvalid),
        .master_ready(master.awready),
        .master_data({master.awprot, master.awaddr}),
        .*
    );

    logic_axi4_lite_buffered_basic #(
        .WIDTH(DATA_BYTES * 8 + DATA_BYTES)
    )
    write_data_channel (
        /* Slave */
        .slave_valid(slave.wvalid),
        .slave_ready(slave.wready),
        .slave_data({slave.wstrb, slave.wdata}),
        /* Master */
        .master_valid(master.wvalid),
        .master_ready(master.wready),
        .master_data({master.wstrb, master.wdata}),
        .*
    );

    logic_axi4_lite_buffered_basic #(
        .WIDTH($bits(logic_axi4_lite_pkg::response_t))
    )
    write_response_channel (
        /* Slave */
        .slave_valid(master.bvalid),
        .slave_ready(master.bready),
        .slave_data(master.bresp),
        /* Master */
        .master_valid(slave.bvalid),
        .master_ready(slave.bready),
        .master_data({slave.bresp}),
        .*
    );

    logic_axi4_lite_buffered_basic #(
        .WIDTH(ADDRESS_WIDTH + $bits(logic_axi4_lite_pkg::access_t))
    )
    read_address_channel (
        /* Slave */
        .slave_valid(slave.arvalid),
        .slave_ready(slave.arready),
        .slave_data({slave.arprot, slave.araddr}),
        /* Master */
        .master_valid(master.arvalid),
        .master_ready(master.arready),
        .master_data({master.arprot, master.araddr}),
        .*
    );

    logic_axi4_lite_buffered_basic #(
        .WIDTH(DATA_BYTES * 8 + $bits(logic_axi4_lite_pkg::response_t))
    )
    read_data_channel (
        /* Slave */
        .slave_valid(master.rvalid),
        .slave_ready(master.rready),
        .slave_data({master.rresp, master.rdata}),
        /* Master */
        .master_valid(slave.rvalid),
        .master_ready(slave.rready),
        .master_data({slave.rresp, slave.rdata}),
        .*
    );
endmodule

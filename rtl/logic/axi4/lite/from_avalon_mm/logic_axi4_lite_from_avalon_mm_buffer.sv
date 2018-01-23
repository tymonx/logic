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

/* Module: logic_axi4_lite_from_avalon_mm_buffer
 *
 * Avalon-MM buffer module.
 *
 * Parameters:
 *  DATA_BYTES      - Number of bytes for writedata and readdata signals.
 *  ADDRESS_WIDTH   - Number of bits for address signal.
 *
 * Ports:
 *  aclk            - Clock.
 *  areset_n        - Asynchronous active-low reset.
 *  slave           - Avalon-MM interface.
 *  master          - Avalon-MM interface.
 */
module logic_axi4_lite_from_avalon_mm_buffer #(
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_avalon_mm_if, slave) slave,
    `LOGIC_MODPORT(logic_avalon_mm_if, master) master
);
    localparam DATA_WIDTH = 8 * DATA_BYTES;
    localparam BYTEENABLE_WIDTH = DATA_BYTES;

    localparam WIDTH = 2 + ADDRESS_WIDTH + BYTEENABLE_WIDTH + DATA_WIDTH;

    logic rx_tvalid;
    logic [WIDTH-1:0] rx_tdata;

    logic tx_tvalid;
    logic [WIDTH-1:0] tx_tdata;

    logic master_write;
    logic master_read;

    always_comb rx_tvalid = slave.write || slave.read;

    always_comb rx_tdata = {slave.write, slave.read, slave.address,
        slave.byteenable, slave.writedata};

    always_comb {master_write, master_read, master.address,
        master.byteenable, master.writedata} = tx_tdata;

    always_comb master.write = tx_tvalid && master_write;
    always_comb master.read = tx_tvalid && master_read;

    always_comb slave.response = master.response;
    always_comb slave.readdata = master.readdata;
    always_comb slave.readdatavalid = master.readdatavalid;
    always_comb slave.writeresponsevalid = master.writeresponsevalid;

    logic_basic_buffer #(
        .WIDTH(WIDTH)
    )
    buffer_service (
        .rx_tready(slave.waitrequest) ,
        .tx_tready(master.waitrequest),
        .*
    );
endmodule

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

/* Module: logic_axi4_lite_clock_crossing
 *
 * Clock domain crossing module between slave_aclk and master_aclk.
 *
 * Parameters:
 *  DATA_BYTES      - Number of bytes for wdata and rdata signals.
 *  ADDRESS_WIDTH   - Number of bits for awaddr and araddr signals.
 *  CAPACITY        - Number of single data transactions that can be store in
 *                    internal queue memory (FIFO capacity).
 *  TARGET          - Target implementation.
 *
 * Ports:
 *  areset_n    - Asynchronous active-low reset.
 *  slave_aclk  - Clock for AXI4-Lite slave interface.
 *  master_aclk - Clock for AXI4-Lite master interface.
 *  slave       - AXI4-Lite slave interface.
 *  master      - AXI4-Lite master interface.
 */
module logic_axi4_lite_clock_crossing #(
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1,
    int CAPACITY = 256,
    logic_pkg::target_t TARGET = `LOGIC_CONFIG_TARGET
) (
    input areset_n,
    input slave_aclk,
    input master_aclk,
    `LOGIC_MODPORT(logic_axi4_lite_if, slave) slave,
    `LOGIC_MODPORT(logic_axi4_lite_if, master) master
);
    localparam STRB_WIDTH = DATA_BYTES;
    localparam DATA_WIDTH = 8 * DATA_BYTES;
    localparam PROT_WIDTH = $bits(logic_axi4_lite_pkg::access_t);
    localparam RESP_WIDTH = $bits(logic_axi4_lite_pkg::response_t);

    logic rx_aclk;
    logic tx_aclk;

    always_comb rx_aclk = slave_aclk;
    always_comb tx_aclk = master_aclk;

    logic_clock_domain_crossing #(
        .WIDTH(PROT_WIDTH + ADDRESS_WIDTH),
        .CAPACITY(CAPACITY),
        .TARGET(TARGET)
    )
    write_address_channel (
        /* Slave */
        .rx_tvalid(slave.awvalid),
        .rx_tready(slave.awready),
        .rx_tdata({slave.awprot, slave.awaddr}),
        /* Master */
        .tx_tvalid(master.awvalid),
        .tx_tready(master.awready),
        .tx_tdata({master.awprot, master.awaddr}),
        .*
    );

    logic_clock_domain_crossing #(
        .WIDTH(STRB_WIDTH + DATA_WIDTH),
        .CAPACITY(CAPACITY),
        .TARGET(TARGET)
    )
    write_data_channel (
        /* Slave */
        .rx_tvalid(slave.wvalid),
        .rx_tready(slave.wready),
        .rx_tdata({slave.wstrb, slave.wdata}),
        /* Master */
        .tx_tvalid(master.wvalid),
        .tx_tready(master.wready),
        .tx_tdata({master.wstrb, master.wdata}),
        .*
    );

    logic_clock_domain_crossing #(
        .WIDTH(RESP_WIDTH),
        .CAPACITY(CAPACITY),
        .TARGET(TARGET)
    )
    write_response_channel (
        /* Slave */
        .rx_tvalid(master.bvalid),
        .rx_tready(master.bready),
        .rx_tdata(master.bresp),
        /* Master */
        .tx_tvalid(slave.bvalid),
        .tx_tready(slave.bready),
        .tx_tdata({slave.bresp}),
        .*
    );

    logic_clock_domain_crossing #(
        .WIDTH(PROT_WIDTH + ADDRESS_WIDTH),
        .CAPACITY(CAPACITY),
        .TARGET(TARGET)
    )
    read_address_channel (
        /* Slave */
        .rx_tvalid(slave.arvalid),
        .rx_tready(slave.arready),
        .rx_tdata({slave.arprot, slave.araddr}),
        /* Master */
        .tx_tvalid(master.arvalid),
        .tx_tready(master.arready),
        .tx_tdata({master.arprot, master.araddr}),
        .*
    );

    logic_clock_domain_crossing #(
        .WIDTH(RESP_WIDTH + DATA_WIDTH),
        .CAPACITY(CAPACITY),
        .TARGET(TARGET)
    )
    read_data_channel (
        /* Slave */
        .rx_tvalid(master.rvalid),
        .rx_tready(master.rready),
        .rx_tdata({master.rresp, master.rdata}),
        /* Master */
        .tx_tvalid(slave.rvalid),
        .tx_tready(slave.rready),
        .tx_tdata({slave.rresp, slave.rdata}),
        .*
    );
endmodule

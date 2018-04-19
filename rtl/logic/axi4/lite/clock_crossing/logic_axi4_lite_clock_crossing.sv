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

/* Module: logic_axi4_lite_clock_crossing
 *
 * Clock domain crossing module between slave_aclk and master_aclk.
 *
 * Parameters:
 *  DATA_BYTES      - Number of bytes for wdata and rdata signals.
 *  ADDRESS_WIDTH   - Number of bits for awaddr and araddr signals.
 *  CAPACITY        - Number of single data transactions that can be store in
 *                    internal queue memory (FIFO capacity).
 *  GENERIC         - Enable or disable generic implementation.
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
    logic_pkg::target_t TARGET = logic_pkg::TARGET_GENERIC,
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1,
    int CAPACITY = 256,
    int GENERIC = 1
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

    typedef logic [ADDRESS_WIDTH-1:0] araddr_t;
    typedef logic [ADDRESS_WIDTH-1:0] awaddr_t;
    typedef logic [DATA_BYTES-1:0][7:0] wdata_t;
    typedef logic [DATA_BYTES-1:0][7:0] rdata_t;
    typedef logic [DATA_BYTES-1:0] wstrb_t;
    typedef logic_axi4_lite_pkg::response_t rresp_t;
    typedef logic_axi4_lite_pkg::response_t bresp_t;
    typedef logic_axi4_lite_pkg::access_t awprot_t;
    typedef logic_axi4_lite_pkg::access_t arprot_t;

    /* Write address channel */
    logic slave_awvalid;
    logic slave_awready;
    awaddr_t slave_awaddr;
    awprot_t slave_awprot;

    /* Write data channel */
    logic slave_wvalid;
    logic slave_wready;
    wdata_t slave_wdata;
    wstrb_t slave_wstrb;

    /* Write response channel */
    logic slave_bvalid;
    logic slave_bready;
    bresp_t slave_bresp;

    /* Read address channel */
    logic slave_arvalid;
    logic slave_arready;
    araddr_t slave_araddr;
    arprot_t slave_arprot;

    /* Read data channel */
    logic slave_rvalid;
    logic slave_rready;
    rdata_t slave_rdata;
    rresp_t slave_rresp;

    /* Write address channel */
    logic master_awvalid;
    logic master_awready;
    awaddr_t master_awaddr;
    awprot_t master_awprot;

    /* Write data channel */
    logic master_wvalid;
    logic master_wready;
    wdata_t master_wdata;
    wstrb_t master_wstrb;

    /* Write response channel */
    logic master_bvalid;
    logic master_bready;
    bresp_t master_bresp;

    /* Read address channel */
    logic master_arvalid;
    logic master_arready;
    araddr_t master_araddr;
    arprot_t master_arprot;

    /* Read data channel */
    logic master_rvalid;
    logic master_rready;
    rdata_t master_rdata;
    rresp_t master_rresp;

    `LOGIC_AXI4_LITE_IF_MASTER_ASSIGN(slave, slave);

    logic_clock_domain_crossing #(
        .WIDTH(PROT_WIDTH + ADDRESS_WIDTH),
        .CAPACITY(CAPACITY),
        .GENERIC(GENERIC),
        .TARGET(TARGET)
    )
    write_address_channel (
        /* Slave */
        .rx_aclk(slave_aclk),
        .rx_tvalid(slave_awvalid),
        .rx_tready(slave_awready),
        .rx_tdata({slave_awprot, slave_awaddr}),
        /* Master */
        .tx_aclk(master_aclk),
        .tx_tvalid(master_awvalid),
        .tx_tready(master_awready),
        .tx_tdata({master_awprot, master_awaddr}),
        .*
    );

    logic_clock_domain_crossing #(
        .WIDTH(STRB_WIDTH + DATA_WIDTH),
        .CAPACITY(CAPACITY),
        .GENERIC(GENERIC),
        .TARGET(TARGET)
    )
    write_data_channel (
        /* Slave */
        .rx_aclk(slave_aclk),
        .rx_tvalid(slave_wvalid),
        .rx_tready(slave_wready),
        .rx_tdata({slave_wstrb, slave_wdata}),
        /* Master */
        .tx_aclk(master_aclk),
        .tx_tvalid(master_wvalid),
        .tx_tready(master_wready),
        .tx_tdata({master_wstrb, master_wdata}),
        .*
    );

    logic_clock_domain_crossing #(
        .WIDTH(RESP_WIDTH),
        .CAPACITY(CAPACITY),
        .GENERIC(GENERIC),
        .TARGET(TARGET)
    )
    write_response_channel (
        /* Slave */
        .rx_aclk(master_aclk),
        .rx_tvalid(master_bvalid),
        .rx_tready(master_bready),
        .rx_tdata(master_bresp),
        /* Master */
        .tx_aclk(slave_aclk),
        .tx_tvalid(slave_bvalid),
        .tx_tready(slave_bready),
        .tx_tdata({slave_bresp}),
        .*
    );

    logic_clock_domain_crossing #(
        .WIDTH(PROT_WIDTH + ADDRESS_WIDTH),
        .CAPACITY(CAPACITY),
        .GENERIC(GENERIC),
        .TARGET(TARGET)
    )
    read_address_channel (
        /* Slave */
        .rx_aclk(slave_aclk),
        .rx_tvalid(slave_arvalid),
        .rx_tready(slave_arready),
        .rx_tdata({slave_arprot, slave_araddr}),
        /* Master */
        .tx_aclk(master_aclk),
        .tx_tvalid(master_arvalid),
        .tx_tready(master_arready),
        .tx_tdata({master_arprot, master_araddr}),
        .*
    );

    logic_clock_domain_crossing #(
        .WIDTH(RESP_WIDTH + DATA_WIDTH),
        .CAPACITY(CAPACITY),
        .GENERIC(GENERIC),
        .TARGET(TARGET)
    )
    read_data_channel (
        /* Slave */
        .rx_aclk(master_aclk),
        .rx_tvalid(master_rvalid),
        .rx_tready(master_rready),
        .rx_tdata({master_rresp, master_rdata}),
        /* Master */
        .tx_aclk(slave_aclk),
        .tx_tvalid(slave_rvalid),
        .tx_tready(slave_rready),
        .tx_tdata({slave_rresp, slave_rdata}),
        .*
    );

    `LOGIC_AXI4_LITE_IF_SLAVE_ASSIGN(master, master);
endmodule

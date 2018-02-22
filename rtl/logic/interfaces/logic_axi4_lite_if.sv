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

/* Interface: logic_axi4_lite_if
 *
 * AXI4-Lite interface.
 *
 * Parameters:
 *  DATA_BYTES      - Number of bytes for wdata and rdata signals.
 *  ADDRESS_WIDTH   - Number of bits for awaddr and araddr signals.
 *
 * Ports:
 *  aclk        - Clock. Used only for internal checkers and assertions
 *  areset_n    - Asynchronous active-low reset. Used only for internal checkers
 *                and assertions
 */
interface logic_axi4_lite_if #(
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1,
    int AWADDR_WIDTH = ADDRESS_WIDTH,
    int ARADDR_WIDTH = ADDRESS_WIDTH
) (
    input aclk,
    input areset_n
);
    initial begin: design_rule_checks
        `LOGIC_DRC_POWER_OF_2(DATA_BYTES)
        `LOGIC_DRC_RANGE(DATA_BYTES, 4, 8)
    end

    typedef logic [ARADDR_WIDTH-1:0] araddr_t;
    typedef logic [AWADDR_WIDTH-1:0] awaddr_t;
    typedef logic [DATA_BYTES-1:0][7:0] wdata_t;
    typedef logic [DATA_BYTES-1:0][7:0] rdata_t;
    typedef logic [DATA_BYTES-1:0] wstrb_t;
    typedef logic_axi4_lite_pkg::response_t rresp_t;
    typedef logic_axi4_lite_pkg::response_t bresp_t;
    typedef logic_axi4_lite_pkg::access_t awprot_t;
    typedef logic_axi4_lite_pkg::access_t arprot_t;

    /* Write address channel */
    logic awvalid;
    logic awready;
    awaddr_t awaddr;
    awprot_t awprot;

    /* Write data channel */
    logic wvalid;
    logic wready;
    wdata_t wdata;
    wstrb_t wstrb;

    /* Write response channel */
    logic bvalid;
    logic bready;
    bresp_t bresp;

    /* Read address channel */
    logic arvalid;
    logic arready;
    araddr_t araddr;
    arprot_t arprot;

    /* Read data channel */
    logic rvalid;
    logic rready;
    rdata_t rdata;
    rresp_t rresp;

`ifndef LOGIC_MODPORT_DISABLED
    modport slave (
        /* Write address channel */
        input awvalid,
        output awready,
        input awaddr,
        input awprot,
        /* Write data channel */
        input wvalid,
        output wready,
        input wdata,
        input wstrb,
        /* Write response channel */
        output bvalid,
        input bready,
        output bresp,
        /* Read address channel */
        input arvalid,
        output arready,
        input araddr,
        input arprot,
        /* Read data channel */
        output rvalid,
        input rready,
        output rdata,
        output rresp
    );

    modport master (
        /* Write address channel */
        output awvalid,
        input awready,
        output awaddr,
        output awprot,
        /* Write data channel */
        output wvalid,
        input wready,
        output wdata,
        output wstrb,
        /* Write response channel */
        input bvalid,
        output bready,
        input bresp,
        /* Read address channel */
        output arvalid,
        input arready,
        output araddr,
        output arprot,
        /* Read data channel */
        input rvalid,
        output rready,
        input rdata,
        input rresp
    );

    modport monitor (
        /* Write address channel */
        input awvalid,
        input awready,
        input awaddr,
        input awprot,
        /* Write data channel */
        input wvalid,
        input wready,
        input wdata,
        input wstrb,
        /* Write response channel */
        input bvalid,
        input bready,
        input bresp,
        /* Read address channel */
        input arvalid,
        input arready,
        input araddr,
        input arprot,
        /* Read data channel */
        input rvalid,
        input rready,
        input rdata,
        input rresp
    );
`endif

`ifndef SYNTHESIS
    clocking cb_slave @(posedge aclk);
        /* Write address channel */
        output awvalid;
        input awready;
        output awaddr;
        output awprot;
        /* Write data channel */
        output wvalid;
        input wready;
        output wdata;
        output wstrb;
        /* Write response channel */
        input bvalid;
        output bready;
        input bresp;
        /* Read address channel */
        output arvalid;
        input arready;
        output araddr;
        output arprot;
        /* Read data channel */
        input rvalid;
        output rready;
        input rdata;
        input rresp;
    endclocking

    clocking cb_master @(posedge aclk);
        /* Write address channel */
        input awvalid;
        output awready;
        input awaddr;
        input awprot;
        /* Write data channel */
        input wvalid;
        output wready;
        input wdata;
        input wstrb;
        /* Write response channel */
        output bvalid;
        input bready;
        output bresp;
        /* Read address channel */
        input arvalid;
        output arready;
        input araddr;
        input arprot;
        /* Read data channel */
        output rvalid;
        input rready;
        output rdata;
        output rresp;
    endclocking

    clocking cb_monitor @(posedge aclk);
        /* Write address channel */
        input awvalid;
        input awready;
        input awaddr;
        input awprot;
        /* Write data channel */
        input wvalid;
        input wready;
        input wdata;
        input wstrb;
        /* Write response channel */
        input bvalid;
        input bready;
        input bresp;
        /* Read address channel */
        input arvalid;
        input arready;
        input araddr;
        input arprot;
        /* Read data channel */
        input rvalid;
        input rready;
        input rdata;
        input rresp;
    endclocking
`endif

`ifdef VERILATOR
    logic _unused_ports = &{1'b0, aclk, areset_n, 1'b0};
`endif

endinterface

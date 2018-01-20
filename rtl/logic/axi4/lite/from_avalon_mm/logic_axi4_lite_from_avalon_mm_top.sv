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

module logic_axi4_lite_from_avalon_mm_top #(
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1
) (
    input aclk,
    input areset_n,
    /* Slave */
    input slave_read,
    input slave_write,
    input [ADDRESS_WIDTH-1:0] slave_address,
    input [DATA_BYTES-1:0][7:0] slave_writedata,
    input [DATA_BYTES-1:0] slave_byteenable,
    output logic_avalon_mm_pkg::response_t slave_response,
    output logic [DATA_BYTES-1:0][7:0] slave_readdata,
    output logic slave_waitrequest,
    output logic slave_readdatavalid,
    output logic slave_writeresponsevalid,
    /* Master - write address channel */
    output logic master_awvalid,
    output logic [ADDRESS_WIDTH-1:0] master_awaddr,
    output logic_axi4_lite_pkg::access_t master_awprot,
    input master_awready,
    /* Master - write data channel */
    output logic master_wvalid,
    output logic [DATA_BYTES-1:0][7:0] master_wdata,
    output logic [DATA_BYTES-1:0] master_wstrb,
    input master_wready,
    /* Master - write response channel */
    input master_bvalid,
    input logic_axi4_lite_pkg::response_t master_bresp,
    output logic master_bready,
    /* Master - read address channel */
    output logic master_arvalid,
    output logic [ADDRESS_WIDTH-1:0] master_araddr,
    output logic_axi4_lite_pkg::access_t master_arprot,
    input master_arready,
    /* Master - read data channel */
    output logic master_rready,
    input master_rvalid,
    input [DATA_BYTES-1:0][7:0] master_rdata,
    input logic_axi4_lite_pkg::response_t master_rresp
);
    logic_avalon_mm_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) slave (
        .clk(aclk),
        .reset_n(areset_n)
    );

    logic_axi4_lite_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) master (.*);

    `LOGIC_AVALON_MM_IF_SLAVE_ASSIGN(slave, slave);

    logic_axi4_lite_from_avalon_mm #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) unit (.*);

    `LOGIC_AXI4_LITE_IF_MASTER_ASSIGN(master, master);
endmodule

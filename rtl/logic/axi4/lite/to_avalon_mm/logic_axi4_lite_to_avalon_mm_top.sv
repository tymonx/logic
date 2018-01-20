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

module logic_axi4_lite_to_avalon_mm_top #(
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1
) (
    input aclk,
    input areset_n,
    /* Slave - write address channel */
    input slave_awvalid,
    input [ADDRESS_WIDTH-1:0] slave_awaddr,
    input logic_axi4_lite_pkg::access_t slave_awprot,
    output logic slave_awready,
    /* Slave - write data channel */
    input slave_wvalid,
    input [DATA_BYTES-1:0][7:0] slave_wdata,
    input [DATA_BYTES-1:0] slave_wstrb,
    output logic slave_wready,
    /* Slave - write response channel */
    input slave_bready,
    output logic slave_bvalid,
    output logic_axi4_lite_pkg::response_t slave_bresp,
    /* Slave - read address channel */
    input slave_arvalid,
    input [ADDRESS_WIDTH-1:0] slave_araddr,
    input logic_axi4_lite_pkg::access_t slave_arprot,
    output logic slave_arready,
    /* Slave - read data channel */
    input slave_rready,
    output logic slave_rvalid,
    output logic [DATA_BYTES-1:0][7:0] slave_rdata,
    output logic_axi4_lite_pkg::response_t slave_rresp,
    /* Master */
    output logic master_read,
    output logic master_write,
    output logic [ADDRESS_WIDTH-1:0] master_address,
    output logic [DATA_BYTES-1:0][7:0] master_writedata,
    output logic [DATA_BYTES-1:0] master_byteenable,
    input logic_avalon_mm_pkg::response_t master_response,
    input [DATA_BYTES-1:0][7:0] master_readdata,
    input master_waitrequest,
    input master_readdatavalid,
    input master_writeresponsevalid
);
    logic_axi4_lite_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) slave (.*);

    logic_avalon_mm_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) master (
        .clk(aclk),
        .reset_n(areset_n)
    );

    `LOGIC_AXI4_LITE_IF_SLAVE_ASSIGN(slave, slave);

    logic_axi4_lite_to_avalon_mm #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) unit (.*);

    `LOGIC_AVALON_MM_IF_MASTER_ASSIGN(master, master);
endmodule

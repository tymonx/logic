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

module logic_axi4_lite_clock_crossing_top #(
    logic_pkg::target_t TARGET = logic_pkg::TARGET_GENERIC,
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1,
    int CAPACITY = 256,
    int GENERIC = 1
) (
    input areset_n,
    input slave_aclk,
    input master_aclk,
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
    logic_axi4_lite_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) slave (
        .aclk(slave_aclk),
        .*
    );

    logic_axi4_lite_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) master (
        .aclk(master_aclk),
        .*
    );

    `LOGIC_AXI4_LITE_IF_SLAVE_ASSIGN(slave, slave);

    logic_axi4_lite_clock_crossing #(
        .TARGET(TARGET),
        .GENERIC(GENERIC),
        .CAPACITY(CAPACITY),
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) unit (.*);

    `LOGIC_AXI4_LITE_IF_MASTER_ASSIGN(master, master);
endmodule

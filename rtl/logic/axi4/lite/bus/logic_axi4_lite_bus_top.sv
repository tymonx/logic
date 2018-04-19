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

module logic_axi4_lite_bus_top #(
    int SLAVES = 2,
    int MASTERS = 1,
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 10,
    logic_axi4_lite_bus_pkg::slave_t [SLAVES-1:0] MAP = {
        {SLAVES{64'h1000, 64'h0000}}
    }
) (
    input aclk,
    input areset_n,
    /* Slave - write address channel */
    input [MASTERS-1:0] slave_awvalid,
    input [MASTERS-1:0][ADDRESS_WIDTH-1:0] slave_awaddr,
    input logic_axi4_lite_pkg::access_t [MASTERS-1:0] slave_awprot,
    output logic [MASTERS-1:0] slave_awready,
    /* Slave - write data channel */
    input [MASTERS-1:0] slave_wvalid,
    input [MASTERS-1:0][DATA_BYTES-1:0][7:0] slave_wdata,
    input [MASTERS-1:0][DATA_BYTES-1:0] slave_wstrb,
    output logic [MASTERS-1:0] slave_wready,
    /* Slave - write response channel */
    input [MASTERS-1:0] slave_bready,
    output logic [MASTERS-1:0] slave_bvalid,
    output logic_axi4_lite_pkg::response_t [MASTERS-1:0] slave_bresp,
    /* Slave - read address channel */
    input [MASTERS-1:0] slave_arvalid,
    input [MASTERS-1:0][ADDRESS_WIDTH-1:0] slave_araddr,
    input logic_axi4_lite_pkg::access_t [MASTERS-1:0] slave_arprot,
    output logic [MASTERS-1:0] slave_arready,
    /* Slave - read data channel */
    input [MASTERS-1:0] slave_rready,
    output logic [MASTERS-1:0] slave_rvalid,
    output logic [MASTERS-1:0][DATA_BYTES-1:0][7:0] slave_rdata,
    output logic_axi4_lite_pkg::response_t [MASTERS-1:0] slave_rresp,
    /* Master - write address channel */
    output logic [SLAVES-1:0] master_awvalid,
    output logic [SLAVES-1:0][ADDRESS_WIDTH-1:0] master_awaddr,
    output logic_axi4_lite_pkg::access_t [SLAVES-1:0] master_awprot,
    input [SLAVES-1:0] master_awready,
    /* Master - write data channel */
    output logic [SLAVES-1:0] master_wvalid,
    output logic [SLAVES-1:0][DATA_BYTES-1:0][7:0] master_wdata,
    output logic [SLAVES-1:0][DATA_BYTES-1:0] master_wstrb,
    input [SLAVES-1:0] master_wready,
    /* Master - write response channel */
    input [SLAVES-1:0] master_bvalid,
    input logic_axi4_lite_pkg::response_t [SLAVES-1:0] master_bresp,
    output logic [SLAVES-1:0] master_bready,
    /* Master - read address channel */
    output logic [SLAVES-1:0] master_arvalid,
    output logic [SLAVES-1:0][ADDRESS_WIDTH-1:0] master_araddr,
    output logic_axi4_lite_pkg::access_t [SLAVES-1:0] master_arprot,
    input [SLAVES-1:0] master_arready,
    /* Master - read data channel */
    output logic [SLAVES-1:0] master_rready,
    input [SLAVES-1:0] master_rvalid,
    input [SLAVES-1:0][DATA_BYTES-1:0][7:0] master_rdata,
    input logic_axi4_lite_pkg::response_t [SLAVES-1:0] master_rresp
);
    genvar k;

    logic_axi4_lite_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) slave [MASTERS] (
        .aclk(aclk),
        .areset_n(areset_n)
    );

    logic_axi4_lite_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) master [SLAVES] (
        .aclk(aclk),
        .areset_n(areset_n)
    );

    generate
        for (k = 0; k < MASTERS; ++k) begin: slaves
            `LOGIC_AXI4_LITE_IF_SLAVE_ASSIGN_ARRAY(slave[k], slave, k);
        end

        for (k = 0; k < SLAVES; ++k) begin: masters
            `LOGIC_AXI4_LITE_IF_MASTER_ASSIGN_ARRAY(master, k, master[k]);
        end
    endgenerate

    logic_axi4_lite_bus #(
        .SLAVES(SLAVES),
        .MASTERS(MASTERS),
        .MAP(MAP),
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) unit (.*);
endmodule

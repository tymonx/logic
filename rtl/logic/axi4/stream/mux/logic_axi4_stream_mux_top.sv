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

module logic_axi4_stream_mux_top #(
    int INPUTS = 4,
    int TDATA_BYTES = 4,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1
) (
    input aclk,
    input areset_n,
    /* Rx */
    input [INPUTS-1:0] rx_tlast,
    input [INPUTS-1:0] rx_tvalid,
    input [INPUTS-1:0][TDATA_BYTES-1:0][7:0] rx_tdata,
    input [INPUTS-1:0][TDATA_BYTES-1:0] rx_tstrb,
    input [INPUTS-1:0][TDATA_BYTES-1:0] rx_tkeep,
    input [INPUTS-1:0][TDEST_WIDTH-1:0] rx_tdest,
    input [INPUTS-1:0][TUSER_WIDTH-1:0] rx_tuser,
    input [INPUTS-1:0][TID_WIDTH-1:0] rx_tid,
    output logic [INPUTS-1:0] rx_tready,
    /* Tx */
    output logic tx_tlast,
    output logic tx_tvalid,
    output logic [TDATA_BYTES-1:0][7:0] tx_tdata,
    output logic [TDATA_BYTES-1:0] tx_tstrb,
    output logic [TDATA_BYTES-1:0] tx_tkeep,
    output logic [TDEST_WIDTH-1:0] tx_tdest,
    output logic [TUSER_WIDTH-1:0] tx_tuser,
    output logic [TID_WIDTH-1:0] tx_tid,
    input tx_tready
);
    genvar k;

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    ) rx [INPUTS] (
        .aclk(aclk),
        .areset_n(areset_n)
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    ) tx (.*);

    generate
        for (k = 0; k < INPUTS; ++k) begin: inputs
            always_comb rx[k].tvalid = rx_tvalid[k];
            always_comb rx[k].tlast = rx_tlast[k];
            always_comb rx[k].tdata = rx_tdata[k];
            always_comb rx[k].tstrb = rx_tstrb[k];
            always_comb rx[k].tkeep = rx_tkeep[k];
            always_comb rx[k].tdest = rx_tdest[k];
            always_comb rx[k].tuser = rx_tuser[k];
            always_comb rx[k].tid = rx_tid[k];
            always_comb rx_tready[k] = rx[k].tready;
        end
    endgenerate

    logic_axi4_stream_mux #(
        .INPUTS(INPUTS),
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    ) unit (
        .*
    );

    `LOGIC_AXI4_STREAM_IF_TX_ASSIGN(tx, tx);
endmodule

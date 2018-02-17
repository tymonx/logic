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

module logic_axi4_stream_extract_top #(
    int PACKETS = 4,
    int TDATA_BYTES = 4,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int USE_TID = 0,
    int EXTRACT_WIDTH = (USE_TID > 0) ? TID_WIDTH : TUSER_WIDTH,
    bit [PACKETS-1:0][EXTRACT_WIDTH-1:0] EXTRACT = init_extract()
) (
    input aclk,
    input areset_n,
    /* Rx */
    input rx_tlast,
    input rx_tvalid,
    input [TDATA_BYTES-1:0][7:0] rx_tdata,
    input [TDATA_BYTES-1:0] rx_tstrb,
    input [TDATA_BYTES-1:0] rx_tkeep,
    input [TDEST_WIDTH-1:0] rx_tdest,
    input [TUSER_WIDTH-1:0] rx_tuser,
    input [TID_WIDTH-1:0] rx_tid,
    output logic rx_tready,
    /* Tx */
    output logic [1:0] tx_tlast,
    output logic [1:0] tx_tvalid,
    output logic [1:0][TDATA_BYTES-1:0][7:0] tx_tdata,
    output logic [1:0][TDATA_BYTES-1:0] tx_tstrb,
    output logic [1:0][TDATA_BYTES-1:0] tx_tkeep,
    output logic [1:0][TDEST_WIDTH-1:0] tx_tdest,
    output logic [1:0][TUSER_WIDTH-1:0] tx_tuser,
    output logic [1:0][TID_WIDTH-1:0] tx_tid,
    input [1:0] tx_tready
);
    localparam int OUTPUTS = 2;

    genvar k;

    typedef bit [PACKETS-1:0][EXTRACT_WIDTH-1:0] extract_t;

    function extract_t init_extract;
        for (int i = 0; i < PACKETS; ++i) begin
            init_extract[i] = i[EXTRACT_WIDTH-1:0];
        end
    endfunction

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB),
        .USE_TLAST(USE_TLAST)
    ) rx (.*);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB),
        .USE_TLAST(USE_TLAST)
    ) tx[OUTPUTS] (
        .aclk(aclk),
        .areset_n(areset_n)
    );

    `LOGIC_AXI4_STREAM_IF_RX_ASSIGN(rx, rx);

    logic_axi4_stream_extract #(
        .PACKETS(PACKETS),
        .EXTRACT(EXTRACT),
        .USE_TID(USE_TID),
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB),
        .USE_TLAST(USE_TLAST)
    ) unit (.*);

    generate
        for (k = 0; k < OUTPUTS; ++k) begin: outputs
            always_comb tx_tvalid[k] = tx[k].tvalid;
            always_comb tx_tlast[k] = tx[k].tlast;
            always_comb tx_tdata[k] = tx[k].tdata;
            always_comb tx_tstrb[k] = tx[k].tstrb;
            always_comb tx_tkeep[k] = tx[k].tkeep;
            always_comb tx_tdest[k] = tx[k].tdest;
            always_comb tx_tuser[k] = tx[k].tuser;
            always_comb tx_tid[k] = tx[k].tid;
            always_comb tx[k].tready = tx_tready[k];
        end
    endgenerate
endmodule

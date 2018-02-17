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

module logic_axi4_stream_downsizer_top #(
    int TDATA_BYTES = 4,
    int TUSER_WIDTH = 1,
    int RX_TDATA_BYTES = 2 * TDATA_BYTES,
    int TX_TDATA_BYTES = TDATA_BYTES,
    int RX_TUSER_WIDTH = TUSER_WIDTH,
    int TX_TUSER_WIDTH = TUSER_WIDTH,
    int TDEST_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int USE_TLAST = 1
) (
    input aclk,
    input areset_n,
    /* Rx */
    input rx_tlast,
    input rx_tvalid,
    input [RX_TDATA_BYTES-1:0][7:0] rx_tdata,
    input [RX_TDATA_BYTES-1:0] rx_tstrb,
    input [RX_TDATA_BYTES-1:0] rx_tkeep,
    input [RX_TUSER_WIDTH-1:0] rx_tuser,
    input [TDEST_WIDTH-1:0] rx_tdest,
    input [TID_WIDTH-1:0] rx_tid,
    output logic rx_tready,
    /* Tx */
    output logic tx_tlast,
    output logic tx_tvalid,
    output logic [TX_TDATA_BYTES-1:0][7:0] tx_tdata,
    output logic [TX_TDATA_BYTES-1:0] tx_tstrb,
    output logic [TX_TDATA_BYTES-1:0] tx_tkeep,
    output logic [TX_TUSER_WIDTH-1:0] tx_tuser,
    output logic [TDEST_WIDTH-1:0] tx_tdest,
    output logic [TID_WIDTH-1:0] tx_tid,
    input tx_tready
);
    logic_axi4_stream_if #(
        .TDATA_BYTES(RX_TDATA_BYTES),
        .TUSER_WIDTH(RX_TUSER_WIDTH),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB),
        .USE_TLAST(USE_TLAST)
    ) rx (.*);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TX_TDATA_BYTES),
        .TUSER_WIDTH(TX_TUSER_WIDTH),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB),
        .USE_TLAST(USE_TLAST)
    ) tx (.*);

    `LOGIC_AXI4_STREAM_IF_RX_ASSIGN(rx, rx);

    logic_axi4_stream_downsizer #(
        .RX_TDATA_BYTES(RX_TDATA_BYTES),
        .TX_TDATA_BYTES(TX_TDATA_BYTES),
        .RX_TUSER_WIDTH(RX_TUSER_WIDTH),
        .TX_TUSER_WIDTH(TX_TUSER_WIDTH),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB),
        .USE_TLAST(USE_TLAST)
    ) unit (.*);

    `LOGIC_AXI4_STREAM_IF_TX_ASSIGN(tx, tx);
endmodule

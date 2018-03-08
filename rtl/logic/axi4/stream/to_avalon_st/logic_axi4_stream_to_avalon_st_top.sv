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

module logic_axi4_stream_to_avalon_st_top #(
    int TDATA_BYTES = 4,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int ERROR_WIDTH = 1,
    int EMPTY_WIDTH = (TDATA_BYTES >= 2) ? $clog2(TDATA_BYTES) : 1,
    int FIRST_SYMBOL_IN_HIGH_ORDER_BITS = 1
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
    output logic tx_valid,
    output logic tx_startofpacket,
    output logic tx_endofpacket,
    output logic [TID_WIDTH-1:0] tx_channel,
    output logic [ERROR_WIDTH-1:0] tx_error,
    output logic [EMPTY_WIDTH-1:0] tx_empty,
    output logic [TDATA_BYTES-1:0][7:0] tx_data,
    input tx_ready
);
    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    ) rx (.*);

    logic_avalon_st_if #(
        .SYMBOLS_PER_BEAT(TDATA_BYTES),
        .CHANNEL_WIDTH(TID_WIDTH),
        .ERROR_WIDTH(ERROR_WIDTH)
    ) tx (
        .clk(aclk),
        .reset_n(areset_n)
    );

    `LOGIC_AXI4_STREAM_IF_RX_ASSIGN(rx, rx);

    logic_axi4_stream_to_avalon_st #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB),
        .FIRST_SYMBOL_IN_HIGH_ORDER_BITS(FIRST_SYMBOL_IN_HIGH_ORDER_BITS)
    ) unit (.*);

    `LOGIC_AVALON_ST_IF_TX_ASSIGN(tx, tx);
endmodule

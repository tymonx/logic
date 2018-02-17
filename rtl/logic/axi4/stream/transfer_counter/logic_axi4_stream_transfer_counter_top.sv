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

module logic_axi4_stream_transfer_counter_top #(
    int COUNTER_MAX = 256,
    int PACKETS = 0,
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
    /* Monitor Rx */
    input monitor_rx_tlast,
    input monitor_rx_tvalid,
    input [TDATA_BYTES-1:0][7:0] monitor_rx_tdata,
    input [TDATA_BYTES-1:0] monitor_rx_tstrb,
    input [TDATA_BYTES-1:0] monitor_rx_tkeep,
    input [TDEST_WIDTH-1:0] monitor_rx_tdest,
    input [TUSER_WIDTH-1:0] monitor_rx_tuser,
    input [TID_WIDTH-1:0] monitor_rx_tid,
    input monitor_rx_tready,
    /* Monitor Tx */
    input monitor_tx_tlast,
    input monitor_tx_tvalid,
    input [TDATA_BYTES-1:0][7:0] monitor_tx_tdata,
    input [TDATA_BYTES-1:0] monitor_tx_tstrb,
    input [TDATA_BYTES-1:0] monitor_tx_tkeep,
    input [TDEST_WIDTH-1:0] monitor_tx_tdest,
    input [TUSER_WIDTH-1:0] monitor_tx_tuser,
    input [TID_WIDTH-1:0] monitor_tx_tid,
    input monitor_tx_tready,
    /* Tx */
    output logic tx_tlast,
    output logic tx_tvalid,
    output logic [TDATA_BYTES-1:0][7:0] tx_tdata,
    output logic [TDATA_BYTES-1:0] tx_tstrb,
    output logic [TDATA_BYTES-1:0] tx_tkeep,
    output logic [0:0] tx_tdest,
    output logic [0:0] tx_tuser,
    output logic [0:0] tx_tid,
    input tx_tready
);
    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    ) monitor_rx (.*);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    ) monitor_tx (.*);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) tx (.*);

    always_comb monitor_rx.tvalid = monitor_rx_tvalid;
    always_comb monitor_rx.tlast = monitor_rx_tlast;
    always_comb monitor_rx.tdata = monitor_rx_tdata;
    always_comb monitor_rx.tstrb = monitor_rx_tstrb;
    always_comb monitor_rx.tkeep = monitor_rx_tkeep;
    always_comb monitor_rx.tdest = monitor_rx_tdest;
    always_comb monitor_rx.tuser = monitor_rx_tuser;
    always_comb monitor_rx.tid = monitor_rx_tid;
    always_comb monitor_rx.tready = monitor_rx_tready;

    always_comb monitor_tx.tvalid = monitor_tx_tvalid;
    always_comb monitor_tx.tlast = monitor_tx_tlast;
    always_comb monitor_tx.tdata = monitor_tx_tdata;
    always_comb monitor_tx.tstrb = monitor_tx_tstrb;
    always_comb monitor_tx.tkeep = monitor_tx_tkeep;
    always_comb monitor_tx.tdest = monitor_tx_tdest;
    always_comb monitor_tx.tuser = monitor_tx_tuser;
    always_comb monitor_tx.tid = monitor_tx_tid;
    always_comb monitor_tx.tready = monitor_tx_tready;

    logic_axi4_stream_transfer_counter #(
        .PACKETS(PACKETS),
        .COUNTER_MAX(COUNTER_MAX),
        .TDATA_BYTES(TDATA_BYTES)
    ) unit (.*);

    `LOGIC_AXI4_STREAM_IF_TX_ASSIGN(tx, tx);
endmodule

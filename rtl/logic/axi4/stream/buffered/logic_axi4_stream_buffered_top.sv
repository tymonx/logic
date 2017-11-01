/* Copyright 2017 Tymoteusz Blazejczyk
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

module logic_axi4_stream_buffered_top #(
    int TDATA_BYTES = `LOGIC_AXI4_STREAM_TDATA_BYTES,
    int TDEST_WIDTH = `LOGIC_AXI4_STREAM_TDEST_WIDTH,
    int TUSER_WIDTH = `LOGIC_AXI4_STREAM_TUSER_WIDTH,
    int TID_WIDTH = `LOGIC_AXI4_STREAM_TID_WIDTH
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
    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH)
    ) rx (.*);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH)
    ) tx (.*);

    logic_axi4_stream_buffered unit (.*);

    always_comb rx.tvalid = rx_tvalid;
    always_comb rx.tlast = rx_tlast;
    always_comb rx.tdata = rx_tdata;
    always_comb rx.tstrb = rx_tstrb;
    always_comb rx.tkeep = rx_tkeep;
    always_comb rx.tdest = rx_tdest;
    always_comb rx.tuser = rx_tuser;
    always_comb rx.tid = rx_tid;
    always_comb rx_tready = rx.tready;

    always_comb tx_tvalid = tx.tvalid;
    always_comb tx_tlast = tx.tlast;
    always_comb tx_tdata = tx.tdata;
    always_comb tx_tstrb = tx.tstrb;
    always_comb tx_tkeep = tx.tkeep;
    always_comb tx_tdest = tx.tdest;
    always_comb tx_tuser = tx.tuser;
    always_comb tx_tid = tx.tid;
    always_comb tx.tready = tx_tready;
endmodule

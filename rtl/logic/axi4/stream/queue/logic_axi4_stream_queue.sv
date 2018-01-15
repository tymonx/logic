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

/* Module: logic_axi4_stream_queue
 *
 * Stores data stream in the queue (FIFO).
 *
 * Parameters:
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *  CAPACITY    - Number of single data transactions that can be store in
 *                internal queue memory (FIFO capacity).
 *  TARGET      - Target device implementation.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Stream interface.
 *  tx          - AXI4-Stream interface.
 */
module logic_axi4_stream_queue #(
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int CAPACITY = 256,
    logic_pkg::target_t TARGET = `LOGIC_CONFIG_TARGET
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    localparam TLAST_WIDTH = 1;
    localparam TDATA_WIDTH = TDATA_BYTES * 8;
    localparam TSTRB_WIDTH = TDATA_BYTES;
    localparam TKEEP_WIDTH = TDATA_BYTES;

    localparam WIDTH = TUSER_WIDTH + TDEST_WIDTH + TID_WIDTH + TLAST_WIDTH +
        TKEEP_WIDTH + TSTRB_WIDTH + TDATA_WIDTH;

    logic rx_tready;
    logic rx_tvalid;
    logic [WIDTH-1:0] rx_tdata;

    logic tx_tready;
    logic tx_tvalid;
    logic [WIDTH-1:0] tx_tdata;

    always_comb rx.tready = rx_tready;
    always_comb rx_tvalid = rx.tvalid;
    always_comb rx_tdata = {rx.tuser, rx.tdest, rx.tid, rx.tlast, rx.tkeep,
        rx.tstrb, rx.tdata};

    always_comb tx_tready = tx.tready;
    always_comb tx.tvalid = tx_tvalid;
    always_comb {tx.tuser, tx.tdest, tx.tid, tx.tlast, tx.tkeep,
        tx.tstrb, tx.tdata} = tx_tdata;

    logic_basic_queue #(
        .WIDTH(WIDTH),
        .TARGET(TARGET),
        .CAPACITY(CAPACITY)
    )
    unit (
        .*
    );
endmodule

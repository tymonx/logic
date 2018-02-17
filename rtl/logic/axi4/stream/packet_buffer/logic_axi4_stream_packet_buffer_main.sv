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

/* Module: logic_axi4_stream_packet_buffer_main
 *
 * Buffer whole packet before sending to next module.
 *
 * Parameters:
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *  USE_TLAST   - Enable or disable tlast signal.
 *  USE_TKEEP   - Enable or disable tkeep signal.
 *  USE_TSTRB   - Enable or disable tstrb signal.
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
module logic_axi4_stream_packet_buffer_main #(
    logic_pkg::target_t TARGET = logic_pkg::TARGET_GENERIC,
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TSTRB = 1,
    int USE_TKEEP = 1,
    int CAPACITY = 256
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    localparam int COUNTER_TDATA_BYTES = 4;

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    )
    queued (
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    )
    monitor_rx (
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    )
    monitor_tx (
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(COUNTER_TDATA_BYTES),
        .TDEST_WIDTH(0),
        .TUSER_WIDTH(0),
        .TID_WIDTH(0),
        .USE_TLAST(0),
        .USE_TKEEP(0),
        .USE_TSTRB(0)
    )
    packets_counted (
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(COUNTER_TDATA_BYTES),
        .TDEST_WIDTH(0),
        .TUSER_WIDTH(0),
        .TID_WIDTH(0),
        .USE_TLAST(0),
        .USE_TKEEP(0),
        .USE_TSTRB(0)
    )
    transfers_counted (
        .*
    );

    /* Workaround for Intel Quartus Lite/Standard */
    always_comb monitor_rx.tvalid = rx.tvalid;
    always_comb monitor_rx.tready = rx.tready;
    always_comb monitor_rx.tlast = rx.tlast;
    always_comb monitor_rx.tdata = rx.tdata;
    always_comb monitor_rx.tstrb = rx.tstrb;
    always_comb monitor_rx.tkeep = rx.tkeep;
    always_comb monitor_rx.tdest = rx.tdest;
    always_comb monitor_rx.tuser = rx.tuser;
    always_comb monitor_rx.tid = rx.tid;

    /* Workaround for Intel Quartus Lite/Standard */
    always_comb monitor_tx.tvalid = queued.tvalid;
    always_comb monitor_tx.tready = queued.tready;
    always_comb monitor_tx.tlast = queued.tlast;
    always_comb monitor_tx.tdata = queued.tdata;
    always_comb monitor_tx.tstrb = queued.tstrb;
    always_comb monitor_tx.tkeep = queued.tkeep;
    always_comb monitor_tx.tdest = queued.tdest;
    always_comb monitor_tx.tuser = queued.tuser;
    always_comb monitor_tx.tid = queued.tid;

    logic_axi4_stream_queue #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TSTRB(USE_TSTRB),
        .USE_TKEEP(USE_TKEEP),
        .CAPACITY(CAPACITY),
        .TARGET(TARGET)
    )
    queue (
        .tx(queued),
        .*
    );

    logic_axi4_stream_transfer_counter #(
        .PACKETS(0),
        .COUNTER_MAX(CAPACITY),
        .TDATA_BYTES(COUNTER_TDATA_BYTES)
    )
    transfers_count (
        .tx(transfers_counted),
        .*
    );

    logic_axi4_stream_transfer_counter #(
        .PACKETS(1),
        .COUNTER_MAX(CAPACITY),
        .TDATA_BYTES(COUNTER_TDATA_BYTES)
    )
    packets_count (
        .tx(packets_counted),
        .*
    );

    logic_axi4_stream_packet_buffer_unit #(
        .CAPACITY(CAPACITY)
    )
    unit (
        .rx(queued),
        .*
    );
endmodule

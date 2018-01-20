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
    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH)
    )
    queued (
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH)
    )
    monitor (
        .*
    );

    /* Workaround for Quartus Lite/Standard Prime */
    always_comb monitor.tready = rx.tready;
    always_comb monitor.tvalid = rx.tvalid;
    always_comb monitor.tlast = rx.tlast;
    always_comb monitor.tuser = rx.tuser;
    always_comb monitor.tdest = rx.tdest;
    always_comb monitor.tstrb = rx.tstrb;
    always_comb monitor.tkeep = rx.tkeep;
    always_comb monitor.tdata = rx.tdata;
    always_comb monitor.tid = rx.tid;

    logic_axi4_stream_queue #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .CAPACITY(CAPACITY),
        .TARGET(TARGET)
    )
    queue (
        .tx(queued),
        .*
    );

    logic_axi4_stream_packet_buffer_count #(
        .CAPACITY(CAPACITY)
    )
    count (
        .rx(queued),
        .*
    );
endmodule

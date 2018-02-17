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

/* Module: logic_axi4_stream_buffer
 *
 * Improve timings between modules by adding register to ready signal path from
 * tx to rx ports and it keeps zero latency bus transcation on both sides.
 *
 * Parameters:
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *  USE_TLAST   - Enable or disable tlast signal.
 *  USE_TKEEP   - Enable or disable tkeep signal.
 *  USE_TSTRB   - Enable or disable tstrb signal.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Stream interface.
 *  tx          - AXI4-Stream interface.
 */
module logic_axi4_stream_buffer #(
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    localparam int TLAST_WIDTH = (USE_TLAST > 0) ? 1 : 0;
    localparam int TDATA_WIDTH = TDATA_BYTES * 8;
    localparam int TSTRB_WIDTH = (USE_TSTRB > 0) ? TDATA_BYTES : 0;
    localparam int TKEEP_WIDTH = (USE_TKEEP > 0) ? TDATA_BYTES : 0;

    localparam int WIDTH = TUSER_WIDTH + TDEST_WIDTH + TID_WIDTH + TLAST_WIDTH +
        TKEEP_WIDTH + TSTRB_WIDTH + TDATA_WIDTH;

    logic rx_tvalid;
    logic rx_tready;
    logic [WIDTH-1:0] rx_tdata;

    logic tx_tvalid;
    logic tx_tready;
    logic [WIDTH-1:0] tx_tdata;

    always_comb rx_tvalid = rx.tvalid;
    always_comb rx.tready = rx_tready;

    always_comb tx.tvalid = tx_tvalid;
    always_comb tx_tready = tx.tready;

    always_comb rx_tdata = rx.read();
    always_comb tx.comb_write(tx_tdata);

    logic_basic_buffer #(
        .WIDTH(WIDTH)
    )
    unit (
        .*
    );
endmodule

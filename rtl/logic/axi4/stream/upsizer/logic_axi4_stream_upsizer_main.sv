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

/* Module: logic_axi4_stream_upsizer_main
 *
 * Upsize tdata and tuser output signals for next module.
 *
 * Parameters:
 *  RX_TDATA_BYTES  - Number of bytes for tdata signal.
 *  TX_TDATA_BYTES  - Number of bytes for tdata signal.
 *  RX_TUSER_WIDTH  - Number of bits for tuser signal.
 *  TX_TUSER_WIDTH  - Number of bits for tuser signal.
 *  TDEST_WIDTH     - Number of bits for tdest signal.
 *  TID_WIDTH       - Number of bits for tid signal.
 *  USE_TLAST       - Enable or disable tlast signal.
 *  USE_TKEEP       - Enable or disable tkeep signal.
 *  USE_TSTRB       - Enable or disable tstrb signal.
  *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Stream interface.
 *  tx          - AXI4-Stream interface.
 */
module logic_axi4_stream_upsizer_main #(
    int RX_TDATA_BYTES = 1,
    int TX_TDATA_BYTES = 1,
    int RX_TUSER_WIDTH = 1,
    int TX_TUSER_WIDTH = 1,
    int TDEST_WIDTH = 1,
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
    logic_axi4_stream_if #(
        .TDATA_BYTES(RX_TDATA_BYTES),
        .TUSER_WIDTH(RX_TUSER_WIDTH),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TID_WIDTH(TID_WIDTH)
    )
    buffered (
        .*
    );

    logic_axi4_stream_buffer #(
        .TDATA_BYTES(RX_TDATA_BYTES),
        .TUSER_WIDTH(RX_TUSER_WIDTH),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    )
    buffer (
        .tx(buffered),
        .*
    );

    logic_axi4_stream_upsizer_unit #(
        .RX_TDATA_BYTES(RX_TDATA_BYTES),
        .TX_TDATA_BYTES(TX_TDATA_BYTES),
        .RX_TUSER_WIDTH(RX_TUSER_WIDTH),
        .TX_TUSER_WIDTH(TX_TUSER_WIDTH),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    )
    upsized (
        .rx(buffered),
        .*
    );
endmodule

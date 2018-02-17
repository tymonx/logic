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

/* Module: logic_axi4_stream_resizer
 *
 * Resize tdata and tuser output signals for next module.
 *
 * Parameters:
 *  RX_TDATA_BYTES  - Number of bytes for rx tdata signal.
 *  TX_TDATA_BYTES  - Number of bytes for tx tdata signal.
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
module logic_axi4_stream_resizer #(
    int TDATA_BYTES = 1,
    int TUSER_WIDTH = 1,
    int RX_TDATA_BYTES = TDATA_BYTES,
    int TX_TDATA_BYTES = TDATA_BYTES,
    int RX_TUSER_WIDTH = TUSER_WIDTH,
    int TX_TUSER_WIDTH = TUSER_WIDTH,
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
    generate
        if (RX_TDATA_BYTES < TX_TDATA_BYTES) begin: upsize
            logic_axi4_stream_upsizer #(
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
            unit (
                .*
            );
        end
        else if (RX_TDATA_BYTES > TX_TDATA_BYTES) begin: downsize
            logic_axi4_stream_downsizer #(
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
            unit (
                .*
            );
        end
        else begin: bypass
            logic_axi4_stream_assign #(
                .TDATA_BYTES(TX_TDATA_BYTES),
                .TUSER_WIDTH(TX_TUSER_WIDTH),
                .TDEST_WIDTH(TDEST_WIDTH),
                .TID_WIDTH(TID_WIDTH),
                .USE_TLAST(USE_TLAST),
                .USE_TKEEP(USE_TKEEP),
                .USE_TSTRB(USE_TSTRB)
            )
            unit (
                .*
            );

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, aclk, areset_n, 1'b0};
`endif
        end
    endgenerate
endmodule

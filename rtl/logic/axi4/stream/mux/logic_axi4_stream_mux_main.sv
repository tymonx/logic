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

/* Module: logic_axi4_stream_mux_main
 *
 * Parameters:
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *  TLAST       - Enable/disable tlast signal.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Stream Rx interface.
 *  tx          - AXI4-Stream Tx interface.
 */
module logic_axi4_stream_mux_main #(
    int INPUTS = 2,
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int TLAST = 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx[INPUTS],
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    generate
        if (INPUTS > 2) begin: next
            localparam int MUXED = (INPUTS + 1) / 2;

            logic_axi4_stream_if #(
                .TDATA_BYTES((TDATA_BYTES > 0) ? TDATA_BYTES : 1),
                .TDEST_WIDTH((TDEST_WIDTH > 0) ? TDEST_WIDTH : 1),
                .TUSER_WIDTH((TUSER_WIDTH > 0) ? TUSER_WIDTH : 1),
                .TID_WIDTH((TID_WIDTH > 0) ? TID_WIDTH : 1)
            )
            muxed [MUXED] (
                .aclk(aclk),
                .areset_n(areset_n)
            );

            logic_axi4_stream_mux_stage #(
                .INPUTS(INPUTS),
                .TDATA_BYTES(TDATA_BYTES),
                .TDEST_WIDTH(TDEST_WIDTH),
                .TUSER_WIDTH(TUSER_WIDTH),
                .TID_WIDTH(TID_WIDTH),
                .TLAST(TLAST)
            )
            mux (
                .rx(rx),
                .tx(muxed),
                .*
            );

            logic_axi4_stream_mux_main #(
                .INPUTS(MUXED),
                .TDATA_BYTES(TDATA_BYTES),
                .TDEST_WIDTH(TDEST_WIDTH),
                .TUSER_WIDTH(TUSER_WIDTH),
                .TID_WIDTH(TID_WIDTH),
                .TLAST(TLAST)
            )
            main (
                .rx(muxed),
                .tx(tx),
                .*
            );
        end
        else if (2 == INPUTS) begin: last
            logic_axi4_stream_if #(
                .TDATA_BYTES((TDATA_BYTES > 0) ? TDATA_BYTES : 1),
                .TDEST_WIDTH((TDEST_WIDTH > 0) ? TDEST_WIDTH : 1),
                .TUSER_WIDTH((TUSER_WIDTH > 0) ? TUSER_WIDTH : 1),
                .TID_WIDTH((TID_WIDTH > 0) ? TID_WIDTH : 1)
            )
            muxed [1] (
                .aclk(aclk),
                .areset_n(areset_n)
            );

            logic_axi4_stream_mux_stage #(
                .INPUTS(INPUTS),
                .TDATA_BYTES(TDATA_BYTES),
                .TDEST_WIDTH(TDEST_WIDTH),
                .TUSER_WIDTH(TUSER_WIDTH),
                .TID_WIDTH(TID_WIDTH),
                .TLAST(TLAST)
            )
            mux (
                .rx(rx),
                .tx(muxed),
                .*
            );

            logic_axi4_stream_assign
            mux_assigned (
                .rx(muxed[0]),
                .tx(tx),
                .*
            );
        end
        else begin: bypassed
            logic_axi4_stream_assign
            bypass (
                .rx(rx[0]),
                .tx(tx),
                .*
            );
        end
    endgenerate
endmodule

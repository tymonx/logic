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

/* Module: logic_axi4_stream_mux_stage
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
 *  rx          - AXI4-Stream Rx interface.
 *  tx          - AXI4-Stream Tx interface.
 */
module logic_axi4_stream_mux_stage #(
    int INPUTS = 2,
    int OUTPUTS = (INPUTS + 1) / 2,
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
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx[INPUTS],
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx[OUTPUTS]
);
    localparam int NUM = 2 * (INPUTS / 2) ;

    genvar k;
    genvar n;

    generate
        if (1 == INPUTS[0]) begin: odd
            logic_axi4_stream_assign #(
                .TDATA_BYTES(TDATA_BYTES),
                .TDEST_WIDTH(TDEST_WIDTH),
                .TUSER_WIDTH(TUSER_WIDTH),
                .TID_WIDTH(TID_WIDTH),
                .USE_TLAST(USE_TLAST),
                .USE_TKEEP(USE_TKEEP),
                .USE_TSTRB(USE_TSTRB)
            )
            bypass (
                .rx(rx[INPUTS-1]),
                .tx(tx[OUTPUTS-1]),
                .*
            );
        end

        for (k = 0; k < NUM; k += 2) begin: muxes
            logic_axi4_stream_if #(
                .TDATA_BYTES(TDATA_BYTES),
                .TDEST_WIDTH(TDEST_WIDTH),
                .TUSER_WIDTH(TUSER_WIDTH),
                .TID_WIDTH(TID_WIDTH),
                .USE_TLAST(USE_TLAST),
                .USE_TKEEP(USE_TKEEP),
                .USE_TSTRB(USE_TSTRB)
            )
            buffered [2] (
                .aclk(aclk),
                .areset_n(areset_n)
            );

            for (n = 0; n < 2; ++n) begin: buffers
                logic_axi4_stream_buffer #(
                    .TDATA_BYTES(TDATA_BYTES),
                    .TDEST_WIDTH(TDEST_WIDTH),
                    .TUSER_WIDTH(TUSER_WIDTH),
                    .TID_WIDTH(TID_WIDTH),
                    .USE_TLAST(USE_TLAST),
                    .USE_TKEEP(USE_TKEEP),
                    .USE_TSTRB(USE_TSTRB)
                )
                buffer (
                    .rx(rx[k + n]),
                    .tx(buffered[n]),
                    .*
                );
            end

            logic_axi4_stream_mux_unit #(
                .TDATA_BYTES(TDATA_BYTES),
                .TDEST_WIDTH(TDEST_WIDTH),
                .TUSER_WIDTH(TUSER_WIDTH),
                .TID_WIDTH(TID_WIDTH),
                .USE_TLAST(USE_TLAST),
                .USE_TKEEP(USE_TKEEP),
                .USE_TSTRB(USE_TSTRB)
            )
            mux (
                .rx(buffered),
                .tx(tx[k / 2]),
                .*
            );
        end
    endgenerate
endmodule

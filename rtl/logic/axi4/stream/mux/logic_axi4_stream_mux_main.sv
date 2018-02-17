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

/* Module: logic_axi4_stream_mux_main
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
module logic_axi4_stream_mux_main #(
    int INPUTS = 2,
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int DEPTH = (INPUTS >= 2) ? $clog2(INPUTS) : 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx[INPUTS],
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    localparam int INPUTS_NORMALIZED = 2**DEPTH;
    localparam int MUXED = (2 * INPUTS_NORMALIZED) - 1;

    genvar k;
    genvar n;

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    )
    muxed [MUXED] (
        .aclk(aclk),
        .areset_n(areset_n)
    );

    logic_axi4_stream_assign #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    )
    output_assigned (
        .rx(muxed[0]),
        .tx(tx)
    );

    generate
        for (k = 0; k < INPUTS_NORMALIZED; ++k) begin: inputs
            if (k < INPUTS) begin: enabled
                logic_axi4_stream_assign #(
                    .TDATA_BYTES(TDATA_BYTES),
                    .TDEST_WIDTH(TDEST_WIDTH),
                    .TUSER_WIDTH(TUSER_WIDTH),
                    .TID_WIDTH(TID_WIDTH),
                    .USE_TLAST(USE_TLAST),
                    .USE_TKEEP(USE_TKEEP),
                    .USE_TSTRB(USE_TSTRB)
                )
                input_assigned (
                    .rx(rx[k]),
                    .tx(muxed[MUXED-1-k])
                );
            end
            else begin: disabled
                always_comb muxed[MUXED-1-k].tvalid = '0;
                always_comb muxed[MUXED-1-k].tlast = 'x;
                always_comb muxed[MUXED-1-k].tdata = 'x;
                always_comb muxed[MUXED-1-k].tkeep = 'x;
                always_comb muxed[MUXED-1-k].tstrb = 'x;
                always_comb muxed[MUXED-1-k].tuser = 'x;
                always_comb muxed[MUXED-1-k].tdest = 'x;
                always_comb muxed[MUXED-1-k].tid = 'x;
`ifdef VERILATOR
                logic _unused_ports = &{1'b0, muxed[MUXED-1-k].tready, 1'b0};
`endif
            end
        end

        for (k = 2; k <= INPUTS_NORMALIZED; k = 2 * k) begin: stages
            localparam int MUXED_IN = k;
            localparam int MUXED_OUT = k / 2;

            logic_axi4_stream_if #(
                .TDATA_BYTES(TDATA_BYTES),
                .TDEST_WIDTH(TDEST_WIDTH),
                .TUSER_WIDTH(TUSER_WIDTH),
                .TID_WIDTH(TID_WIDTH),
                .USE_TLAST(USE_TLAST),
                .USE_TKEEP(USE_TKEEP),
                .USE_TSTRB(USE_TSTRB)
            )
            muxed_in [MUXED_IN] (
                .aclk(aclk),
                .areset_n(areset_n)
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
            muxed_out [MUXED_OUT] (
                .aclk(aclk),
                .areset_n(areset_n)
            );

            for (n = 0; n < MUXED_IN; ++n) begin: map_in
                logic_axi4_stream_assign #(
                    .TDATA_BYTES(TDATA_BYTES),
                    .TDEST_WIDTH(TDEST_WIDTH),
                    .TUSER_WIDTH(TUSER_WIDTH),
                    .TID_WIDTH(TID_WIDTH),
                    .USE_TLAST(USE_TLAST),
                    .USE_TKEEP(USE_TKEEP),
                    .USE_TSTRB(USE_TSTRB)
                )
                mux_in_assigned (
                    .rx(muxed[k - 1 + n]),
                    .tx(muxed_in[n])
                );
            end

            for (n = 0; n < MUXED_OUT; ++n) begin: map_out
                logic_axi4_stream_assign #(
                    .TDATA_BYTES(TDATA_BYTES),
                    .TDEST_WIDTH(TDEST_WIDTH),
                    .TUSER_WIDTH(TUSER_WIDTH),
                    .TID_WIDTH(TID_WIDTH),
                    .USE_TLAST(USE_TLAST),
                    .USE_TKEEP(USE_TKEEP),
                    .USE_TSTRB(USE_TSTRB)
                )
                mux_out_assigned (
                    .rx(muxed_out[n]),
                    .tx(muxed[k/2 - 1 + n])
                );
            end

            logic_axi4_stream_mux_stage #(
                .INPUTS(k),
                .TDATA_BYTES(TDATA_BYTES),
                .TDEST_WIDTH(TDEST_WIDTH),
                .TUSER_WIDTH(TUSER_WIDTH),
                .TID_WIDTH(TID_WIDTH),
                .USE_TLAST(USE_TLAST),
                .USE_TKEEP(USE_TKEEP),
                .USE_TSTRB(USE_TSTRB)
            )
            mux (
                .rx(muxed_in),
                .tx(muxed_out),
                .*
            );
        end
    endgenerate
endmodule

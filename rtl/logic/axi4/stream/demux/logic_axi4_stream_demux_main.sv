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

/* Module: logic_axi4_stream_demux_main
 *
 * Parameters:
 *  GROUP       - Group outputs.
 *  OFFSET      - Offset ID.
 *  OUTPUTS     - Number of outputs.
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *  USE_TKEEP   - Enable or disable tkeep signal.
 *  USE_TSTRB   - Enable or disable tstrb signal.
 *  USE_TLAST   - Enable or disable tlast signal.
 *  USE_TID     - Use tid instead of tdest signal for demultiplexing data.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Stream Rx interface.
 *  tx          - AXI4-Stream Tx interface.
 */
module logic_axi4_stream_demux_main #(
    int GROUP = 8,
    int OFFSET = 0,
    int OUTPUTS = 2,
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int USE_TLAST = 1,
    int USE_TID = 0
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx[OUTPUTS]
);
    localparam int DEMUXES = (OUTPUTS + GROUP - 1) / GROUP;
    localparam int STAGES = DEMUXES + 1;

    genvar k;
    genvar n;

    logic_axi4_stream_if #(
        .TDATA_BYTES((TDATA_BYTES > 0) ? TDATA_BYTES : 1),
        .TDEST_WIDTH((TDEST_WIDTH > 0) ? TDEST_WIDTH : 1),
        .TUSER_WIDTH((TUSER_WIDTH > 0) ? TUSER_WIDTH : 1),
        .TID_WIDTH((TID_WIDTH > 0) ? TID_WIDTH : 1)
    )
    stages [STAGES] (
        .aclk(aclk),
        .areset_n(areset_n)
    );

    logic_axi4_stream_assign
    input_assigned (
        .rx(rx),
        .tx(stages[0]),
        .*
    );

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            stages[STAGES-1].tready <= '0;
        end
        else begin
            stages[STAGES-1].tready <= '1;
        end
    end

    generate
        for (k = 0; k < OUTPUTS; k += GROUP) begin: demuxes
            localparam int STAGE = (k / GROUP);
            localparam int REMAINDER = (OUTPUTS - k);
            localparam int WIDTH = (GROUP < REMAINDER) ? GROUP : REMAINDER;

            logic_axi4_stream_if #(
                .TDATA_BYTES((TDATA_BYTES > 0) ? TDATA_BYTES : 1),
                .TDEST_WIDTH((TDEST_WIDTH > 0) ? TDEST_WIDTH : 1),
                .TUSER_WIDTH((TUSER_WIDTH > 0) ? TUSER_WIDTH : 1),
                .TID_WIDTH((TID_WIDTH > 0) ? TID_WIDTH : 1)
            )
            demuxed [WIDTH] (
                .aclk(aclk),
                .areset_n(areset_n)
            );

            logic_axi4_stream_demux_stage #(
                .OFFSET(OFFSET + k),
                .OUTPUTS(WIDTH),
                .TDATA_BYTES(TDATA_BYTES),
                .TDEST_WIDTH(TDEST_WIDTH),
                .TUSER_WIDTH(TUSER_WIDTH),
                .TID_WIDTH(TID_WIDTH),
                .USE_TLAST(USE_TLAST),
                .USE_TSTRB(USE_TSTRB),
                .USE_TKEEP(USE_TKEEP),
                .USE_TID(USE_TID)
            )
            demux (
                .prev(stages[STAGE]),
                .next(stages[STAGE+1]),
                .tx(demuxed),
                .*
            );

            for (n = 0; n < WIDTH; ++n) begin: map
                logic_axi4_stream_assign
                output_assigned (
                    .rx(demuxed[n]),
                    .tx(tx[k + n]),
                    .*
                );
            end
        end
    endgenerate

`ifdef VERILATOR
    logic _unused_ports = &{
        1'b0,
        stages[STAGES-1].tvalid,
        stages[STAGES-1].tdata,
        stages[STAGES-1].tlast,
        stages[STAGES-1].tkeep,
        stages[STAGES-1].tstrb,
        stages[STAGES-1].tdest,
        stages[STAGES-1].tuser,
        stages[STAGES-1].tid,
        1'b0
    };
`endif
endmodule

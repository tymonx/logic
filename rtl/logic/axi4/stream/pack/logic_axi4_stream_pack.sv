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

/* Module: logic_axi4_stream_pack
 *
 * Description.
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
module logic_axi4_stream_pack #(
    int STAGES = 4,
    int TDATA_BYTES = 4,
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
    localparam int M_TDATA_BYTES = (TDATA_BYTES > 0) ? TDATA_BYTES : 1;
    localparam int M_TDEST_WIDTH = (TDEST_WIDTH > 0) ? TDEST_WIDTH : 1;
    localparam int M_TUSER_WIDTH = (TUSER_WIDTH > 0) ? TUSER_WIDTH : 1;
    localparam int M_TID_WIDTH = (TID_WIDTH > 0) ? TID_WIDTH : 1;
    localparam int STAGES_ALIGNED = (M_TDATA_BYTES + STAGES - 1) / STAGES;

    genvar k;

    logic_axi4_stream_if #(
        .TDATA_BYTES(M_TDATA_BYTES),
        .TDEST_WIDTH(M_TDEST_WIDTH),
        .TUSER_WIDTH(M_TUSER_WIDTH),
        .TID_WIDTH(M_TID_WIDTH)
    )
    buffered (
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(M_TDATA_BYTES),
        .TDEST_WIDTH(M_TDEST_WIDTH),
        .TUSER_WIDTH(M_TUSER_WIDTH),
        .TID_WIDTH(M_TID_WIDTH)
    )
    counted (
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(2 * M_TDATA_BYTES),
        .TDEST_WIDTH(M_TDEST_WIDTH),
        .TUSER_WIDTH(M_TUSER_WIDTH),
        .TID_WIDTH(M_TID_WIDTH)
    )
    shifted[STAGES_ALIGNED:0] (
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(2 * M_TDATA_BYTES),
        .TDEST_WIDTH(M_TDEST_WIDTH),
        .TUSER_WIDTH(M_TUSER_WIDTH),
        .TID_WIDTH(M_TID_WIDTH)
    )
    split[1:0] (
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(2 * M_TDATA_BYTES),
        .TDEST_WIDTH(M_TDEST_WIDTH),
        .TUSER_WIDTH(M_TUSER_WIDTH),
        .TID_WIDTH(M_TID_WIDTH)
    )
    delayed[1:0] (
        .*
    );

    logic_axi4_stream_buffer #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TLAST(USE_TLAST)
    )
    buffer (
        .tx(buffered),
        .*
    );

    logic_axi4_stream_pack_count #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TLAST(USE_TLAST)
    )
    count (
        .rx(buffered),
        .tx(counted),
        .*
    );

    logic_axi4_stream_pack_restore #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TLAST(USE_TLAST)
    )
    count (
        .rx(counted),
        .tx(shifted[0]),
        .*
    );

    for (k = 0; k < STAGES_ALIGNED; ++k) begin: stages
        localparam int SHIFT_STAGES = ((k * STAGES) < TDATA_BYTES) ?
            STAGES : (TDATA_BYTES - k * STAGES);

        logic_axi4_stream_pack_shift #(
            .STAGES(SHIFT_STAGES),
            .TDATA_BYTES(TDATA_BYTES),
            .TDEST_WIDTH(TDEST_WIDTH),
            .TUSER_WIDTH(TUSER_WIDTH),
            .TID_WIDTH(TID_WIDTH),
            .USE_TLAST(USE_TLAST),
            .USE_TKEEP(USE_TKEEP),
            .USE_TLAST(USE_TLAST)
        )
        shift (
            .rx(shifted[k]),
            .tx(shifted[k + 1]),
            .*
        );
    end

    logic_axi4_stream_pack_split
    split_unit (
        .rx(shifted[STAGES_ALIGNED]),
        .tx(split),
        .*
    );

    logic_axi4_stream_delay #(
        .STAGES(SHIFT_STAGES),
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TLAST(USE_TLAST)
    )
    delay (
        .rx(split[0]),
        .tx(delayed[0]),
        .*
    );

    logic_axi4_stream_assign
    split_assigned (
        .rx(split[1]),
        .tx(delayed[1]),
        .*
    );

    logic_axi4_stream_pack_join #(
        .STAGES(SHIFT_STAGES),
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TLAST(USE_TLAST)
    )
    join_unit (
        .rx(delayed),
        .*
    );
endmodule

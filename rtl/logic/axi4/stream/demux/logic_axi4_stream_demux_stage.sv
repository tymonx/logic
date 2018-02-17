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

/* Module: logic_axi4_stream_demux_stage
 *
 * Parameters:
 *  OUTPUTS     - Number of outputs.
 *  MAP         - Map tdest (or tid) to demultiplexer output.
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
 *  prev        - AXI4-Stream Rx interface.
 *  next        - AXI4-Stream Tx interface.
 *  tx          - AXI4-Stream Tx interface.
 */
module logic_axi4_stream_demux_stage #(
    int OUTPUTS = 2,
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int USE_TLAST = 1,
    int USE_TID = 0,
    int MAP_WIDTH = (USE_TID > 0) ? TID_WIDTH : TUSER_WIDTH,
    bit [OUTPUTS-1:0][MAP_WIDTH-1:0] MAP = init_map()
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) prev,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) next,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx[OUTPUTS]
);
    typedef bit [OUTPUTS-1:0][MAP_WIDTH-1:0] map_t;

    function map_t init_map;
        for (int i = 0; i < OUTPUTS; ++i) begin
            init_map[i] = i[MAP_WIDTH-1:0];
        end
    endfunction

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB),
        .USE_TLAST(USE_TLAST)
    )
    buffered (
        .*
    );

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
        .rx(prev),
        .tx(buffered),
        .*
    );

    logic_axi4_stream_demux_unit #(
        .MAP(MAP),
        .OUTPUTS(OUTPUTS),
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
        .prev(buffered),
        .next(next),
        .tx(tx),
        .*
    );
endmodule

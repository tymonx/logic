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

/* Module: logic_axi4_stream_from_avalon_st
 *
 * Avalon-ST interface to AXI4-Stream interface bridge.
 *
 * Parameters:
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *  USE_TLAST   - Enable or disable tlast signal.
 *  USE_TKEEP   - Enable or disable tkeep signal.
 *  USE_TSTRB   - Enable or disable tstrb signal.
 *  FIRST_SYMBOL_IN_HIGH_ORDER_BITS - 1 is big-endian, 0 is little-endian.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - Avalon-ST interface.
 *  tx          - AXI4-Stream interface.
 */
module logic_axi4_stream_from_avalon_st #(
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int USE_TLAST = 1,
    int EMPTY_WIDTH = (TDATA_BYTES >= 2) ? $clog2(TDATA_BYTES) : 1,
    int FIRST_SYMBOL_IN_HIGH_ORDER_BITS = 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_avalon_st_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    genvar k;

    localparam int M_TDATA_BYTES = (TDATA_BYTES > 0) ? TDATA_BYTES : 1;
    localparam int M_TSTRB_WIDTH = (TDATA_BYTES > 0) ? TDATA_BYTES : 1;
    localparam int M_TID_WIDTH = (TID_WIDTH > 0) ? TID_WIDTH : 1;

    typedef logic [M_TID_WIDTH-1:0] tid_t;
    typedef logic [M_TSTRB_WIDTH-1:0] tstrb_t;
    typedef logic [M_TDATA_BYTES-1:0][7:0] tdata_t;

    tdata_t endiannes;

    generate
        if (FIRST_SYMBOL_IN_HIGH_ORDER_BITS > 0) begin: big_endian
            for (k = 0; k < M_TDATA_BYTES; ++k) begin: swap
                always_comb endiannes[M_TDATA_BYTES - 1 - k] = rx.data[k];
            end
        end
        else begin: little_endian
            always_comb endiannes = tdata_t'(rx.data);
        end
    endgenerate

    always_comb rx.ready = tx.tready;
    always_comb tx.tkeep = '1;
    always_comb tx.tuser = '0;
    always_comb tx.tdest = '0;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.tvalid <= '0;
        end
        else if (tx.tready) begin
            tx.tvalid <= rx.valid;
        end
    end

    always_ff @(posedge aclk) begin
        if (tx.tready) begin
            tx.tlast <= rx.endofpacket;
            tx.tid <= tid_t'(rx.channel);
            tx.tstrb <= tstrb_t'({M_TSTRB_WIDTH{1'b1}} >> rx.empty);
            tx.tdata <= endiannes;
        end
    end

`ifdef VERILATOR
    logic _unused_ports = &{1'b0, rx.startofpacket, rx.error, 1'b0};
`endif
endmodule

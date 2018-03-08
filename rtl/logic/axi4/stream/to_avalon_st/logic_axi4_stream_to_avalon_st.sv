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

/* Module: logic_axi4_stream_to_avalon_st
 *
 * AXI4-Stream interface to Avalon-ST interface bridge.
 *
 * Parameters:
 *  TDATA_BYTES  - Number of bytes for tdata signal.
 *  TUSER_WIDTH  - Number of bits for tuser signal.
 *  TDEST_WIDTH  - Number of bits for tdest signal.
 *  TID_WIDTH    - Number of bits for tid signal.
 *  USE_TLAST    - Enable or disable tlast signal.
 *  USE_TKEEP    - Enable or disable tkeep signal.
 *  USE_TSTRB    - Enable or disable tstrb signal.
 *  FIRST_SYMBOL_IN_HIGH_ORDER_BITS - 1 is big-endian, 0 is little-endian.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Stream interface.
 *  tx          - Avalon-ST interface.
 */
module logic_axi4_stream_to_avalon_st #(
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int EMPTY_WIDTH = (TDATA_BYTES >= 2) ? $clog2(TDATA_BYTES) : 1,
    int FIRST_SYMBOL_IN_HIGH_ORDER_BITS = 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_avalon_st_if, tx) tx
);
    localparam int M_TDATA_BYTES = (TDATA_BYTES > 0) ? TDATA_BYTES : 1;

    typedef logic [M_TDATA_BYTES-1:0][7:0] tdata_t;

    genvar k;

    logic startofpacket;
    logic [EMPTY_WIDTH-1:0] empty;

    tdata_t endiannes;

    generate
        if (FIRST_SYMBOL_IN_HIGH_ORDER_BITS > 0) begin: big_endian
            for (k = 0; k < M_TDATA_BYTES; ++k) begin: swap
                always_comb endiannes[M_TDATA_BYTES - 1 - k] = rx.tdata[k];
            end
        end
        else begin: little_endian
            always_comb endiannes = tdata_t'(rx.tdata);
        end
    endgenerate

    always_comb rx.tready = tx.ready;
    always_comb tx.error = '0;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.valid <= '0;
        end
        else if (tx.ready) begin
            tx.valid <= rx.tvalid;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            startofpacket <= '1;
        end
        else if (rx.tready && rx.tvalid) begin
            if (rx.tlast) begin
                startofpacket <= '1;
            end
            else begin
                startofpacket <= '0;
            end
        end
    end

    always_comb begin
        empty = '0;

        for (int i = 0; i < TDATA_BYTES; ++i) begin
            if (rx.tstrb[i] && rx.tkeep[i]) begin
                --empty;
            end
        end
    end

    always_ff @(posedge aclk) begin
        if (tx.ready) begin
            tx.startofpacket <= startofpacket;
            tx.endofpacket <= rx.tlast;
            tx.channel <= rx.tid;
            tx.empty <= empty;
            tx.data <= endiannes;
        end
    end
endmodule

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

/* Module: logic_axi4_stream_queue
 *
 * Stores data stream in the queue (FIFO).
 *
 * Parameters:
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *  TLAST       - Enable/disable tlast signal.
 *  CAPACITY    - Number of single data transactions that can be store in
 *                internal queue memory (FIFO capacity).
 *  TARGET      - Target device implementation.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Stream interface.
 *  tx          - AXI4-Stream interface.
 */
module logic_axi4_stream_queue #(
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int TLAST = 1,
    int CAPACITY = 256,
    logic_pkg::target_t TARGET = `LOGIC_CONFIG_TARGET
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    localparam TLAST_WIDTH = (TLAST > 0) ? 1 : 0;
    localparam TDATA_WIDTH = TDATA_BYTES * 8;
    localparam TSTRB_WIDTH = TDATA_BYTES;
    localparam TKEEP_WIDTH = TDATA_BYTES;

    localparam WIDTH = TUSER_WIDTH + TDEST_WIDTH + TID_WIDTH + TLAST_WIDTH +
        TKEEP_WIDTH + TSTRB_WIDTH + TDATA_WIDTH;

    localparam TDATA_OFFSET = 0;
    localparam TSTRB_OFFSET = TDATA_OFFSET + TDATA_WIDTH;
    localparam TKEEP_OFFSET = TSTRB_OFFSET + TSTRB_WIDTH;
    localparam TLAST_OFFSET = TKEEP_OFFSET + TKEEP_WIDTH;
    localparam TDEST_OFFSET = TLAST_OFFSET + TLAST_WIDTH;
    localparam TUSER_OFFSET = TDEST_OFFSET + TDEST_WIDTH;
    localparam TID_OFFSET = TUSER_OFFSET + TUSER_WIDTH;

    logic rx_tvalid;
    logic rx_tready;
    logic [WIDTH-1:0] rx_tdata;

    logic tx_tvalid;
    logic tx_tready;
    logic [WIDTH-1:0] tx_tdata;

    always_comb rx_tvalid = rx.tvalid;
    always_comb rx.tready = rx_tready;

    always_comb tx.tvalid = tx_tvalid;
    always_comb tx_tready = tx.tready;

    generate
        if (TDATA_BYTES > 0) begin: tdata_enabled
            always_comb rx_tdata[TDATA_OFFSET+:TDATA_WIDTH] = rx.tdata;
            always_comb rx_tdata[TSTRB_OFFSET+:TSTRB_WIDTH] = rx.tstrb;
            always_comb rx_tdata[TKEEP_OFFSET+:TKEEP_WIDTH] = rx.tstrb;

            always_comb tx.tdata = tx_tdata[TDATA_OFFSET+:TDATA_WIDTH];
            always_comb tx.tstrb = tx_tdata[TSTRB_OFFSET+:TSTRB_WIDTH];
            always_comb tx.tkeep = tx_tdata[TKEEP_OFFSET+:TKEEP_WIDTH];
        end
        else begin: tdata_disabled
            always_comb tx.tdata = '0;
            always_comb tx.tstrb = '1;
            always_comb tx.tkeep = '1;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tdata, rx.tstrb, rx.tkeep, 1'b0};
`endif
        end

        if (TLAST_WIDTH > 0) begin: tlast_enabled
            always_comb rx_tdata[TLAST_OFFSET+:TLAST_WIDTH] = rx.tlast;
            always_comb tx.tlast = tx_tdata[TLAST_OFFSET+:TLAST_WIDTH];
        end
        else begin: tlast_disabled
            always_comb tx.tlast = '1;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tlast, 1'b0};
`endif
        end

        if (TDEST_WIDTH > 0) begin: tdest_enabled
            always_comb rx_tdata[TDEST_OFFSET+:TDEST_WIDTH] = rx.tdest;
            always_comb tx.tdest = tx_tdata[TDEST_OFFSET+:TDEST_WIDTH];
        end
        else begin: tdest_disabled
            always_comb tx.tdest = '0;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tdest, 1'b0};
`endif
        end

        if (TUSER_WIDTH > 0) begin: tuser_enabled
            always_comb rx_tdata[TUSER_OFFSET+:TUSER_WIDTH] = rx.tuser;
            always_comb tx.tuser = tx_tdata[TUSER_OFFSET+:TUSER_WIDTH];
        end
        else begin: tuser_disabled
            always_comb tx.tuser = '0;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tuser, 1'b0};
`endif
        end

        if (TID_WIDTH > 0) begin: tid_enabled
            always_comb rx_tdata[TID_OFFSET+:TID_WIDTH] = rx.tid;
            always_comb tx.tid = tx_tdata[TID_OFFSET+:TID_WIDTH];
        end
        else begin: tid_disabled
            always_comb tx.tid = '0;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tid, 1'b0};
`endif
        end
    endgenerate

    logic_basic_queue #(
        .WIDTH(WIDTH),
        .TARGET(TARGET),
        .CAPACITY(CAPACITY)
    )
    unit (
        .*
    );
endmodule

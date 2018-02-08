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

/* Module: logic_axi4_stream_downsizer_unit
 *
 * Downsizer tdata and tuser output signals for next module.
 *
 * Parameters:
 *  RX_TDATA_BYTES  - Number of bytes for tdata signal.
 *  TX_TDATA_BYTES  - Number of bytes for tdata signal.
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
module logic_axi4_stream_downsizer_unit #(
    int RX_TDATA_BYTES = 1,
    int TX_TDATA_BYTES = 1,
    int RX_TUSER_WIDTH = 1,
    int TX_TUSER_WIDTH = 1,
    int TDEST_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int DOWNSIZE = RX_TDATA_BYTES / TX_TDATA_BYTES,
    int INDEX_WIDTH = (DOWNSIZE >= 2) ? $clog2(DOWNSIZE) : 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    localparam TDATA_BYTES = TX_TDATA_BYTES;

    localparam DOWNSIZE_MAX = 2**INDEX_WIDTH;
    localparam TLAST_WIDTH = (USE_TLAST > 0) ? 1 : 0;
    localparam TDATA_WIDTH = TDATA_BYTES * 8;
    localparam TSTRB_WIDTH = (USE_TSTRB > 0) ? TDATA_BYTES : 0;
    localparam TKEEP_WIDTH = (USE_TKEEP > 0) ? TDATA_BYTES : 0;

    localparam real DOWNSIZE_REAL = real'(RX_TDATA_BYTES)/real'(TX_TDATA_BYTES);
    localparam int DOWNSIZE_FLOOR = int'(DOWNSIZE_REAL + 0.499);

    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL(DOWNSIZE, DOWNSIZE_FLOOR)
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(RX_TDATA_BYTES, TX_TDATA_BYTES)
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(RX_TUSER_WIDTH, TX_TUSER_WIDTH)
    end

    enum logic [0:0] {
        FSM_FIRST,
        FSM_DOWNSIZE
    } fsm_state;

    genvar k;

    logic index_reset;
    logic index_enable;
    logic index_last;
    logic [INDEX_WIDTH-1:0] index = '0;
    logic last[0:DOWNSIZE_MAX-1];
    logic [DOWNSIZE-1:0][TDATA_BYTES-1:0] keep_bytes;

    always_comb last[DOWNSIZE-1] = 1'b1;
    always_comb keep_bytes = rx.tkeep | rx.tstrb;

    always_comb index_last = last[index];
    always_comb index_enable = tx.tready && rx.tvalid;
    always_comb index_reset = tx.tready && rx.tvalid && index_last;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            index <= '0;
        end
        else if (index_reset) begin
            index <= '0;
        end
        else if (index_enable) begin
            index <= index + 1'b1;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_FIRST;
        end
        else if (rx.tvalid && tx.tready) begin
            unique case (fsm_state)
            FSM_FIRST: begin
                if (!last[0]) begin
                    fsm_state <= FSM_DOWNSIZE;
                end
            end
            FSM_DOWNSIZE: begin
                if (index_last) begin
                    fsm_state <= FSM_FIRST;
                end
            end
            default: begin
                fsm_state <= FSM_FIRST;
            end
            endcase
        end
    end

    always_comb begin
        unique case (fsm_state)
        FSM_FIRST: begin
            rx.tready = !rx.tvalid || (rx.tvalid && tx.tready && last[0]);
        end
        FSM_DOWNSIZE: begin
            rx.tready = rx.tvalid && tx.tready && index_last;
        end
        default: begin
            rx.tready = '0;
        end
        endcase
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.tvalid <= '0;
        end
        else if (tx.tready) begin
            tx.tvalid <= rx.tvalid;
        end
    end

    generate
        for (k = 0; k < (DOWNSIZE - 1); ++k) begin: downsize_last
            always_comb last[k] = (|keep_bytes[k]) &&
                (~|keep_bytes[DOWNSIZE-1:k+1]);
        end

        for (k = DOWNSIZE; k < DOWNSIZE_MAX; ++k) begin: downsize_unknown
            always_comb last[k] = 'X;
        end

        if (TDATA_BYTES > 0) begin: tdata_enabled
            logic [DOWNSIZE_MAX-1:0][TDATA_WIDTH-1:0] mux;

            always_comb mux[DOWNSIZE-1:0] = rx.tdata;

            for (k = DOWNSIZE; k < DOWNSIZE_MAX; ++k) begin: unknown
                always_comb mux[k] = 'X;
            end

            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tdata <= mux[index];
                end
            end
        end
        else begin: tdata_disabled
            always_comb tx.tdata = '0;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tdata, 1'b0};
`endif
        end

        if (TKEEP_WIDTH > 0) begin: tkeep_enabled
            logic [DOWNSIZE_MAX-1:0][TKEEP_WIDTH-1:0] mux;

            always_comb mux[DOWNSIZE-1:0] = rx.tkeep;

            for (k = DOWNSIZE; k < DOWNSIZE_MAX; ++k) begin: unknown
                always_comb mux[k] = 'X;
            end

            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tkeep <= mux[index];
                end
            end
        end
        else begin: tkeep_disabled
            always_comb tx.tkeep = '1;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tkeep, 1'b0};
`endif
        end

        if (TSTRB_WIDTH > 0) begin: tstrb_enabled
            logic [DOWNSIZE_MAX-1:0][TSTRB_WIDTH-1:0] mux;

            always_comb mux[DOWNSIZE-1:0] = rx.tstrb;

            for (k = DOWNSIZE; k < DOWNSIZE_MAX; ++k) begin: unknown
                always_comb mux[k] = 'X;
            end

            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tstrb <= mux[index];
                end
            end
        end
        else begin: tstrb_disabled
            always_comb tx.tstrb = '1;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tstrb, 1'b0};
`endif
        end

        if (TLAST_WIDTH > 0) begin: tlast_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tlast <= rx.tlast && rx.tvalid && index_last;
                end
            end
        end
        else begin: tlast_disabled
            always_comb tx.tlast = '1;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tlast, 1'b0};
`endif
        end

        if (TDEST_WIDTH > 0) begin: tdest_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tdest <= rx.tdest;
                end
            end
        end
        else begin: tdest_disabled
            always_comb tx.tdest = '0;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tdest, 1'b0};
`endif
        end

        if ((RX_TUSER_WIDTH > 0) && (TX_TUSER_WIDTH > 0)) begin: tuser_enabled
            if (RX_TUSER_WIDTH == TX_TUSER_WIDTH) begin: pass
                always_ff @(posedge aclk) begin
                    if (tx.tready) begin
                        tx.tuser <= rx.tuser;
                    end
                end
            end
            else if (RX_TUSER_WIDTH == (DOWNSIZE * TX_TUSER_WIDTH)) begin: down
                logic [DOWNSIZE_MAX-1:0][TX_TUSER_WIDTH-1:0] mux;

                always_comb mux[DOWNSIZE-1:0] = rx.tuser;

                for (k = DOWNSIZE; k < DOWNSIZE_MAX; ++k) begin: unknown
                    always_comb mux[k] = 'X;
                end

                always_ff @(posedge aclk) begin
                    if (tx.tready) begin
                        tx.tuser <= mux[index];
                    end
                end
            end
            else begin: not_supported
                initial begin
                    `LOGIC_DRC_NOT_SUPPORTED(RX_TUSER_WIDTH)
                end
            end
        end
        else begin: tuser_disabled
            always_comb tx.tuser = '0;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tuser, 1'b0};
`endif
        end

        if (TID_WIDTH > 0) begin: tid_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tid <= rx.tid;
                end
            end
        end
        else begin: tid_disabled
            always_comb tx.tid = '0;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tid, 1'b0};
`endif
        end
    endgenerate
endmodule

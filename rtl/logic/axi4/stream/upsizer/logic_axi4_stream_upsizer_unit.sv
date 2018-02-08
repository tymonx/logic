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

/* Module: logic_axi4_stream_upsizer_unit
 *
 * Upsize tdata and tuser output signals for next module.
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
module logic_axi4_stream_upsizer_unit #(
    int RX_TDATA_BYTES = 1,
    int TX_TDATA_BYTES = 1,
    int RX_TUSER_WIDTH = 1,
    int TX_TUSER_WIDTH = 1,
    int TDEST_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int UPSIZE = TX_TDATA_BYTES / RX_TDATA_BYTES,
    int INDEX_WIDTH = (UPSIZE >= 2) ? $clog2(UPSIZE) : 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    localparam int TDATA_BYTES = RX_TDATA_BYTES;

    localparam int INDEX_MAX = UPSIZE - 1;
    localparam int TLAST_WIDTH = (USE_TLAST > 0) ? 1 : 0;
    localparam int TDATA_WIDTH = TDATA_BYTES * 8;
    localparam int TSTRB_WIDTH = (USE_TSTRB > 0) ? TDATA_BYTES : 0;
    localparam int TKEEP_WIDTH = (USE_TKEEP > 0) ? TDATA_BYTES : 0;

    localparam real UPSIZE_REAL = real'(TX_TDATA_BYTES)/real'(RX_TDATA_BYTES);
    localparam int UPSIZE_FLOOR = int'(UPSIZE_REAL + 0.499);

    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL(UPSIZE, UPSIZE_FLOOR)
        `LOGIC_DRC_EQUAL_OR_LESS_THAN(RX_TDATA_BYTES, TX_TDATA_BYTES)
        `LOGIC_DRC_EQUAL_OR_LESS_THAN(RX_TUSER_WIDTH, TX_TUSER_WIDTH)
    end

    enum logic [1:0] {
        FSM_UPSIZE,
        FSM_UPSIZE_NEXT,
        FSM_UPSIZE_LAST
    } fsm_state;

    genvar k;

    logic index_reset;
    logic index_enable;
    logic index_last;
    logic [INDEX_WIDTH-1:0] index;

    logic [UPSIZE-1:0] write;

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

    always_comb index_last = (INDEX_MAX[INDEX_WIDTH-1:0] == index);

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_UPSIZE;
        end
        else begin
            unique case (fsm_state)
            FSM_UPSIZE: begin
                if (rx.tvalid) begin
                    if (rx.tlast) begin
                        fsm_state <= FSM_UPSIZE_LAST;
                    end
                    else if (index_last) begin
                        fsm_state <= FSM_UPSIZE_NEXT;
                    end
                end
            end
            FSM_UPSIZE_NEXT, FSM_UPSIZE_LAST: begin
                if (tx.tready) begin
                    if (rx.tvalid) begin
                        if (rx.tlast) begin
                            fsm_state <= FSM_UPSIZE_LAST;
                        end
                        else if (index_last) begin
                            fsm_state <= FSM_UPSIZE_NEXT;
                        end
                        else begin
                            fsm_state <= FSM_UPSIZE;
                        end
                    end
                    else begin
                        fsm_state <= FSM_UPSIZE;
                    end
                end
            end
            default: begin
                fsm_state <= FSM_UPSIZE;
            end
            endcase
        end
    end

    always_comb begin
        unique case (fsm_state)
        FSM_UPSIZE: begin
            rx.tready = '1;
        end
        default: begin
            rx.tready = !rx.tvalid || tx.tready;
        end
        endcase
    end

    always_comb begin
        unique case (fsm_state)
        FSM_UPSIZE: begin
            index_enable = rx.tvalid;
        end
        FSM_UPSIZE_NEXT, FSM_UPSIZE_LAST: begin
            index_enable = rx.tvalid && tx.tready && !rx.tlast && !index_last;
        end
        default: begin
            index_enable = '0;
        end
        endcase
    end

    always_comb begin
        unique case (fsm_state)
        FSM_UPSIZE: begin
            index_reset = rx.tvalid && (index_last || rx.tlast);
        end
        FSM_UPSIZE_NEXT, FSM_UPSIZE_LAST: begin
            index_reset = rx.tvalid && (index_last || rx.tlast) && tx.tready;
        end
        default: begin
            index_reset = '0;
        end
        endcase
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.tvalid <= '0;
        end
        else if (tx.tready) begin
            tx.tvalid <= (FSM_UPSIZE_NEXT == fsm_state) ||
                (FSM_UPSIZE_LAST == fsm_state);
        end
    end

    generate
        for (k = 0; k < UPSIZE; ++k) begin: upsize_write
            always_comb write[k] = (k[INDEX_WIDTH-1:0] == index) &&
                rx.tvalid && rx.tready;
        end

        if (TDATA_BYTES > 0) begin: tdata_enabled
            logic [UPSIZE-1:0][TDATA_BYTES-1:0][7:0] buffer;

            for (k = 0; k < UPSIZE; ++k) begin: upsize
                always_ff @(posedge aclk) begin
                    if (write[k]) begin
                        buffer[k] <= rx.tdata;
                    end
                end
            end

            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tdata <= buffer;
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
            logic [UPSIZE-1:0][TKEEP_WIDTH-1:0] buffer;

            always_ff @(posedge aclk) begin
                if (write[0]) begin
                    buffer[0] <= rx.tkeep;
                end
            end

            for (k = 1; k < UPSIZE; ++k) begin: upsize
                always_ff @(posedge aclk) begin
                    if (write[0]) begin
                        buffer[k] <= '0;
                    end
                    else if (write[k]) begin
                        buffer[k] <= rx.tkeep;
                    end
                end
            end

            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tkeep <= buffer;
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
            logic [UPSIZE-1:0][TSTRB_WIDTH-1:0] buffer;

            always_ff @(posedge aclk) begin
                if (write[0]) begin
                    buffer[0] <= rx.tstrb;
                end
            end

            for (k = 1; k < UPSIZE; ++k) begin: upsize
                always_ff @(posedge aclk) begin
                    if (write[0]) begin
                        buffer[k] <= '0;
                    end
                    else if (write[k]) begin
                        buffer[k] <= rx.tstrb;
                    end
                end
            end

            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tstrb <= buffer;
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
                    tx.tlast <= (FSM_UPSIZE_LAST == fsm_state);
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
            logic [TDEST_WIDTH-1:0] buffer;

            always_ff @(posedge aclk) begin
                if (write[0]) begin
                    buffer <= rx.tdest;
                end
            end

            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tdest <= buffer;
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
                logic [RX_TUSER_WIDTH-1:0] buffer;

                always_ff @(posedge aclk) begin
                    if (write[0]) begin
                        buffer <= rx.tuser;
                    end
                end

                always_ff @(posedge aclk) begin
                    if (tx.tready) begin
                        tx.tuser <= buffer;
                    end
                end
            end
            else if ((UPSIZE * RX_TUSER_WIDTH) == TX_TUSER_WIDTH) begin: up
                logic [UPSIZE-1:0][RX_TUSER_WIDTH-1:0] buffer;

                always_ff @(posedge aclk) begin
                    if (write[0]) begin
                        buffer[0] <= rx.tuser;
                    end
                end

                for (k = 1; k < UPSIZE; ++k) begin: upsize
                    always_ff @(posedge aclk) begin
                        if (write[0]) begin
                            buffer[k] <= '0;
                        end
                        else if (write[k]) begin
                            buffer[k] <= rx.tuser;
                        end
                    end
                end

                always_ff @(posedge aclk) begin
                    if (tx.tready) begin
                        tx.tuser <= buffer;
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
            logic [TID_WIDTH-1:0] buffer;

            always_ff @(posedge aclk) begin
                if (write[0]) begin
                    buffer <= rx.tid;
                end
            end

            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tid <= buffer;
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

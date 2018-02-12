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

/* Module: logic_axi4_stream_pack_join
 *
 * Count valid bytes.
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
module logic_axi4_stream_pack_join #(
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
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx[1:0],
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    logic valid;
    logic [TDATA_BYTES-1:0][7:0] data;

    enum logic [1:0] {
        FSM_IDLE,
        FSM_RX0_PACK,
        FSM_RX0_ALIGNED,
        FSM_RX1_PACK,
        FSM_RX1_ALIGNED,
        FSM_RX1_IDLE
    } fsm_state;

    always_comb rx.tready = tx.tready;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_IDLE;
        end
        else if (tx.tready) begin
            unique case (fsm_state)
            FSM_IDLE, FSM_RX0_ALIGNED, FSM_RX0_PACK: begin
                if (rx[0].tvalid) begin
                    if (rx[0].tlast) begin
                        fsm_state <= FSM_IDLE;
                    end
                    else if (rx[0].tkeep[TDATA_BYTES-1]) begin
                        fsm_state <= FSM_RX0_ALIGNED;
                    end
                    else if (rx[1].tvalid) begin
                        if (rx[1].tlast) begin
                            fsm_state <= FSM_RX1_IDLE;
                        end
                        else if (rx[1].tkeep[TDATA_BYTES-1]) begin
                            fsm_state <= FSM_RX1_ALIGNED;
                        end
                        else begin
                            fsm_state <= FSM_RX1_PACK;
                        end
                    end
                    else begin
                        fsm_state <= FSM_RX0_PACK;
                    end
                end
            end
            FSM_RX1_ALIGNED: begin
                fsm_state <= FSM_RX0_ALIGNED;
            end
            FSM_RX1_PACK: begin
                fsm_state <= FSM_RX0_PACK;
            end
            default: begin
                fsm_state <= FSM_IDLE;
            end
            endcase
        end
    end

    always_comb begin
        unique case (fsm_state)
        FSM_IDLE, FSM_ALIGNED: begin
            valid = rx[0].tvalid && (rx[0].tlast ||
                rx[0].tkeep[TDATA_BYTES-1]);
        end
        default: begin
            valid = '0;
        end
        endcase
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.tvalid <= '0;
        end
        else if (tx.tready) begin
            tx.tvalid <= valid;
        end
    end

    always_ff @(posedge aclk) begin
        if (tx.tready) begin
            tx.tkeep <= rx.tkeep;
            tx.tdata <= rx.tdata;
        end
    end

    generate
        if (USE_TSTRB > 0) begin: tstrb_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tstrb <= rx[0].tstrb;
                end
            end
        end
        else begin: tstrb_disabled
            always_comb tx.tstrb = '1;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx[0].tstrb, 1'b0};
`endif
        end

        if (USE_TLAST > 0) begin: tlast_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tlast <= rx[0].tlast;
                end
            end
        end
        else begin: tlast_disabled
            always_comb tx.tlast = '1;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx[0].tlast, 1'b0};
`endif
        end

        if (TUSER_WIDTH > 0) begin: tuser_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tuser <= rx[0].tuser;
                end
            end
        end
        else begin: tuser_disabled
            always_comb tx.tuser = '0;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx[0].tuser, 1'b0};
`endif
        end

        if (TDEST_WIDTH > 0) begin: tdest_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tdest <= rx[0].tdest;
                end
            end
        end
        else begin: tdest_disabled
            always_comb tx.tdest = '0;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx[0].tdest, 1'b0};
`endif
        end

        if (TID_WIDTH > 0) begin: tid_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tid <= rx[0].tid;
                end
            end
        end
        else begin: tid_disabled
            always_comb tx.tid = '0;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx[0].tid, 1'b0};
`endif
        end
    endgenerate
endmodule

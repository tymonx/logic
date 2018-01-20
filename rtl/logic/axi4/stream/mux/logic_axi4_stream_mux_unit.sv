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

/* Module: logic_axi4_stream_mux_unit
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
module logic_axi4_stream_mux_unit #(
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx[2],
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    enum logic [1:0] {
        FSM_FIRST,
        FSM_FIRST_SELECT,
        FSM_SECOND,
        FSM_SECOND_SELECT
    } fsm_state;

    logic select;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_FIRST;
        end
        else if (tx.tready) begin
            unique case (fsm_state)
            FSM_FIRST: begin
                if (rx[0].tvalid) begin
                    fsm_state <= rx[0].tlast ? FSM_SECOND : FSM_FIRST_SELECT;
                end
                else if (rx[1].tvalid) begin
                    fsm_state <= rx[1].tlast ? FSM_FIRST : FSM_SECOND_SELECT;
                end
            end
            FSM_FIRST_SELECT: begin
                if (rx[0].tvalid && rx[0].tlast) begin
                    fsm_state <= FSM_SECOND;
                end
            end
            FSM_SECOND: begin
                if (rx[1].tvalid) begin
                    fsm_state <= rx[1].tlast ? FSM_FIRST : FSM_SECOND_SELECT;
                end
                else if (rx[0].tvalid) begin
                    fsm_state <= rx[0].tlast ? FSM_SECOND : FSM_FIRST_SELECT;
                end
            end
            FSM_SECOND_SELECT: begin
                if (rx[1].tvalid && rx[1].tlast) begin
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
            select = rx[0].tvalid ? '0 : '1;
        end
        FSM_FIRST_SELECT: begin
            select = '0;
        end
        FSM_SECOND: begin
            select = rx[1].tvalid ? '1 : '0;
        end
        FSM_SECOND_SELECT: begin
            select = '1;
        end
        default: begin
            select = '0;
        end
        endcase
    end

    always_comb rx[0].tready = !rx[0].tvalid || ((1'b0 == select) && tx.tready);
    always_comb rx[1].tready = !rx[1].tvalid || ((1'b1 == select) && tx.tready);

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.tvalid <= '0;
        end
        else if (tx.tready) begin
            tx.tvalid <= select ? rx[1].tvalid : rx[0].tvalid;
        end
    end

    generate
        if (USE_TLAST > 0) begin: tlast_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tlast <= select ? rx[1].tlast : rx[0].tlast;
                end
            end
        end
        else begin: tlast_disabled
            always_comb tx.tlast = '1;
        end

        if ((TDATA_BYTES > 0) && (USE_TKEEP > 0)) begin: tkeep_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tkeep <= select ? rx[1].tkeep : rx[0].tkeep;
                end
            end
        end
        else begin: tkeep_disabled
            always_comb tx.tkeep = '1;
        end

        if ((TDATA_BYTES > 0) && (USE_TSTRB > 0)) begin: tstrb_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tstrb <= select ? rx[1].tstrb : rx[0].tstrb;
                end
            end
        end
        else begin: tstrb_disabled
            always_comb tx.tstrb = '1;
        end

        if (TDATA_BYTES > 0) begin: tdata_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tdata <= select ? rx[1].tdata : rx[0].tdata;
                end
            end
        end
        else begin: tdata_disabled
            always_comb tx.tdata = '0;
        end

        if (TUSER_WIDTH > 0) begin: tuser_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tuser <= select ? rx[1].tuser : rx[0].tuser;
                end
            end
        end
        else begin: tuser_disabled
            always_comb tx.tuser = '0;
        end

        if (TDEST_WIDTH > 0) begin: tdest_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tdest <= select ? rx[1].tdest : rx[0].tdest;
                end
            end
        end
        else begin: tdest_disabled
            always_comb tx.tdest = '0;
        end

        if (TID_WIDTH > 0) begin: tid_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tid <= select ? rx[1].tid : rx[0].tid;
                end
            end
        end
        else begin: tid_disabled
            always_comb tx.tid = '0;
        end
    endgenerate
endmodule

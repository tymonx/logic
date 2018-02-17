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

    always_ff @(posedge aclk) begin
        if (tx.tready) begin
            tx.write(select ? rx[1].read() : rx[0].read());
        end
    end
endmodule

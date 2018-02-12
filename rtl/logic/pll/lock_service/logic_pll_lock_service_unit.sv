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

/* Module: logic_pll_lock_service_unit
 *
 * Main implementation for logic_pll_lock_service module.
 * It provides PLL control by using PLL input reset and PLL output locked
 * signals.
 *
 * Parameters:
 *  RESET_DURATION      - Number of clock cycles for PLL reset duration.
 *  WAIT_FOR_LOCK       - Number of clock cycles for PLL lock timeout.
 *  PLL_LOCKED_STAGES   - Number of registers used for filtering PLL locked
 *                        signal.
 *
 * Ports:
 *  aclk            - Clock.
 *  areset_n        - Asynchronous active-low reset.
 *  pll_locked      - PLL locked signal from PLL.
 *  pll_reset       - PLL reset signal to PLL.
 *  locked          - Filtered and stable PLL locked output signal.
 *  timer_config    - AXI4-Stream interface for configuring timer.
 *  timer           - AXI4-Stream interface for timer.
 */
module logic_pll_lock_service_unit #(
    int RESET_DURATION = 2,
    int WAIT_FOR_LOCK = 1_000_000,
    int PLL_LOCKED_STAGES = 8
) (
    input aclk,
    input areset_n,
    input pll_locked,
    output logic pll_reset,
    output logic locked,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) timer,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) timer_config
);
    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(RESET_DURATION, 2)
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(WAIT_FOR_LOCK, 2)
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(PLL_LOCKED_STAGES, 2)
    end

    enum logic [1:0] {
        FSM_RESET,
        FSM_WAIT_FOR_LOCK,
        FSM_LOCKED,
        FSM_RESET_LOAD
    } fsm_state;

    logic timer_event;

    logic pll_locked_stable;
    logic pll_locked_filtered;
    logic [PLL_LOCKED_STAGES-1:0] pll_locked_q;

    always_comb timer_event = timer.tready && timer.tvalid && timer.tlast;

    always_comb timer_config.tlast = '1;
    always_comb timer_config.tstrb = '1;
    always_comb timer_config.tkeep = '1;
    always_comb timer_config.tuser = '0;
    always_comb timer_config.tdest = '0;
    always_comb timer_config.tid = '0;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            pll_locked_q <= '0;
        end
        else begin
            pll_locked_q <= {pll_locked, pll_locked_q[PLL_LOCKED_STAGES-1:1]};
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            pll_locked_stable <= '0;
        end
        else begin
            pll_locked_stable <= &pll_locked_q;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            pll_locked_filtered <= '0;
        end
        else begin
            pll_locked_filtered <= |pll_locked_q;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_RESET;
        end
        else begin
            unique case (fsm_state)
            FSM_RESET: begin
                if (timer_event) begin
                    fsm_state <= FSM_WAIT_FOR_LOCK;
                end
            end
            FSM_WAIT_FOR_LOCK: begin
                if (1'b1 === pll_locked_stable) begin
                    fsm_state <= FSM_LOCKED;
                end
                else if (timer_event) begin
                    fsm_state <= FSM_RESET_LOAD;
                end
            end
            FSM_LOCKED: begin
                if (1'b1 !== pll_locked_filtered) begin
                    fsm_state <= FSM_RESET_LOAD;
                end
            end
            FSM_RESET_LOAD: begin
                fsm_state <= FSM_RESET;
            end
            default: begin
                fsm_state <= FSM_RESET;
            end
            endcase
        end
    end

    always_comb begin
        unique case (fsm_state)
        FSM_RESET_LOAD: begin
            timer_config.tvalid = '1;
        end
        FSM_RESET: begin
            timer_config.tvalid = timer_event;
        end
        default: begin
            timer_config.tvalid = '0;
        end
        endcase
    end

    always_comb begin
        unique case (fsm_state)
        FSM_RESET_LOAD: begin
            timer_config.tdata = RESET_DURATION[$bits(timer_config.tdata)-1:0];
        end
        FSM_RESET: begin
            timer_config.tdata = WAIT_FOR_LOCK[$bits(timer_config.tdata)-1:0];
        end
        default: begin
            timer_config.tdata = '0;
        end
        endcase
    end

    always_comb begin
        unique case (fsm_state)
        FSM_RESET, FSM_RESET_LOAD, FSM_WAIT_FOR_LOCK: begin
            timer.tready = '1;
        end
        default: begin
            timer.tready = '0;
        end
        endcase
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            pll_reset <= '1;
        end
        else begin
            pll_reset <= (FSM_RESET == fsm_state);
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            locked <= '0;
        end
        else begin
            locked <= (FSM_LOCKED == fsm_state);
        end
    end
endmodule

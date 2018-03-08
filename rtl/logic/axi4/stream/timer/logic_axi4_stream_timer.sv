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

/* Module: logic_axi4_stream_timer
 *
 * Timer over AXI4-Stream interface. The rx input port is used to write
 * periodic value for internal counter. The tx output port produce values
 * from 0 to periodic value minus one. The tlast output signal is used
 * as counter reload event.
 *
 * Parameters:
 *  TDATA_BYTES         - Number of bytes for tdata signal.
 *  DEFAULT_PERIODIC    - Default periodic value for internal counter.
 *  COUNTER_MAX         - Maximum value for internal counter. It used to
 *                        calculate COUNTER_WIDTH parameter.
 *  COUNTER_WIDTH       - Number of bits for internal counter.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Stream interface. Used to load periodic value for
 *                counter.
 *  tx          - AXI4-Stream interface. It produces values from 0 to
 *                periodic minus one. The tlast output signal is used as
 *                counter reload event.
 */
module logic_axi4_stream_timer #(
    int TDATA_BYTES = 4,
    int PERIODIC_DEFAULT = 2,
    int COUNTER_MAX = PERIODIC_DEFAULT,
    int COUNTER_WIDTH = (COUNTER_MAX >= 2) ? $clog2(COUNTER_MAX) : 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    localparam int PERIODIC_OFFSET = 2;
    localparam int PERIODIC_LOAD = PERIODIC_DEFAULT - PERIODIC_OFFSET;

    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(PERIODIC_DEFAULT, 2)
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(COUNTER_MAX, PERIODIC_DEFAULT)
    end

    typedef logic [COUNTER_WIDTH-1:0] counter_t;
    typedef logic [TDATA_BYTES-1:0][7:0] data_t;

    enum logic [0:0] {
        FSM_IDLE,
        FSM_RELOAD
    } fsm_state;

    logic counter_event;
    logic counter_reload;

    counter_t counter;
    counter_t periodic;
    counter_t periodic_load;

    always_comb rx.tready = '1;

    always_comb periodic_load = counter_t'(rx.tdata) -
        PERIODIC_OFFSET[COUNTER_WIDTH-1:0];

    always_comb counter_reload = counter_event || rx.tvalid ||
        (FSM_RELOAD == fsm_state);

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_IDLE;
        end
        else begin
            case (fsm_state)
            FSM_IDLE: begin
                if (rx.tvalid && tx.tvalid && !tx.tready) begin
                    fsm_state <= FSM_RELOAD;
                end
            end
            FSM_RELOAD: begin
                if (tx.tvalid && tx.tready) begin
                    fsm_state <= FSM_IDLE;
                end
            end
            default: begin
                fsm_state <= FSM_IDLE;
            end
            endcase
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            counter <= '0;
        end
        else if (tx.tready && tx.tvalid) begin
            counter <= counter_reload ? '0 : counter + 1'b1;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            periodic <= PERIODIC_LOAD[COUNTER_WIDTH-1:0];
        end
        else if (rx.tvalid) begin
            periodic <= periodic_load;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            counter_event <= '0;
        end
        else if (tx.tready) begin
            counter_event <= (counter == periodic) && !rx.tvalid &&
                (FSM_RELOAD != fsm_state);
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.tvalid <= '0;
        end
        else if (tx.tready) begin
            tx.tvalid <= '1;
        end
    end

    always_comb tx.tlast = counter_event;
    always_comb tx.tdata = data_t'(counter);
    always_comb tx.tstrb = '1;
    always_comb tx.tkeep = '1;
    always_comb tx.tuser = '0;
    always_comb tx.tdest = '0;
    always_comb tx.tid = '0;
endmodule

/* Copyright 2017 Tymoteusz Blazejczyk
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

/* Module: logic_clock_domain_crossing_generic_read
 *
 * Parameters:
 *  WIDTH       - Number of bits for input and output data signals.
 *  CAPACITY    - Number of elements that can be stored inside module.
 *
 * Ports:
 *  tx_aclk         - Clock.
 *  tx_areset_n     - Asynchronous active-low reset.
 *  tx_tvalid       - Tx valid signal.
 *  tx_tdata        - Tx data signal.
 *  tx_tready       - Tx ready signal.
 *  read_enable     - Read enable.
 *  read_data       - Read data.
 *  read_pointer    - Read pointer.
 *  write_pointer   - Write pointer.
 */
module logic_clock_domain_crossing_generic_read #(
    int DATA_WIDTH = 1,
    int ADDRESS_WIDTH = 1
) (
    input tx_aclk,
    input tx_areset_n,
    /* Tx */
    output logic tx_tvalid,
    output logic [DATA_WIDTH-1:0] tx_tdata,
    input tx_tready,
    /* Read */
    output logic read_enable,
    output logic [ADDRESS_WIDTH-1:0] read_pointer,
    input [DATA_WIDTH-1:0] read_data,
    input [ADDRESS_WIDTH-1:0] write_pointer_synced
);
    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(ADDRESS_WIDTH, 2)
    end

    localparam ALMOST_EMPTY = 3;

    enum logic [1:0] {
        FSM_IDLE,
        FSM_WAIT,
        FSM_READ,
        FSM_BURST
    } fsm_state;

    logic empty;
    logic almost_empty;
    logic [ADDRESS_WIDTH-1:0] difference;

    always_ff @(posedge tx_aclk or negedge tx_areset_n) begin
        if (!tx_areset_n) begin
            difference <= '0;
        end
        else begin
            difference <= write_pointer_synced - read_pointer;
        end
    end

    always_ff @(posedge tx_aclk or negedge tx_areset_n) begin
        if (!tx_areset_n) begin
            empty <= '0;
        end
        else begin
            empty <= (write_pointer_synced == read_pointer);
        end
    end

    always_ff @(posedge tx_aclk or negedge tx_areset_n) begin
        if (!tx_areset_n) begin
            almost_empty <= '0;
        end
        else begin
            almost_empty <= (difference < ALMOST_EMPTY[ADDRESS_WIDTH-1:0]);
        end
    end

    always_ff @(posedge tx_aclk or negedge tx_areset_n) begin
        if (!tx_areset_n) begin
            fsm_state <= FSM_IDLE;
        end
        else begin
            unique case (fsm_state)
            FSM_IDLE: begin
                if (!almost_empty) begin
                    fsm_state <= FSM_BURST;
                end
                else if (!empty) begin
                    fsm_state <= FSM_WAIT;
                end
            end
            FSM_WAIT: begin
                fsm_state <= FSM_READ;
            end
            FSM_READ: begin
                if (tx_tready) begin
                    if (!almost_empty) begin
                        fsm_state <= FSM_BURST;
                    end
                    else if (!empty) begin
                        fsm_state <= FSM_WAIT;
                    end
                    else begin
                        fsm_state <= FSM_IDLE;
                    end
                end
            end
            FSM_BURST: begin
                if (tx_tready && almost_empty) begin
                    fsm_state <= FSM_WAIT;
                end
            end
            default: begin
                fsm_state <= FSM_IDLE;
            end
            endcase
        end
    end

    always_comb begin
        unique case (fsm_state)
        FSM_IDLE: begin
            read_enable = !empty;
        end
        FSM_READ: begin
            read_enable = !empty && tx_tready;
        end
        FSM_BURST: begin
            read_enable = tx_tready;
        end
        default: begin
            read_enable = '0;
        end
        endcase
    end

    always_ff @(posedge tx_aclk or negedge tx_areset_n) begin
        if (!tx_areset_n) begin
            read_pointer <= '0;
        end
        else if (read_enable) begin
            read_pointer <= read_pointer + 1'b1;
        end
    end

    always_ff @(posedge tx_aclk or negedge tx_areset_n) begin
        if (!tx_areset_n) begin
            tx_tvalid <= '0;
        end
        else if (tx_tready) begin
            tx_tvalid <= (FSM_READ == fsm_state) || (FSM_BURST == fsm_state);
        end
    end

    always_ff @(posedge tx_aclk) begin
        if (tx_tready) begin
            tx_tdata <= read_data;
        end
    end
endmodule

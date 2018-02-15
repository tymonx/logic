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

module logic_basic_queue_generic_read #(
    int DATA_WIDTH = 1,
    int ADDRESS_WIDTH = 1
) (
    input aclk,
    input areset_n,
    input tx_tready,
    output logic tx_tvalid,
    output logic [DATA_WIDTH-1:0] tx_tdata,
    input [DATA_WIDTH-1:0] read_data,
    output logic [ADDRESS_WIDTH-1:0] read_pointer,
    output logic read_enable,
    input [ADDRESS_WIDTH:0] capacity
);
    localparam int ALMOST_EMPTY = 1;

    enum logic [0:0] {
        FSM_IDLE,
        FSM_DATA
    } fsm_state;

    logic empty;
    logic almost_empty;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            almost_empty <= '1;
        end
        else begin
            almost_empty <= (capacity <= ALMOST_EMPTY[ADDRESS_WIDTH:0]);
        end
    end

    always_comb empty = almost_empty && (2'b00 == capacity[1:0]);

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            read_pointer <= '0;
        end
        else if (read_enable) begin
            read_pointer <= read_pointer + 1'b1;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_IDLE;
        end
        else begin
            unique case (fsm_state)
            FSM_IDLE: begin
                if (!empty) begin
                    fsm_state <= FSM_DATA;
                end
            end
            FSM_DATA: begin
                if (tx_tready && empty) begin
                    fsm_state <= FSM_IDLE;
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
        FSM_DATA: begin
            read_enable = !empty && tx_tready;
        end
        default: begin
            read_enable = '0;
        end
        endcase
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx_tvalid <= '0;
        end
        else if (tx_tready) begin
            tx_tvalid <= (FSM_DATA == fsm_state);
        end
    end

    always_ff @(posedge aclk) begin
        if (tx_tready) begin
            tx_tdata <= read_data;
        end
    end
endmodule

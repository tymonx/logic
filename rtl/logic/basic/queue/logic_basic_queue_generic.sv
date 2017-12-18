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

module logic_basic_queue_generic #(
    int WIDTH = 1,
    int CAPACITY = 256,
    int ADDRESS_WIDTH = $clog2(CAPACITY)
) (
    input aclk,
    input areset_n,
    /* Rx */
    input rx_tvalid,
    input [WIDTH-1:0] rx_tdata,
    output logic rx_tready,
    /* Tx */
    input tx_tready,
    output logic tx_tvalid,
    output logic [WIDTH-1:0] tx_tdata
);
    localparam QUEUE_DEPTH = 2**ADDRESS_WIDTH;
    localparam ALMOST_FULL = QUEUE_DEPTH - 3;
    localparam DATA_WIDTH = WIDTH;

    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(CAPACITY, 4)
    end

    logic [DATA_WIDTH-1:0] queue[0:QUEUE_DEPTH-1];

    logic write;
    logic [DATA_WIDTH-1:0] write_data;
    logic [ADDRESS_WIDTH-1:0] write_pointer;

    logic read;
    logic [DATA_WIDTH-1:0] read_data;
    logic [ADDRESS_WIDTH-1:0] read_pointer;

    struct packed {
        logic valid;
        logic [ADDRESS_WIDTH-1:0] capacity;
    } status;

    enum logic [0:0] {
        FSM_IDLE,
        FSM_DATA
    } fsm_state;

    always_ff @(posedge aclk) begin
        write_data <= rx_tdata;
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            write <= '0;
        end
        else begin
            write <= rx_tvalid && rx_tready;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            rx_tready <= '0;
        end
        else begin
            rx_tready <= !status.valid ||
                (status.capacity < ALMOST_FULL[ADDRESS_WIDTH-1:0]);
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            write_pointer <= '0;
        end
        else if (write) begin
            write_pointer <= write_pointer + 1'b1;
        end
    end

    always_ff @(posedge aclk) begin
        if (write) begin
            queue[write_pointer] <= write_data;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            read_pointer <= '0;
        end
        else if (read) begin
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
                if (status.valid) begin
                    fsm_state <= FSM_DATA;
                end
            end
            FSM_DATA: begin
                if (tx_tready && !status.valid) begin
                    fsm_state <= FSM_IDLE;
                end
            end
            endcase
        end
    end

    always_comb begin
        unique case (fsm_state)
        FSM_IDLE: begin
            read = status.valid;
        end
        FSM_DATA: begin
            read = status.valid && tx_tready;
        end
        endcase
    end

    always_ff @(posedge aclk) begin
        if (read) begin
            read_data <= queue[read_pointer];
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            status <= '{valid: 1'b0, capacity: '1};
        end
        else if (write && !read) begin
            status <= status + 1'b1;
        end
        else if (!write && read) begin
            status <= status - 1'b1;
        end
    end

    always_comb tx_tvalid = (FSM_DATA == fsm_state);
    always_comb tx_tdata = read_data;
endmodule

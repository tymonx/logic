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

module logic_axi4_stream_queue_intel #(
    int CAPACITY = 256,
    int ADDRESS_WIDTH = $clog2(CAPACITY)
) (
    input aclk,
    input areset_n,
    logic_axi4_stream_if.rx rx,
    logic_axi4_stream_if.tx tx
);
    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(CAPACITY, 4)
    end

    logic full;
    logic almost_full;
    logic write;
    logic [$bits(rx.read())-1:0] write_data;

    logic empty;
    logic almost_empty;
    logic read;
    logic [$bits(rx.read())-1:0] read_data;

    logic [ADDRESS_WIDTH-1:0] usedw;
    logic [1:0] eccstatus;

    enum logic [0:0] {
        FSM_IDLE,
        FSM_DATA
    } fsm_state;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            write <= '0;
        end
        else begin
            write <= rx.tvalid && rx.tready;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            rx.tready <= '0;
        end
        else begin
            rx.tready <= !almost_full;
        end
    end

    always_ff @(posedge aclk) begin
        write_data <= rx.read();
    end

    scfifo #(
        .lpm_width($bits(write_data)),
        .lpm_widthu(ADDRESS_WIDTH),
        .lpm_numwords(2**ADDRESS_WIDTH),
        .lpm_type("scfifo"),
        .lpm_showahead("OFF"),
        .almost_full_value(2**ADDRESS_WIDTH - 2),
        .overflow_checking("OFF"),
        .underflow_checking("OFF")
    )
    scfifo (
        .data(write_data),
        .wrreq(write),
        .rdreq(read),
        .clock(aclk),
        .aclr(!areset_n),
        .sclr(1'b0),
        .q(read_data),
        .*
    );

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
                if (tx.tready && empty) begin
                    fsm_state <= FSM_IDLE;
                end
            end
            endcase
        end
    end

    always_comb begin
        unique case (fsm_state)
        FSM_IDLE: begin
            read = !empty;
        end
        FSM_DATA: begin
            read = !empty && tx.tready;
        end
        endcase
    end

    always_comb tx.tvalid = (FSM_DATA == fsm_state);
    always_comb tx.comb_write(read_data);
endmodule

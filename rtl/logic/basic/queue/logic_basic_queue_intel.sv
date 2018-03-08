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

module logic_basic_queue_intel #(
    int WIDTH = 1,
    int CAPACITY = 256,
    int ADDRESS_WIDTH = $clog2(CAPACITY)
) (
    input aclk,
    input areset_n,
    input rx_tvalid,
    input [WIDTH-1:0] rx_tdata,
    output logic rx_tready,
    input tx_tready,
    output logic tx_tvalid,
    output logic [WIDTH-1:0] tx_tdata
);
    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(CAPACITY, 4)
    end

    localparam DATA_WIDTH = WIDTH;
    localparam ALMOST_FULL = (2**ADDRESS_WIDTH) - 1;

    logic full;
    logic almost_full;
    logic write;
    logic [DATA_WIDTH-1:0] write_data;

    logic empty;
    logic almost_empty;
    logic read;
    logic [DATA_WIDTH-1:0] read_data;

    logic [ADDRESS_WIDTH-1:0] usedw;

    enum logic [0:0] {
        FSM_IDLE,
        FSM_DATA
    } fsm_state;

    always_comb write = rx_tvalid && rx_tready;
    always_comb write_data = rx_tdata;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            rx_tready <= '0;
        end
        else begin
            rx_tready <= !almost_full;
        end
    end

    /* verilator lint_off PINMISSING */
    /* verilator lint_off DECLFILENAME */

    scfifo #(
        .lpm_width($bits(write_data)),
        .lpm_widthu(ADDRESS_WIDTH),
        .lpm_numwords(2**ADDRESS_WIDTH),
        .lpm_type("scfifo"),
        .lpm_showahead("OFF"),
        .almost_full_value(ALMOST_FULL),
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
        .usedw(usedw),
        .empty(empty),
        .full(full),
        .almost_empty(almost_empty),
        .almost_full(almost_full)
    );

    /* verilator lint_on DECLFILENAME */
    /* verilator lint_on PINMISSING */

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
            read = !empty;
        end
        FSM_DATA: begin
            read = !empty && tx_tready;
        end
        default: begin
            read = '0;
        end
        endcase
    end

    always_comb tx_tvalid = (FSM_DATA == fsm_state);
    always_comb tx_tdata = read_data;

`ifdef OVL_ASSERT_ON
    logic [`OVL_FIRE_WIDTH-1:0] assert_usedw_overflow_fire;
    logic [`OVL_FIRE_WIDTH-1:0] assert_usedw_underflow_fire;

    ovl_no_transition #(
        .severity_level(`OVL_FATAL),
        .width(ADDRESS_WIDTH),
        .property_type(`OVL_ASSERT),
        .msg("usedw cannot overflow")
    )
    assert_usedw_overflow (
        .clock(aclk),
        .reset(areset_n),
        .enable(1'b1),
        .test_expr(usedw),
        .start_state('1),
        .next_state('0),
        .fire(assert_usedw_overflow_fire)
    );

    ovl_no_transition #(
        .severity_level(`OVL_FATAL),
        .width(ADDRESS_WIDTH),
        .property_type(`OVL_ASSERT),
        .msg("usedw cannot underflow")
    )
    assert_usedw_underflow (
        .clock(aclk),
        .reset(areset_n),
        .enable(1'b1),
        .test_expr(usedw),
        .start_state('0),
        .next_state('1),
        .fire(assert_usedw_underflow_fire)
    );
`endif

endmodule

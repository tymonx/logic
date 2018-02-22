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

/* Module: logic_clock_domain_crossing_generic_write
 *
 * Parameters:
 *  WIDTH       - Number of bits for input and output data signals.
 *  CAPACITY    - Number of elements that can be stored inside module.
 *
 * Ports:
 *  rx_aclk         - Clock.
 *  rx_areset_n     - Asynchronous active-low reset.
 *  rx_tvalid       - Rx valid signal.
 *  rx_tdata        - Rx data signal.
 *  rx_tready       - Rx ready signal.
 *  write_enable    - Write enable.
 *  write_data      - Write data.
 *  write_pointer   - Write pointer.
 *  read_pointer    - Read pointer.
 */
module logic_clock_domain_crossing_generic_write #(
    int DATA_WIDTH = 1,
    int ADDRESS_WIDTH = 3
) (
    input rx_aclk,
    input rx_areset_n,
    input rx_tvalid,
    input [DATA_WIDTH-1:0] rx_tdata,
    output logic rx_tready,
    output logic write_enable,
    output logic [DATA_WIDTH-1:0] write_data,
    output logic [ADDRESS_WIDTH-1:0] write_pointer,
    input [ADDRESS_WIDTH-1:0] read_pointer_synced
);
    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(ADDRESS_WIDTH, 3)
    end

    localparam ALMOST_FULL = (2**ADDRESS_WIDTH) - 3;

    logic almost_full;
    logic [ADDRESS_WIDTH-1:0] difference;

    always_ff @(posedge rx_aclk or negedge rx_areset_n) begin
        if (!rx_areset_n) begin
            difference <= '0;
        end
        else begin
            difference <= write_pointer - read_pointer_synced;
        end
    end

    always_comb write_data = rx_tdata;
    always_comb write_enable = rx_tvalid && rx_tready;
    always_comb almost_full = (difference >= ALMOST_FULL[ADDRESS_WIDTH-1:0]);

    always_ff @(posedge rx_aclk or negedge rx_areset_n) begin
        if (!rx_areset_n) begin
            rx_tready <= '0;
        end
        else begin
            rx_tready <= !almost_full;
        end
    end

    always_ff @(posedge rx_aclk or negedge rx_areset_n) begin
        if (!rx_areset_n) begin
            write_pointer <= '0;
        end
        else if (write_enable) begin
            write_pointer <= write_pointer + 1'b1;
        end
    end

`ifdef OVL_ASSERT_ON
    /* verilator lint_off UNUSED */
    logic [`OVL_FIRE_WIDTH-1:0] assert_difference_overflow_fire;
    logic [`OVL_FIRE_WIDTH-1:0] assert_difference_underflow_fire;
    /* verilator lint_on UNUSED */

    ovl_no_transition #(
        .severity_level(`OVL_FATAL),
        .width(ADDRESS_WIDTH),
        .property_type(`OVL_ASSERT),
        .msg("difference cannot overflow")
    )
    assert_difference_overflow (
        .clock(rx_aclk),
        .reset(rx_areset_n),
        .enable(1'b1),
        .test_expr(difference),
        .start_state('1),
        .next_state('0),
        .fire(assert_difference_overflow_fire)
    );

    ovl_no_transition #(
        .severity_level(`OVL_FATAL),
        .width(ADDRESS_WIDTH),
        .property_type(`OVL_ASSERT),
        .msg("difference cannot underflow")
    )
    assert_difference_underflow (
        .clock(rx_aclk),
        .reset(rx_areset_n),
        .enable(1'b1),
        .test_expr(difference),
        .start_state('0),
        .next_state('1),
        .fire(assert_difference_underflow_fire)
    );
`endif

endmodule

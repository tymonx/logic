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

/* Module: logic_clock_domain_crossing_intel
 *
 * Parameters:
 *  WIDTH       - Number of bits for input and output data signals.
 *  CAPACITY    - Number of elements that can be stored inside module.
 *
 * Ports:
 *  areset_n    - Asynchronous active-low reset.
 *  rx_aclk     - Rx clock.
 *  rx_tvalid   - Rx valid signal.
 *  rx_tdata    - Rx data signal.
 *  rx_tready   - Rx ready signal.
 *  tx_aclk     - Tx clock.
 *  tx_tvalid   - Tx valid signal.
 *  tx_tdata    - Tx data signal.
 *  tx_tready   - Tx ready signal.
 */
module logic_clock_domain_crossing_intel #(
    int WIDTH = 1,
    int CAPACITY = 256,
    int ADDRESS_WIDTH = $clog2(CAPACITY)
) (
    input areset_n,
    input rx_aclk,
    input rx_tvalid,
    input [WIDTH-1:0] rx_tdata,
    output logic rx_tready,
    input tx_aclk,
    input tx_tready,
    output logic tx_tvalid,
    output logic [WIDTH-1:0] tx_tdata
);
    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(CAPACITY, 4)
    end

    localparam DATA_WIDTH = WIDTH;
    localparam ALMOST_FULL = (2**ADDRESS_WIDTH) - 1;

    logic wrfull;
    logic wrempty;
    logic [ADDRESS_WIDTH-1:0] wrusedw;

    logic rdfull;
    logic rdempty;
    logic [ADDRESS_WIDTH-1:0] rdusedw;

    logic write_enable;
    logic [DATA_WIDTH-1:0] write_data;

    logic read_enable;
    logic [DATA_WIDTH-1:0] read_data;

    logic almost_full;

    enum logic [0:0] {
        FSM_IDLE,
        FSM_DATA
    } fsm_state;

    always_comb write_enable = rx_tvalid && rx_tready;
    always_comb write_data = rx_tdata;
    always_comb almost_full = (wrusedw >= ALMOST_FULL[ADDRESS_WIDTH-1:0]);

    always_ff @(posedge rx_aclk or negedge areset_n) begin
        if (!areset_n) begin
            rx_tready <= '0;
        end
        else begin
            rx_tready <= !almost_full;
        end
    end

    /* verilator lint_off PINMISSING */
    /* verilator lint_off DECLFILENAME */

    dcfifo #(
        .lpm_width(DATA_WIDTH),
        .lpm_widthu(ADDRESS_WIDTH),
        .lpm_numwords(2**ADDRESS_WIDTH),
        .lpm_type("dcfifo"),
        .lpm_showahead("OFF"),
        .overflow_checking("OFF"),
        .underflow_checking("OFF")
    )
    dcfifo (
        .data(write_data),
        .wrreq(write_enable),
        .rdreq(read_enable),
        .wrclk(rx_aclk),
        .rdclk(tx_aclk),
        .aclr(!areset_n),
        .q(read_data),
        .wrusedw(wrusedw),
        .wrempty(wrempty),
        .wrfull(wrfull),
        .rdempty(rdempty),
        .rdfull(rdfull),
        .rdusedw(rdusedw)
    );

    /* verilator lint_on DECLFILENAME */
    /* verilator lint_on PINMISSING */

    always_ff @(posedge tx_aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_IDLE;
        end
        else begin
            unique case (fsm_state)
            FSM_IDLE: begin
                if (!rdempty) begin
                    fsm_state <= FSM_DATA;
                end
            end
            FSM_DATA: begin
                if (tx_tready && rdempty) begin
                    fsm_state <= FSM_IDLE;
                end
            end
            endcase
        end
    end

    always_comb begin
        unique case (fsm_state)
        FSM_IDLE: begin
            read_enable = !rdempty;
        end
        FSM_DATA: begin
            read_enable = !rdempty && tx_tready;
        end
        default: begin
            read_enable = '0;
        end
        endcase
    end

    always_ff @(posedge tx_aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx_tvalid <= '0;
        end
        else if (tx_tready) begin
            tx_tvalid <= (FSM_DATA == fsm_state);
        end
    end

    always_ff @(posedge tx_aclk) begin
        if (tx_tready) begin
            tx_tdata <= read_data;
        end
    end

`ifdef OVL_ASSERT_ON
    logic [`OVL_FIRE_WIDTH-1:0] assert_wrusedw_overflow_fire;
    logic [`OVL_FIRE_WIDTH-1:0] assert_wrusedw_underflow_fire;
    logic [`OVL_FIRE_WIDTH-1:0] assert_rdusedw_overflow_fire;
    logic [`OVL_FIRE_WIDTH-1:0] assert_rdusedw_underflow_fire;

    ovl_no_transition #(
        .severity_level(`OVL_FATAL),
        .width(ADDRESS_WIDTH),
        .property_type(`OVL_ASSERT),
        .msg("wrusedw cannot overflow")
    )
    assert_wrusedw_overflow (
        .clock(rx_aclk),
        .reset(areset_n),
        .enable(1'b1),
        .test_expr(wrusedw),
        .start_state('1),
        .next_state('0),
        .fire(assert_wrusedw_overflow_fire)
    );

    ovl_no_transition #(
        .severity_level(`OVL_FATAL),
        .width(ADDRESS_WIDTH),
        .property_type(`OVL_ASSERT),
        .msg("wrusedw cannot underflow")
    )
    assert_wrusedw_underflow (
        .clock(rx_aclk),
        .reset(areset_n),
        .enable(1'b1),
        .test_expr(wrusedw),
        .start_state('0),
        .next_state('1),
        .fire(assert_wrusedw_underflow_fire)
    );

    ovl_no_transition #(
        .severity_level(`OVL_FATAL),
        .width(ADDRESS_WIDTH),
        .property_type(`OVL_ASSERT),
        .msg("rdusedw cannot overflow")
    )
    assert_rdusedw_overflow (
        .clock(rx_aclk),
        .reset(areset_n),
        .enable(1'b1),
        .test_expr(rdusedw),
        .start_state('1),
        .next_state('0),
        .fire(assert_rdusedw_overflow_fire)
    );

    ovl_no_transition #(
        .severity_level(`OVL_FATAL),
        .width(ADDRESS_WIDTH),
        .property_type(`OVL_ASSERT),
        .msg("rdusedw cannot underflow")
    )
    assert_rdusedw_underflow (
        .clock(rx_aclk),
        .reset(areset_n),
        .enable(1'b1),
        .test_expr(rdusedw),
        .start_state('0),
        .next_state('1),
        .fire(assert_rdusedw_underflow_fire)
    );
`endif

endmodule

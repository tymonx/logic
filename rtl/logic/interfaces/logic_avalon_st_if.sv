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

/* Interface: logic_avalon_st_if
 *
 * Avalon-ST interface.
 *
 * Parameters:
 *  SYMBOLS_PER_BEAT     - The number of symbols that are transferred on every
 *                         valid cycle.
 *  DATA_BITS_PER_SYMBOL - Defines the number of bits per symbol. For example,
 *                         byte-oriented interfaces have 8-bit symbols.
 *                         This value is not restricted to be a power of 2.
 *  MAX_CHANNEL          - The maximum number of channels that a data
 *                         interface can support.
 *  CHANNEL_WIDTH        - Number of bits for channel signal.
 *  ERROR_WIDTH          - Number of bits for error signal.
 *  FIRST_SYMBOL_IN_HIGH_ORDER_BITS - When true, the first-order symbol is
 *                                   driven to the most significant bits of
 *                                   the data interface. The highest-order
 *                                   symbol is labeled D0 in this specification.
 *                                   When this property is set to false,
 *                                   the first symbol appears on the low bits.
 *                                   D0 appears at data[7:0]. For a 32-bit bus,
 *                                   if true, D0 appears on bits[31:24].
 *
 * Ports:
 *  clk         - Clock. Used only for internal checkers and assertions
 *  reset_n     - Asynchronous active-low reset. Used only for internal checkers
 *                and assertions
 */
interface logic_avalon_st_if #(
    int SYMBOLS_PER_BEAT = 1,
    int DATA_BITS_PER_SYMBOL = 8,
    int EMPTY_WIDTH = (SYMBOLS_PER_BEAT >= 2) ? $clog2(SYMBOLS_PER_BEAT) : 1,
    int MAX_CHANNEL = 0,
    int CHANNEL_WIDTH = (MAX_CHANNEL >= 1) ? $clog2(MAX_CHANNEL + 1) : 1,
    int ERROR_WIDTH = 1,
    int EMPTY_WITHIN_PACKET = 0,
    int FIRST_SYMBOL_IN_HIGH_ORDER_BITS = 0
) (
    input clk,
    input reset_n
);
    initial begin: design_rule_checks
        `LOGIC_DRC_RANGE(SYMBOLS_PER_BEAT, 1, 32)
        `LOGIC_DRC_RANGE(DATA_BITS_PER_SYMBOL, 1, 512)
        `LOGIC_DRC_RANGE(MAX_CHANNEL, 0, 255)
        `LOGIC_DRC_TRUE_FALSE(EMPTY_WITHIN_PACKET)
        `LOGIC_DRC_TRUE_FALSE(FIRST_SYMBOL_IN_HIGH_ORDER_BITS)
    end

    localparam int DATA_WIDTH = SYMBOLS_PER_BEAT * DATA_BITS_PER_SYMBOL;

    localparam int M_DATA_WIDTH = (DATA_WIDTH > 0) ? DATA_WIDTH : 1;
    localparam int M_EMPTY_WIDTH = (EMPTY_WIDTH > 0) ? EMPTY_WIDTH : 1;
    localparam int M_ERROR_WIDTH = (ERROR_WIDTH > 0) ? ERROR_WIDTH : 1;
    localparam int M_CHANNEL_WIDTH = (CHANNEL_WIDTH > 0) ? CHANNEL_WIDTH : 1;

    localparam int M_SYMBOLS_PER_BEAT = (SYMBOLS_PER_BEAT > 0) ?
        SYMBOLS_PER_BEAT : 1;

    localparam int M_DATA_BITS_PER_SYMBOL = (DATA_BITS_PER_SYMBOL > 0) ?
        DATA_BITS_PER_SYMBOL : 1;

    typedef logic [M_SYMBOLS_PER_BEAT-1:0][M_DATA_BITS_PER_SYMBOL-1:0] data_t;
    typedef logic [M_EMPTY_WIDTH-1:0] empty_t;
    typedef logic [M_ERROR_WIDTH-1:0] error_t;
    typedef logic [M_CHANNEL_WIDTH-1:0] channel_t;

`ifdef SYNTHESIS
    logic ready;
    logic valid;
    logic startofpacket;
    logic endofpacket;
    channel_t channel;
    error_t error;
    empty_t empty;
    data_t data;
`else
    logic ready = 'X;
    logic valid = 'X;
    logic startofpacket = 'X;
    logic endofpacket = 'X;
    channel_t channel = 'X;
    error_t error = 'X;
    empty_t empty = 'X;
    data_t data = 'X;
`endif

`ifndef LOGIC_MODPORT_DISABLED
    modport rx (
        output ready,
        input valid,
        input startofpacket,
        input endofpacket,
        input channel,
        input error,
        input empty,
        input data
    );

    modport tx (
        input ready,
        output valid,
        output startofpacket,
        output endofpacket,
        output channel,
        output error,
        output empty,
        output data
    );

    modport monitor (
        input ready,
        input valid,
        input startofpacket,
        input endofpacket,
        input channel,
        input error,
        input empty,
        input data
    );
`endif

`ifndef SYNTHESIS
    clocking cb_rx @(posedge clk);
        input ready;
        output valid;
        output startofpacket;
        output endofpacket;
        output channel;
        output error;
        output empty;
        output data;
    endclocking

    modport cb_rx_modport (
        input reset_n,
        clocking cb_rx
    );

    clocking cb_tx @(posedge clk);
        inout ready;
        input valid;
        input startofpacket;
        input endofpacket;
        input channel;
        input error;
        input empty;
        input data;
    endclocking

    modport cb_tx_modport (
        input reset_n,
        clocking cb_tx
    );

    clocking cb_monitor @(posedge clk);
        input ready;
        input valid;
        input startofpacket;
        input endofpacket;
        input channel;
        input error;
        input empty;
        input data;
    endclocking

    modport cb_monitor_modport (
        input reset_n,
        clocking cb_monitor
    );
`endif

`ifdef OVL_ASSERT_ON
    generate
        if (1) begin: assertions
            logic bus_hold;
            logic bus_hold_start;
            logic bus_hold_end;

            always_comb bus_hold_start = !bus_hold && valid && !ready;
            always_comb bus_hold_end = bus_hold && ready;

            always_ff @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    bus_hold <= '0;
                end
                else if (bus_hold_start) begin
                    bus_hold <= '1;
                end
                else if (bus_hold_end) begin
                    bus_hold <= '0;
                end
            end

            /* verilator coverage_off */
            /* verilator lint_off UNUSED */
            genvar k;

            logic [`OVL_FIRE_WIDTH-1:0] assert_valid_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("valid signal always must be in known 0 or 1 state")
            )
            assert_valid_never_unknown (
                .clock(clk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(valid),
                .fire(assert_valid_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_ready_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("ready signal always must be in known 0 or 1 state")
            )
            assert_ready_never_unknown (
                .clock(clk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(ready),
                .fire(assert_ready_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_data_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .width(M_DATA_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("data signal cannot be unknown during active transfer")
            )
            assert_data_never_unknown (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .qualifier(valid),
                .test_expr(data),
                .fire(assert_data_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_empty_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .width(M_EMPTY_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("empty signal cannot be unknown during active transfer")
            )
            assert_empty_never_unknown (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .qualifier(valid),
                .test_expr(empty),
                .fire(assert_empty_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_startofpacket_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("startofpacket signal cannot be unknown")
            )
            assert_startofpacket_never_unknown (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .qualifier(valid),
                .test_expr(startofpacket),
                .fire(assert_startofpacket_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_endofpacket_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("endofpacket signal cannot be unknown")
            )
            assert_endofpacket_never_unknown (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .qualifier(valid),
                .test_expr(endofpacket),
                .fire(assert_endofpacket_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_error_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .width(M_ERROR_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("error signal cannot be unknown during active transfer")
            )
            assert_error_never_unknown (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .qualifier(valid),
                .test_expr(error),
                .fire(assert_error_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_channel_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .width(M_CHANNEL_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("channel signal cannot be unknown during active transfer")
            )
            assert_channel_never_unknown (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .qualifier(valid),
                .test_expr(channel),
                .fire(assert_channel_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_valid_always_reset_fire;

            ovl_always #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("valid signal must be low during reset phase")
            )
            assert_valid_always_reset (
                .clock(clk),
                .reset(!reset_n),
                .enable(1'b1),
                .test_expr(!valid),
                .fire(assert_valid_always_reset_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_valid_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("valid signal cannot change value during bus hold")
            )
            assert_valid_unchange (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(valid),
                .end_event(bus_hold_end),
                .fire(assert_valid_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_startofpacket_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("startofpacket signal cannot change value during bus hold")
            )
            assert_startofpacket_unchange (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(startofpacket),
                .end_event(bus_hold_end),
                .fire(assert_startofpacket_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_endofpacket_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("endofpacket signal cannot change value during bus hold")
            )
            assert_endofpacket_unchange (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(endofpacket),
                .end_event(bus_hold_end),
                .fire(assert_endofpacket_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_data_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .width(M_DATA_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("data signal cannot change value during bus hold")
            )
            assert_data_unchange (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(data),
                .end_event(bus_hold_end),
                .fire(assert_data_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_empty_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .width(M_EMPTY_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("empty signal cannot change value during bus hold")
            )
            assert_empty_unchange (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(empty),
                .end_event(bus_hold_end),
                .fire(assert_empty_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_error_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .width(M_ERROR_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("error signal cannot change value during bus hold")
            )
            assert_error_unchange (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(error),
                .end_event(bus_hold_end),
                .fire(assert_error_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_channel_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .width(M_CHANNEL_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("channel signal cannot change value during bus hold")
            )
            assert_channel_unchange (
                .clock(clk),
                .reset(reset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(channel),
                .end_event(bus_hold_end),
                .fire(assert_channel_unchange_fire)
            );

            logic _unused_assert_fires = &{
                1'b0,
                assert_valid_always_reset_fire,
                assert_valid_unchange_fire,
                assert_endofpacket_unchange_fire,
                assert_data_unchange_fire,
                assert_empty_unchange_fire,
                assert_error_unchange_fire,
                assert_channel_unchange_fire,
                1'b0
            };
            /* verilator lint_on UNUSED */
            /* verilator coverage_on */
        end
    endgenerate
`endif

`ifdef VERILATOR
    logic _unused_ports = &{1'b0, clk, reset_n, 1'b0};
`endif
endinterface

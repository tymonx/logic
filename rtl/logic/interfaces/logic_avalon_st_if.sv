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
    int FIRST_SYMBOL_IN_HIGH_ORDER_BITS = 1
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

    localparam DATA_WIDTH = SYMBOLS_PER_BEAT * DATA_BITS_PER_SYMBOL;

    typedef logic [SYMBOLS_PER_BEAT-1:0][DATA_BITS_PER_SYMBOL-1:0] data_t;
    typedef logic [EMPTY_WIDTH-1:0] empty_t;
    typedef logic [ERROR_WIDTH-1:0] error_t;
    typedef logic [CHANNEL_WIDTH-1:0] channel_t;

    typedef struct packed {
        logic startofpacket;
        logic endofpacket;
        channel_t channel;
        error_t error;
        empty_t empty;
        data_t data;
    } packet_t;

`ifndef LOGIC_SYNTHESIS
    `define INIT = '0
`else
    `define INIT
`endif

    logic ready `INIT;
    logic valid `INIT;
    logic startofpacket `INIT;
    logic endofpacket `INIT;
    channel_t channel `INIT;
    error_t error `INIT;
    empty_t empty `INIT;
    data_t data `INIT;

    function packet_t read();
        return '{startofpacket, endofpacket, channel, error, empty, data};
    endfunction

    task write(input packet_t packet);
        {startofpacket, endofpacket, channel, error, empty, data} <= packet;
    endtask

    task comb_write(input packet_t packet);
        {startofpacket, endofpacket, channel, error, empty, data} = packet;
    endtask

`ifndef LOGIC_MODPORT_DISABLED
    modport rx (
        output ready,
        input valid,
        input startofpacket,
        input endofpacket,
        input channel,
        input error,
        input empty,
        input data,
        import read
    );

    modport tx (
        input ready,
        output valid,
        output startofpacket,
        output endofpacket,
        output channel,
        output error,
        output empty,
        output data,
        import write,
        import comb_write
    );

    modport monitor (
        input ready,
        input valid,
        input startofpacket,
        input endofpacket,
        input channel,
        input error,
        input empty,
        input data,
        import read
    );
`endif

`ifndef LOGIC_SYNTHESIS
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

    clocking cb_mon @(posedge clk);
        input ready;
        input valid;
        input startofpacket;
        input endofpacket;
        input channel;
        input error;
        input empty;
        input data;
    endclocking

    task automatic cb_rx_clear();
        cb_rx.error <= '0;
        cb_rx.channel <= '0;
        cb_rx.endofpacket <= '0;
        cb_rx.startofpacket <= '0;
        cb_rx.empty <= '0;
        cb_rx.data <= '0;
        cb_rx.valid <= '0;
    endtask

    task automatic cb_tx_clear();
        cb_tx.ready <= '0;
    endtask

    task automatic cb_write(const ref byte data[], input int ch = 0,
            int idle_max = 0, int idle_min = 0);
        int total_size = data.size();
        int index = 0;
        int idle = 0;

        if (0 == data.size()) begin
            return;
        end

        forever begin
            if (!reset_n) begin
                break;
            end
            else if (1'b1 === cb_rx.ready) begin
                if (0 == idle) begin
                    int data_empty = 0;

                    if (index >= total_size) begin
                        break;
                    end

                    idle = $urandom_range(idle_max, idle_min);

                    cb_rx.startofpacket <= !index;

                    for (int i = 0; i < SYMBOLS_PER_BEAT; ++i) begin
                        if (index < total_size) begin
                            cb_rx.data[i] <= data[index++];
                        end
                        else begin
                            cb_rx.data[i] <= '0;
                            ++data_empty;
                        end
                    end

                    cb_rx.empty <= empty_t'(data_empty);
                    cb_rx.channel <= channel_t'(ch);
                    cb_rx.endofpacket <= (index >= total_size);
                    cb_rx.valid <= '1;
                end
                else begin
                    --idle;
                    cb_rx.valid <= '0;
                end
            end
            @(cb_rx);
        end

        cb_rx.valid <= '0;
    endtask

    task automatic cb_read(ref byte data[], input int ch = 0,
            int idle_max = 0, int idle_min = 0);
        int idle = 0;
        byte q[$];

        cb_tx.ready <= '1;

        forever begin
            if (!reset_n) begin
                break;
            end
            else if ((1'b1 === cb_tx.ready) && (1'b1 === cb_tx.valid) &&
                    (channel_t'(ch) === cb_tx.channel)) begin
                int data_size = SYMBOLS_PER_BEAT;

                if (EMPTY_WITHIN_PACKET || (1'b1 === cb_tx.endofpacket)) begin
                    data_size -= cb_tx.empty;
                end

                if (1'b1 === cb_tx.startofpacket) begin
                    q.delete();
                end

                for (int i = 0; i < data_size; ++i) begin
                    q.push_back(byte'(cb_tx.data[i]));
                end

                if (1'b1 === cb_tx.endofpacket) begin
                    cb_tx.ready <= '1;
                    @(cb_tx);
                    break;
                end
            end

            if (0 == idle) begin
                idle = $urandom_range(idle_max, idle_min);
                cb_tx.ready <= '1;
            end
            else begin
                --idle;
                cb_tx.ready <= '0;
            end

            @(cb_tx);
        end

        cb_tx.ready <= '0;

        data = new [q.size()];
        foreach (q[i]) begin
            data[i] = q[i];
        end
    endtask
`endif

`ifndef LOGIC_STD_OVL_DISABLED
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
        .width(DATA_WIDTH),
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
        .width(EMPTY_WIDTH),
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
        .msg("startofpacket signal cannot be unknown during active transfer")
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
        .msg("endofpacket signal cannot be unknown during active transfer")
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
        .width(ERROR_WIDTH),
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
        .width(CHANNEL_WIDTH),
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
        .width(DATA_WIDTH),
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
        .width(EMPTY_WIDTH),
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
        .width(ERROR_WIDTH),
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
        .width(CHANNEL_WIDTH),
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
    /* verilator coverage_on */
`endif

`ifdef VERILATOR
    logic _unused_ports = &{1'b0, clk, reset_n, 1'b0};
`endif

endinterface

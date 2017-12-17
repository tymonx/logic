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

`ifndef LOGIC_STD_OVL_DISABLED
`include "std_ovl_defines.h"
`endif

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
    int MAX_CHANNEL = 0,
    int CHANNEL_WIDTH = (MAX_CHANNEL >= 1) ? $clog2(MAX_CHANNEL + 1) : 1,
    int ERROR_WIDTH = 1,
    int EMPTY_WITHIN_PACKET = 0,
    int FIRST_SYMBOL_IN_HIGH_ORDER_BITS = 1
) (
    /* verilator lint_off UNUSED */
    input clk,
    input reset_n
    /* verilator lint_on UNUSED */
);
    initial begin: design_rule_checks
        `LOGIC_DRC_RANGE(SYMBOLS_PER_BEAT, 1, 32)
        `LOGIC_DRC_RANGE(DATA_BITS_PER_SYMBOL, 1, 512)
        `LOGIC_DRC_RANGE(MAX_CHANNEL, 0, 255)
        `LOGIC_DRC_TRUE_FALSE(EMPTY_WITHIN_PACKET)
        `LOGIC_DRC_TRUE_FALSE(FIRST_SYMBOL_IN_HIGH_ORDER_BITS)
    end

    typedef logic [SYMBOLS_PER_BEAT-1:0][DATA_BITS_PER_SYMBOL-1:0] data_t;
    typedef logic [$clog2(SYMBOLS_PER_BEAT)-1:0] empty_t;
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

    logic ready;
    logic valid;
    logic startofpacket;
    logic endofpacket;
    channel_t channel;
    error_t error;
    empty_t empty;
    data_t data;

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

    modport mon (
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
        output ready;
        input valid;
        input startofpacket;
        input endofpacket;
        input channel;
        input error;
        input empty;
        input data;
    endclocking

    clocking cb_tx @(posedge clk);
        input ready;
        output valid;
        output startofpacket;
        output endofpacket;
        output channel;
        output error;
        output empty;
        output data;
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
`endif

endinterface

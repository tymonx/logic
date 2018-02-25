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

`ifndef LOGIC_AVALON_ST_DRIVER_TX_SVH
`define LOGIC_AVALON_ST_DRIVER_TX_SVH

/* Class: logic_avalon_st_driver_rx
 *
 * Avalon-ST Tx interface driver.
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
 *  ACTIVE               - Active or passive driver.
 */
class logic_avalon_st_driver_tx #(
    int SYMBOLS_PER_BEAT = 1,
    int DATA_BITS_PER_SYMBOL = 8,
    int EMPTY_WIDTH = (SYMBOLS_PER_BEAT >= 2) ? $clog2(SYMBOLS_PER_BEAT) : 1,
    int MAX_CHANNEL = 0,
    int CHANNEL_WIDTH = (MAX_CHANNEL >= 1) ? $clog2(MAX_CHANNEL + 1) : 1,
    int ERROR_WIDTH = 1,
    int EMPTY_WITHIN_PACKET = 0,
    int FIRST_SYMBOL_IN_HIGH_ORDER_BITS = 0,
    int ACTIVE = 1
);
    localparam int M_EMPTY_WIDTH = (EMPTY_WIDTH > 0) ? EMPTY_WIDTH : 1;
    localparam int M_ERROR_WIDTH = (ERROR_WIDTH > 0) ? ERROR_WIDTH : 1;
    localparam int M_CHANNEL_WIDTH = (CHANNEL_WIDTH > 0) ? CHANNEL_WIDTH : 1;

    typedef virtual logic_avalon_st_if #(
        .SYMBOLS_PER_BEAT(SYMBOLS_PER_BEAT),
        .DATA_BITS_PER_SYMBOL(DATA_BITS_PER_SYMBOL),
        .EMPTY_WIDTH(EMPTY_WIDTH),
        .MAX_CHANNEL(MAX_CHANNEL),
        .CHANNEL_WIDTH(CHANNEL_WIDTH),
        .ERROR_WIDTH(ERROR_WIDTH),
        .EMPTY_WITHIN_PACKET(EMPTY_WITHIN_PACKET),
        .FIRST_SYMBOL_IN_HIGH_ORDER_BITS(FIRST_SYMBOL_IN_HIGH_ORDER_BITS)
    ) .cb_tx_modport vif_t;

    typedef byte data_t[];
    typedef logic [M_EMPTY_WIDTH-1:0] empty_t;
    typedef logic [M_ERROR_WIDTH-1:0] error_t;
    typedef logic [M_CHANNEL_WIDTH-1:0] channel_t;
    typedef error_t errors_t[];

    extern function new(vif_t vif);

    extern task read(ref data_t data);

    extern function void set_channel(channel_t channel);

    extern function error_t get_error();

    extern function errors_t get_errors();

    extern function void set_timeout(int timeout);

    extern function void set_idle(int idle_min,
        int idle_max = idle_min);

    extern task clk_posedge(int value = 1);

    extern task ready(bit value = 1);

    extern task reset();

    local vif_t m_vif;
    local int m_idle_min;
    local int m_idle_max;
    local int m_timeout;
    local channel_t m_channel;
    local errors_t m_errors;
endclass

function logic_avalon_st_driver_tx::new(vif_t vif);
    m_vif = vif;
    m_idle_max = 0;
    m_idle_min = 0;
    m_timeout = 0;
    m_channel = '0;
    m_errors = new [0];
endfunction

task logic_avalon_st_driver_tx::reset();
    m_idle_max = 0;
    m_idle_min = 0;
    m_timeout = 0;
    m_channel = '0;
    m_errors = new [0];

    ready(0);
endtask

task logic_avalon_st_driver_tx::ready(bit value = 1);
    if (ACTIVE > 0) begin
        m_vif.cb_tx.ready <= value;
    end
endtask

function void logic_avalon_st_driver_tx::set_channel(channel_t channel);
    m_channel = channel;
endfunction

function logic_avalon_st_driver_tx::error_t
        logic_avalon_st_driver_tx::get_error();
    return (m_errors.size() > 0) ? m_errors[0] : '0;
endfunction

function logic_avalon_st_driver_tx::errors_t
        logic_avalon_st_driver_tx::get_errors();
    return m_errors;
endfunction

function void logic_avalon_st_driver_tx::set_timeout(int timeout);
    m_timeout = timeout;
endfunction

function void logic_avalon_st_driver_tx::set_idle(int idle_min,
        int idle_max = idle_min);
    m_idle_min = idle_min;
    m_idle_max = idle_max;
endfunction

task logic_avalon_st_driver_tx::clk_posedge(int value = 1);
    repeat (value) @(m_vif.cb_tx);
endtask

task logic_avalon_st_driver_tx::read(ref data_t data);
    bit is_running = 1;

    int idle = $urandom_range(m_idle_max, m_idle_min);
    int timeout = m_timeout;

    byte data_q[$];
    error_t errors_q[$];

    ready(1);

    while ((is_running || (0 != idle)) && (1'b1 === m_vif.reset_n)) begin
        if ((1'b1 === m_vif.cb_tx.ready) && (1'b1 === m_vif.cb_tx.valid) &&
            (m_channel === m_vif.cb_tx.channel))
        begin
            empty_t empty = m_vif.cb_tx.empty;

            if (m_vif.cb_tx.startofpacket) begin
                data_q.delete();
                errors_q.delete();
            end

            timeout = m_timeout;

            for (int i = 0; i < (SYMBOLS_PER_BEAT - empty); ++i) begin
                int n = i;

                if (0 != FIRST_SYMBOL_IN_HIGH_ORDER_BITS) begin
                    int n = SYMBOLS_PER_BEAT - 1 - i;
                end

                data_q.push_back(byte'(m_vif.cb_tx.data[i]));
            end

            errors_q.push_back(m_vif.cb_tx.error);

            is_running = !(1'b1 === m_vif.cb_tx.endofpacket);
        end

        if (is_running && (m_timeout != 0)) begin
            if (timeout != 0) begin
                --timeout;
            end
            else begin
                idle = 0;
                is_running = 0;
            end
        end

        if (0 == idle) begin
            idle = is_running ? $urandom_range(m_idle_max, m_idle_min) : 0;
            ready(1);
        end
        else begin
            --idle;
            ready(0);
        end

        @(m_vif.cb_tx);
    end

    ready(0);

    data = data_q;
    m_errors = errors_q;
endtask

`endif /* LOGIC_AVALON_ST_DRIVER_TX_SVH */

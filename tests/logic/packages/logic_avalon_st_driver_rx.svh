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

`ifndef LOGIC_AVALON_ST_DRIVER_RX_SVH
`define LOGIC_AVALON_ST_DRIVER_RX_SVH

/* Class: logic_avalon_st_driver_rx
 *
 * Avalon-ST Rx interface driver.
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
 */
class logic_avalon_st_driver_rx #(
    int SYMBOLS_PER_BEAT = 1,
    int DATA_BITS_PER_SYMBOL = 8,
    int EMPTY_WIDTH = (SYMBOLS_PER_BEAT >= 2) ? $clog2(SYMBOLS_PER_BEAT) : 1,
    int MAX_CHANNEL = 0,
    int CHANNEL_WIDTH = (MAX_CHANNEL >= 1) ? $clog2(MAX_CHANNEL + 1) : 1,
    int ERROR_WIDTH = 1,
    int EMPTY_WITHIN_PACKET = 0,
    int FIRST_SYMBOL_IN_HIGH_ORDER_BITS = 0
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
    ) .cb_rx_modport vif_t;

    typedef byte data_t[];
    typedef logic [M_EMPTY_WIDTH-1:0] empty_t;
    typedef logic [M_ERROR_WIDTH-1:0] error_t;
    typedef logic [M_CHANNEL_WIDTH-1:0] channel_t;
    typedef error_t errors_t[];

    extern function new(vif_t vif);

    extern task write(const ref data_t data);

    extern function void set_channel(channel_t channel);

    extern function void set_error(error_t error);

    extern function void set_errors(const ref errors_t errors);

    extern function void set_timeout(int timeout);

    extern function void set_idle(int idle_min, int idle_max = idle_min);

    extern task clk_posedge(int value = 1);

    extern task reset();

    local vif_t m_vif;
    local int m_idle_min;
    local int m_idle_max;
    local int m_timeout;
    local channel_t m_channel;
    local errors_t m_errors;
endclass

function logic_avalon_st_driver_rx::new(vif_t vif);
    m_vif = vif;
    m_idle_max = 0;
    m_idle_min = 0;
    m_timeout = 0;
    m_channel = '0;
    m_errors = new [0];
endfunction

task logic_avalon_st_driver_rx::reset();
    m_idle_max = 0;
    m_idle_min = 0;
    m_timeout = 0;
    m_channel = '0;
    m_errors = new [0];

    m_vif.cb_rx.valid <= '0;
    m_vif.cb_rx.startofpacket <= 'X;
    m_vif.cb_rx.endofpacket <= 'X;
    m_vif.cb_rx.channel <= 'X;
    m_vif.cb_rx.error <= 'X;
    m_vif.cb_rx.empty <= 'X;
    m_vif.cb_rx.data <= 'X;
endtask

function void logic_avalon_st_driver_rx::set_channel(channel_t channel);
    m_channel = channel;
endfunction

function void logic_avalon_st_driver_rx::set_error(error_t error);
    m_errors = new [1];
    m_errors[0] = error;
endfunction

function void logic_avalon_st_driver_rx::set_errors(
        const ref errors_t errors);
    m_errors = new [errors.size()] (errors);
endfunction

function void logic_avalon_st_driver_rx::set_timeout(int timeout);
    m_timeout = timeout;
endfunction

function void logic_avalon_st_driver_rx::set_idle(int idle_min,
        int idle_max = idle_min);
    m_idle_min = idle_min;
    m_idle_max = idle_max;
endfunction

task logic_avalon_st_driver_rx::clk_posedge(int value = 1);
    repeat (value) @(m_vif.cb_rx);
endtask

task logic_avalon_st_driver_rx::write(const ref data_t data);
    const int total_size = data.size();
    bit is_running = (total_size > 0);

    int idle = $urandom_range(m_idle_max, m_idle_min);
    int timeout = m_timeout;
    int transfer = 0;
    int index = 0;

    while (is_running && (1'b1 === m_vif.reset_n)) begin
        if (1'b1 === m_vif.cb_rx.ready) begin
            m_vif.cb_rx.valid <= '0;

            timeout = m_timeout;

            if (index >= total_size) begin
                is_running = 0;
            end
            else if (0 == idle) begin
                empty_t empty = SYMBOLS_PER_BEAT[$bits(empty_t)-1:0];
                idle = $urandom_range(m_idle_max, m_idle_min);

                m_vif.cb_rx.startofpacket <= (0 == index);

                for (int i = 0; i < SYMBOLS_PER_BEAT; ++i) begin
                    int n = i;

                    if (0 != FIRST_SYMBOL_IN_HIGH_ORDER_BITS) begin
                        n = SYMBOLS_PER_BEAT - 1 - i;
                    end

                    if (index < total_size) begin
                        --empty;
                        m_vif.cb_rx.data[n] <= data[index++];
                    end
                    else begin
                        m_vif.cb_rx.data[n] <= '0;
                    end
                end

                if (0 == SYMBOLS_PER_BEAT) begin
                    ++index;
                    m_vif.cb_rx.data <= '0;
                end

                if ((EMPTY_WITHIN_PACKET > 0) || (index >= total_size)) begin
                    m_vif.cb_rx.empty <= empty;
                end
                else begin
                    m_vif.cb_rx.empty <= '0;
                end

                if (transfer < m_errors.size()) begin
                    m_vif.cb_rx.error <= m_errors[transfer];
                end
                else begin
                    m_vif.cb_rx.error <= '0;
                end

                ++transfer;

                m_vif.cb_rx.channel <= m_channel;
                m_vif.cb_rx.endofpacket <= (index >= total_size);
                m_vif.cb_rx.valid <= '1;
            end
            else begin
                --idle;
            end
        end
        else if (0 != m_timeout) begin
            if (0 != timeout) begin
                --timeout;
            end
            else begin
                is_running = 0;
            end
        end
        @(m_vif.cb_rx);
    end

    m_vif.cb_rx.valid <= '0;
endtask

`endif /* LOGIC_AVALON_ST_DRIVER_RX_SVH */

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

`ifndef LOGIC_AXI4_STREAM_DRIVER_RX_SVH
`define LOGIC_AXI4_STREAM_DRIVER_RX_SVH

/* Class: logic_axi4_stream_driver_rx
 *
 * AXI4-Stream Rx interface driver.
 *
 * Parameters:
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *  USE_TLAST   - Enable or disable tlast signal.
 *  USE_TKEEP   - Enable or disable tkeep signal.
 *  USE_TSTRB   - Enable or disable tstrb signal.
 */
class logic_axi4_stream_driver_rx #(
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1
);
    localparam int M_TDEST_WIDTH = (TDEST_WIDTH > 0) ? TDEST_WIDTH : 1;
    localparam int M_TUSER_WIDTH = (TUSER_WIDTH > 0) ? TUSER_WIDTH : 1;
    localparam int M_TID_WIDTH = (TID_WIDTH > 0) ? TID_WIDTH : 1;

    typedef virtual logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    ) .cb_rx_modport vif_t;

    typedef byte data_t[];
    typedef bit [M_TID_WIDTH-1:0] tid_t;
    typedef bit [M_TDEST_WIDTH-1:0] tdest_t;
    typedef bit [M_TUSER_WIDTH-1:0] tuser_t;
    typedef tuser_t tuser_stream_t[];

    extern function new(vif_t vif);

    extern task write(const ref data_t data);

    extern function void set_id(tid_t id);

    extern function void set_destination(tdest_t dest);

    extern function void set_user_data(tuser_t user);

    extern function void set_user_stream(const ref tuser_stream_t user);

    extern function void set_timeout(int timeout);

    extern function void set_idle(int idle_min, int idle_max = idle_min);

    extern task aclk_posedge(int value = 1);

    extern task reset();

    local vif_t m_vif;
    local int m_idle_min;
    local int m_idle_max;
    local int m_timeout;
    local tid_t m_tid;
    local tdest_t m_tdest;
    local tuser_stream_t m_tuser;
endclass

function logic_axi4_stream_driver_rx::new(vif_t vif);
    m_vif = vif;
    m_idle_max = 0;
    m_idle_min = 0;
    m_timeout = 0;
    m_tid = '0;
    m_tdest = '0;
    m_tuser = new [0];
endfunction

task logic_axi4_stream_driver_rx::reset();
    m_idle_max = 0;
    m_idle_min = 0;
    m_timeout = 0;
    m_tid = '0;
    m_tdest = '0;
    m_tuser = new [0];

    m_vif.cb_rx.tvalid <= '0;
    m_vif.cb_rx.tlast <= 'X;
    m_vif.cb_rx.tdata <= 'X;
    m_vif.cb_rx.tstrb <= 'X;
    m_vif.cb_rx.tkeep <= 'X;
    m_vif.cb_rx.tuser <= 'X;
    m_vif.cb_rx.tid <= 'X;
endtask

function void logic_axi4_stream_driver_rx::set_id(tid_t id);
    m_tid = id;
endfunction

function void logic_axi4_stream_driver_rx::set_destination(tdest_t dest);
    m_tdest = dest;
endfunction

function void logic_axi4_stream_driver_rx::set_user_data(tuser_t user);
    m_tuser = new [1];
    m_tuser[0] = user;
endfunction

function void logic_axi4_stream_driver_rx::set_user_stream(
        const ref tuser_stream_t user);
    m_tuser = new [user.size()] (user);
endfunction

function void logic_axi4_stream_driver_rx::set_timeout(int timeout);
    m_timeout = timeout;
endfunction

function void logic_axi4_stream_driver_rx::set_idle(int idle_min,
        int idle_max = idle_min);
    m_idle_min = idle_min;
    m_idle_max = idle_max;
endfunction

task logic_axi4_stream_driver_rx::aclk_posedge(int value = 1);
    repeat (value) @(m_vif.cb_rx);
endtask

task logic_axi4_stream_driver_rx::write(const ref data_t data);
    const int total_size = data.size();
    bit is_running = (total_size > 0);

    int idle = $urandom_range(m_idle_max, m_idle_min);
    int timeout = m_timeout;
    int transfer = 0;
    int index = 0;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        if (1'b1 === m_vif.cb_rx.tready) begin
            m_vif.cb_rx.tvalid <= '0;

            timeout = m_timeout;

            if (index >= total_size) begin
                is_running = 0;
            end
            else if (0 == idle) begin
                idle = $urandom_range(m_idle_max, m_idle_min);

                for (int i = 0; i < TDATA_BYTES; ++i) begin
                    if (index < total_size) begin
                        m_vif.cb_rx.tkeep[i] <= '1;
                        m_vif.cb_rx.tstrb[i] <= '1;
                        m_vif.cb_rx.tdata[i] <= data[index++];
                    end
                    else begin
                        m_vif.cb_rx.tkeep[i] <= '0;
                        m_vif.cb_rx.tstrb[i] <= '0;
                        m_vif.cb_rx.tdata[i] <= '0;
                    end
                end

                if (0 == TDATA_BYTES) begin
                    ++index;
                    m_vif.cb_rx.tkeep <= '0;
                    m_vif.cb_rx.tstrb <= '0;
                    m_vif.cb_rx.tdata <= '0;
                end

                if (transfer < m_tuser.size()) begin
                    m_vif.cb_rx.tuser <= m_tuser[transfer];
                end
                else begin
                    m_vif.cb_rx.tuser <= '0;
                end

                ++transfer;

                m_vif.cb_rx.tid <= m_tid;
                m_vif.cb_rx.tdest <= m_tdest;
                m_vif.cb_rx.tlast <= (index >= total_size);
                m_vif.cb_rx.tvalid <= '1;
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

    m_vif.cb_rx.tvalid <= '0;
endtask

`endif /* LOGIC_AXI4_STREAM_DRIVER_RX_SVH */

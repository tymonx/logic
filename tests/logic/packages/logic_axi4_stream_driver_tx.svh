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

`ifndef LOGIC_AXI4_STREAM_DRIVER_TX_SVH
`define LOGIC_AXI4_STREAM_DRIVER_TX_SVH

/* Class: logic_axi4_stream_driver_tx
 *
 * AXI4-Stream Tx interface driver.
 *
 * Parameters:
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *  USE_TLAST   - Enable or disable tlast signal.
 *  USE_TKEEP   - Enable or disable tkeep signal.
 *  USE_TSTRB   - Enable or disable tstrb signal.
 *  ACTIVE      - Active or passive driver.
 */
class logic_axi4_stream_driver_tx #(
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int ACTIVE = 1
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
    ) .cb_tx_modport vif_t;

    typedef byte data_t[];
    typedef bit [M_TID_WIDTH-1:0] tid_t;
    typedef bit [M_TDEST_WIDTH-1:0] tdest_t;
    typedef bit [M_TUSER_WIDTH-1:0] tuser_t;
    typedef tuser_t tuser_stream_t[];

    extern function new(vif_t vif);

    extern task read(ref byte data[]);

    extern function void set_id(tid_t id);

    extern function void set_destination(tdest_t dest);

    extern function tuser_t get_user_data();

    extern function tuser_stream_t get_user_stream();

    extern function void set_timeout(int timeout);

    extern function void set_idle(int idle_min,
        int idle_max = idle_min);

    extern task ready(bit value = 1);

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

function logic_axi4_stream_driver_tx::new(vif_t vif);
    m_vif = vif;
    m_idle_max = 0;
    m_idle_min = 0;
    m_timeout = 0;
    m_tid = '0;
    m_tdest = '0;
    m_tuser = new [0];
endfunction

task logic_axi4_stream_driver_tx::reset();
    m_idle_max = 0;
    m_idle_min = 0;
    m_timeout = 0;
    m_tid = '0;
    m_tdest = '0;
    m_tuser = new [0];

    ready(0);
endtask

task logic_axi4_stream_driver_tx::ready(bit value = 1);
    if (ACTIVE > 0) begin
        m_vif.cb_tx.tready <= value;
    end
endtask

function void logic_axi4_stream_driver_tx::set_id(tid_t id);
    m_tid = id;
endfunction

function void logic_axi4_stream_driver_tx::set_destination(tdest_t dest);
    m_tdest = dest;
endfunction

function logic_axi4_stream_driver_tx::tuser_t
        logic_axi4_stream_driver_tx::get_user_data();
    return (m_tuser.size() > 0) ? m_tuser[0] : '0;
endfunction

function logic_axi4_stream_driver_tx::tuser_stream_t
        logic_axi4_stream_driver_tx::get_user_stream();
    return m_tuser;
endfunction

function void logic_axi4_stream_driver_tx::set_timeout(int timeout);
    m_timeout = timeout;
endfunction

function void logic_axi4_stream_driver_tx::set_idle(int idle_min,
        int idle_max = idle_min);
    m_idle_min = idle_min;
    m_idle_max = idle_max;
endfunction

task logic_axi4_stream_driver_tx::aclk_posedge(int value = 1);
    repeat (value) @(m_vif.cb_tx);
endtask

task logic_axi4_stream_driver_tx::read(ref data_t data);
    bit is_running = 1;

    int idle = $urandom_range(m_idle_max, m_idle_min);
    int timeout = m_timeout;

    byte data_q[$];
    tuser_t user_q[$];

    ready(1);

    while ((is_running || (0 != idle)) && (1'b1 === m_vif.areset_n)) begin
        if ((1'b1 === m_vif.cb_tx.tready) && (1'b1 === m_vif.cb_tx.tvalid) &&
            (m_tid === m_vif.cb_tx.tid) && (m_tdest === m_vif.cb_tx.tdest))
        begin
            timeout = m_timeout;

            for (int i = 0; i < TDATA_BYTES; ++i) begin
                if ((1'b1 === m_vif.cb_tx.tkeep[i]) &&
                        (1'b1 === m_vif.cb_tx.tstrb[i])) begin
                    data_q.push_back(byte'(m_vif.cb_tx.tdata[i]));
                end
            end

            user_q.push_back(m_vif.cb_tx.tuser);

            is_running = !(1'b1 === m_vif.cb_tx.tlast);
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
    m_tuser = user_q;
endtask

`endif /* LOGIC_AXI4_STREAM_DRIVER_TX_SVH */

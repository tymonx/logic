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

/* Interface: logic_axi4_stream_driver_rx
 *
 * AXI4-Stream interface.
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
    typedef virtual logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TDEST_WIDTH(TDEST_WIDTH),
        .TUSER_WIDTH(TUSER_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .USE_TLAST(USE_TLAST),
        .USE_TKEEP(USE_TKEEP),
        .USE_TSTRB(USE_TSTRB)
    ) .rx vif_t;

    typedef bit [TID_WIDTH-1:0] tid_t;
    typedef bit [TDEST_WIDTH-1:0] tdest_t;
    typedef bit [TUSER_WIDTH-1:0] tuser_t;

    extern function new(vif_t vif);

    extern task write(const ref byte data[]);

    extern function void set_id(tid_t id);

    extern function void set_destination(tdest_t dest);

    extern function void set_user(const ref tuser_t user[]);

    extern function void set_timeout(int timeout);

    extern function void set_idle(int idle);

    extern function void set_idle_range(int idle_min, int idle_max);

    local vif_t m_vif;
    local int m_idle_min;
    local int m_idle_max;
    local int m_timeout;
    local tid_t m_tid;
    local tdest_t m_tdest;
    local tuser_t m_tuser[];
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

function void logic_axi4_stream_driver_rx::set_id(tid_t id);
    m_tid = id;
endfunction

function void logic_axi4_stream_driver_rx::set_destination(tdest_t dest);
    m_tdest = dest;
endfunction

function void logic_axi4_stream_driver_rx::set_user(const ref tuser_t user[]);
    m_tuser = new [user.size()] (user);
endfunction

function void logic_axi4_stream_driver_rx::set_timeout(int timeout);
    m_timeout = timeout;
endfunction

function void logic_axi4_stream_driver_rx::set_idle(int idle);
    m_idle_min = idle;
    m_idle_max = idle;
endfunction

function void logic_axi4_stream_driver_rx::set_idle_range(
        int idle_min, int idle_max);
    m_idle_min = idle_min;
    m_idle_max = idle_max;
endfunction

task logic_axi4_stream_driver_rx::write(const ref byte data[]);
    int total_size = data.size();
    int timeout = m_timeout;
    int transfer = 0;
    int index = 0;
    int idle = 0;

    if (0 == data.size()) begin
        return;
    end

    forever begin
        if (!m_vif.areset_n) begin
            break;
        end
        else if (1'b1 === m_vif.cb.tready) begin
            timeout = m_timeout;

            if (index >= total_size) begin
                break;
            end
            else if (0 == idle) begin
                idle = $urandom_range(m_idle_max, m_idle_min);

                for (int i = 0; i < M_TDATA_BYTES; ++i) begin
                    if (index < total_size) begin
                        m_vif.cb.tkeep[i] <= '1;
                        m_vif.cb.tstrb[i] <= '1;
                        m_vif.cb.tdata[i] <= data[index++];
                    end
                    else begin
                        m_vif.cb.tkeep[i] <= '0;
                        m_vif.cb.tstrb[i] <= '0;
                        m_vif.cb.tdata[i] <= '0;
                    end
                end

                if (transfer < m_tuser.size()) begin
                    m_vif.cb.tuser <= m_tuser[transfer];
                end
                else begin
                    m_vif.cb.tuser <= '0;
                end

                ++transfer;

                m_vif.cb.tid <= tid_t'(m_tid);
                m_vif.cb.tdest <= tdest_t'(m_tdest);
                m_vif.cb.tlast <= (index >= total_size);
                m_vif.cb.tvalid <= '1;
            end
            else begin
                --idle;
                m_vif.cb.tvalid <= '0;
            end
        end
        else if (m_timeout > 0) begin
            if (timeout > 0) begin
                --timeout;
            end
            else begin
                break;
            end
        end
        @(m_vif.cb);
    end

    m_vif.cb.tvalid <= '0;
endtask



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

`ifndef LOGIC_AXI4_LITE_DRIVER_MASTER_SVH
`define LOGIC_AXI4_LITE_DRIVER_MASTER_SVH

/* Class: logic_axi4_lite_driver_master
 *
 * AXI4-Stream Master interface driver.
 *
 * Parameters:
 *  DATA_BYTES      - Number of bytes for data signals.
 *  ADDRESS_WIDTH   - Number of bits for address signals.
 */
class logic_axi4_lite_driver_master #(
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1
);
    typedef virtual logic_axi4_lite_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) .cb_master_modport vif_t;

    typedef logic_axi4_lite_pkg::access_t access_t;
    typedef logic_axi4_lite_pkg::response_t response_t;
    typedef bit [DATA_BYTES-1:0] byte_enable_t;
    typedef bit [DATA_BYTES-1:0][7:0] data_t;
    typedef bit [ADDRESS_WIDTH-1:0] address_t;

    extern function new(vif_t vif);

    extern task reset();

    extern function void set_timeout(int value);

    extern task write_request_data(ref data_t data,
        ref byte_enable_t byte_enable);

    extern task write_request_address(ref address_t address,
        ref access_t access);

    extern task write_request(ref address_t address, ref data_t data,
        ref byte_enable_t byte_enable, ref access_t access);

    extern task write_response(response_t response);

    extern task write_ready(bit value = 1);

    extern task read_request(ref address_t address,
        ref access_t access);

    extern task read_response(data_t data,
        response_t response = logic_axi4_lite_pkg::RESPONSE_OKAY);

    extern task read_ready(bit value = 1);

    extern task aclk_posedge(int count = 1);

    local vif_t m_vif;
    local int m_timeout;
endclass

function logic_axi4_lite_driver_master::new(vif_t vif);
    m_vif = vif;
    m_timeout = 0;
endfunction

function void logic_axi4_lite_driver_master::set_timeout(int value);
    m_timeout = value;
endfunction

task logic_axi4_lite_driver_master::reset();
    m_vif.cb_master.wready <= 1'b0;
    m_vif.cb_master.awready <= 1'b0;
    m_vif.cb_master.arready <= 1'b0;
    m_vif.cb_master.rvalid <= 1'b0;
    m_vif.cb_master.rdata <= 'X;
    m_vif.cb_master.rresp <= response_t'('X);
    m_vif.cb_master.bvalid <= 1'b0;
    m_vif.cb_master.bresp <= response_t'('X);
endtask

task logic_axi4_lite_driver_master::write_request_data(ref data_t data,
        ref byte_enable_t byte_enable);
    bit is_running = 1;
    int timeout = (m_timeout > 0) ? m_timeout : -1;

    data = '0;
    byte_enable = '0;

    m_vif.cb_master.wready <= 1;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        aclk_posedge();

        if ((1'b1 === m_vif.cb_master.wvalid) &&
                (1'b1 === m_vif.cb_master.wready)) begin
            data = m_vif.cb_master.wdata;
            byte_enable = m_vif.cb_master.wstrb;
            is_running = 0;
        end
        else if (timeout > 0) begin
            --timeout;
        end
        else if (timeout == 0) begin
            is_running = 0;
        end
    end

    m_vif.cb_master.wready <= 0;
endtask

task logic_axi4_lite_driver_master::write_request_address(ref address_t address,
        ref access_t access);
    bit is_running = 1;
    int timeout = (m_timeout > 0) ? m_timeout : -1;

    address = '0;
    access = logic_axi4_lite_pkg::DEFAULT_DATA_ACCESS;

    m_vif.cb_master.awready <= 1;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        aclk_posedge();

        if ((1'b1 === m_vif.cb_master.awvalid) &&
                (1'b1 === m_vif.cb_master.awready)) begin
            address = m_vif.cb_master.awaddr;
            access = m_vif.cb_master.awprot;
            is_running = 0;
        end
        else if (timeout > 0) begin
            --timeout;
        end
        else if (timeout == 0) begin
            is_running = 0;
        end
    end

    m_vif.cb_master.awready <= 0;
endtask

task logic_axi4_lite_driver_master::write_request(ref address_t address,
        ref data_t data, ref byte_enable_t byte_enable, ref access_t access);
    address_t r_address;
    data_t r_data;
    byte_enable_t r_byte_enable;
    access_t r_access;

    fork
        write_request_data(r_data, r_byte_enable);
        write_request_address(r_address, r_access);
    join

    address = r_address;
    data = r_data;
    byte_enable = r_byte_enable;
    access = r_access;
endtask

task logic_axi4_lite_driver_master::write_response(response_t response);
    bit is_running = 1;
    int timeout = (m_timeout > 0) ? m_timeout : -1;

    m_vif.cb_master.bresp <= response;
    m_vif.cb_master.bvalid <= 1;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        aclk_posedge();

        if ((1'b1 === m_vif.cb_master.bvalid) &&
                (1'b1 === m_vif.cb_master.bready)) begin
            is_running = 0;
        end
        else if (timeout > 0) begin
            --timeout;
        end
        else if (timeout == 0) begin
            is_running = 0;
        end
    end

    m_vif.cb_master.bvalid <= 0;
endtask

task logic_axi4_lite_driver_master::write_ready(bit value = 1);
    m_vif.cb_master.wready <= value;
    m_vif.cb_master.awready <= value;
endtask

task logic_axi4_lite_driver_master::read_request(ref address_t address,
        ref access_t access);
    bit is_running = 1;
    int timeout = (m_timeout > 0) ? m_timeout : -1;

    address = '0;
    access = logic_axi4_lite_pkg::DEFAULT_DATA_ACCESS;

    m_vif.cb_master.arready <= 1;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        aclk_posedge();

        if ((1'b1 === m_vif.cb_master.arvalid) &&
                (1'b1 === m_vif.cb_master.arready)) begin
            address = m_vif.cb_master.araddr;
            access = m_vif.cb_master.arprot;
            is_running = 0;
        end
        else if (timeout > 0) begin
            --timeout;
        end
        else if (timeout == 0) begin
            is_running = 0;
        end
    end

    m_vif.cb_master.arready <= 0;
endtask

task logic_axi4_lite_driver_master::read_response(data_t data,
        response_t response = logic_axi4_lite_pkg::RESPONSE_OKAY);
    bit is_running = 1;
    int timeout = (m_timeout > 0) ? m_timeout : -1;

    m_vif.cb_master.rdata <= data;
    m_vif.cb_master.rresp <= response;
    m_vif.cb_master.rvalid <= 1;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        aclk_posedge();

        if ((1'b1 === m_vif.cb_master.rvalid) &&
                (1'b1 === m_vif.cb_master.rready)) begin
            is_running = 0;
        end
        else if (timeout > 0) begin
            --timeout;
        end
        else if (timeout == 0) begin
            is_running = 0;
        end
    end

    m_vif.cb_master.rvalid <= 0;
endtask

task logic_axi4_lite_driver_master::read_ready(bit value = 1);
    m_vif.cb_master.arready <= value;
endtask

task logic_axi4_lite_driver_master::aclk_posedge(int count = 1);
    while (count--) begin
        @(m_vif.cb_master);
    end
endtask

`endif /* LOGIC_AXI4_LITE_DRIVER_MASTER_SVH */

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

`ifndef LOGIC_AXI4_LITE_DRIVER_SLAVE_SVH
`define LOGIC_AXI4_LITE_DRIVER_SLAVE_SVH

/* Class: logic_axi4_lite_driver_slave
 *
 * AXI4-Lite Slave interface driver.
 *
 * Parameters:
 *  DATA_BYTES      - Number of bytes for data signals.
 *  ADDRESS_WIDTH   - Number of bits for address signals.
 */
class logic_axi4_lite_driver_slave #(
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1
);
    typedef virtual logic_axi4_lite_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) .cb_slave_modport vif_t;

    typedef logic_axi4_lite_pkg::access_t access_t;
    typedef logic_axi4_lite_pkg::response_t response_t;
    typedef bit [DATA_BYTES-1:0] byte_enable_t;
    typedef bit [DATA_BYTES-1:0][7:0] data_t;
    typedef bit [ADDRESS_WIDTH-1:0] address_t;

    extern function new(vif_t vif);

    extern task reset();

    extern function void set_timeout(int value);

    extern task write_request_data(data_t data,
        byte_enable_t byte_enable = '1);

    extern task write_request_address(address_t address,
        access_t access = logic_axi4_lite_pkg::DEFAULT_DATA_ACCESS);

    extern task write_request(address_t address, data_t data,
        byte_enable_t byte_enable = '1,
        access_t access = logic_axi4_lite_pkg::DEFAULT_DATA_ACCESS);

    extern task write_response(ref response_t response);

    extern task write_ready(bit value = 1);

    extern task read_request(address_t address,
        access_t access = logic_axi4_lite_pkg::DEFAULT_DATA_ACCESS);

    extern task read_response(ref data_t data, ref response_t response);

    extern task read_ready(bit value = 1);

    extern task aclk_posedge(int count = 1);

    local vif_t m_vif;
    local int m_timeout;
endclass

function logic_axi4_lite_driver_slave::new(vif_t vif);
    m_vif = vif;
    m_timeout = 0;
endfunction

function void logic_axi4_lite_driver_slave::set_timeout(int value);
    m_timeout = value;
endfunction

task logic_axi4_lite_driver_slave::reset();
    m_vif.cb_slave.wvalid <= 1'b0;
    m_vif.cb_slave.wdata <= 'X;
    m_vif.cb_slave.wstrb <= 'X;

    m_vif.cb_slave.awvalid <= 1'b0;
    m_vif.cb_slave.awaddr <= 'X;
    m_vif.cb_slave.awprot <= access_t'('X);

    m_vif.cb_slave.arvalid <= 1'b0;
    m_vif.cb_slave.araddr <= 'X;
    m_vif.cb_slave.arprot <= access_t'('X);

    m_vif.cb_slave.bready <= 1'b0;
    m_vif.cb_slave.rready <= 1'b0;
endtask

task logic_axi4_lite_driver_slave::write_request_data(data_t data,
        byte_enable_t byte_enable = '1);
    bit is_running = 1;
    int timeout = (m_timeout > 0) ? m_timeout : -1;

    m_vif.cb_slave.wdata <= data;
    m_vif.cb_slave.wstrb <= byte_enable;
    m_vif.cb_slave.wvalid <= 1;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        aclk_posedge();

        if ((1'b1 === m_vif.cb_slave.wvalid) &&
                (1'b1 === m_vif.cb_slave.wready)) begin
            is_running = 0;
        end
        else if (timeout > 0) begin
            --timeout;
        end
        else if (timeout == 0) begin
            is_running = 0;
        end
    end

    m_vif.cb_slave.wvalid <= 0;
endtask

task logic_axi4_lite_driver_slave::write_request_address(address_t address,
        access_t access = logic_axi4_lite_pkg::DEFAULT_DATA_ACCESS);
    bit is_running = 1;
    int timeout = (m_timeout > 0) ? m_timeout : -1;

    m_vif.cb_slave.awaddr <= address;
    m_vif.cb_slave.awprot <= access;
    m_vif.cb_slave.awvalid <= 1;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        aclk_posedge();

        if ((1'b1 === m_vif.cb_slave.awvalid) &&
                (1'b1 === m_vif.cb_slave.awready)) begin
            is_running = 0;
        end
        else if (timeout > 0) begin
            --timeout;
        end
        else if (timeout == 0) begin
            is_running = 0;
        end
    end

    m_vif.cb_slave.awvalid <= 0;
endtask

task logic_axi4_lite_driver_slave::write_request(address_t address, data_t data,
        byte_enable_t byte_enable = '1,
        access_t access = logic_axi4_lite_pkg::DEFAULT_DATA_ACCESS);
    fork
        write_request_data(data, byte_enable);
        write_request_address(address, access);
    join
endtask

task logic_axi4_lite_driver_slave::write_response(ref response_t response);
    bit is_running = 1;
    int timeout = (m_timeout > 0) ? m_timeout : -1;

    response = logic_axi4_lite_pkg::RESPONSE_OKAY;

    m_vif.cb_slave.bready <= 1;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        aclk_posedge();

        if ((1'b1 === m_vif.cb_slave.bvalid) &&
                (1'b1 === m_vif.cb_slave.bready)) begin
            is_running = 0;
            response = m_vif.cb_slave.bresp;
        end
        else if (timeout > 0) begin
            --timeout;
        end
        else if (timeout == 0) begin
            is_running = 0;
        end
    end

    m_vif.cb_slave.bready <= 0;
endtask

task logic_axi4_lite_driver_slave::write_ready(bit value = 1);
    m_vif.cb_slave.bready <= value;
endtask

task logic_axi4_lite_driver_slave::read_request(address_t address,
        access_t access = logic_axi4_lite_pkg::DEFAULT_DATA_ACCESS);
    bit is_running = 1;
    int timeout = (m_timeout > 0) ? m_timeout : -1;

    m_vif.cb_slave.araddr <= address;
    m_vif.cb_slave.arprot <= access;
    m_vif.cb_slave.arvalid <= 1;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        aclk_posedge();

        if ((1'b1 === m_vif.cb_slave.arvalid) &&
                (1'b1 === m_vif.cb_slave.arready)) begin
            is_running = 0;
        end
        else if (timeout > 0) begin
            --timeout;
        end
        else if (timeout == 0) begin
            is_running = 0;
        end
    end

    m_vif.cb_slave.arvalid <= 0;
endtask

task logic_axi4_lite_driver_slave::read_response(ref data_t data,
        ref response_t response);
    bit is_running = 1;
    int timeout = (m_timeout > 0) ? m_timeout : -1;

    data = '0;
    response = logic_axi4_lite_pkg::RESPONSE_OKAY;

    m_vif.cb_slave.rready <= 1;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        aclk_posedge();

        if ((1'b1 === m_vif.cb_slave.rvalid) &&
                (1'b1 === m_vif.cb_slave.rready)) begin
            is_running = 0;
            data = m_vif.cb_slave.rdata;
            response = m_vif.cb_slave.rresp;
        end
        else if (timeout > 0) begin
            --timeout;
        end
        else if (timeout == 0) begin
            is_running = 0;
        end
    end

    m_vif.cb_slave.rready <= 0;
endtask

task logic_axi4_lite_driver_slave::read_ready(bit value = 1);
    m_vif.cb_slave.rready <= value;
endtask

task logic_axi4_lite_driver_slave::aclk_posedge(int count = 1);
    while (count--) begin
        @(m_vif.cb_slave);
    end
endtask

`endif /* LOGIC_AXI4_LITE_DRIVER_SLAVE_SVH */

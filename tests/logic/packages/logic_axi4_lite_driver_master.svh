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

/* Class: logic_axi4_lite_driver_master
 *
 * AXI4-Stream Master interface driver.
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
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
    ) .cb_slave_modport vif_t;

    typedef logic [DATA_BYTES-1:0] byte_enable_t;
    typedef logic [DATA_BYTES-1:0][7:0] data_t;
    typedef logic [ADDRESS_WIDTH-1:0] address_t;

    typedef logic_axi4_lite_pkg::access_t access_t;
    typedef logic_axi4_lite_pkg::response_t response_t;

    extern function new(vif_t vif);

    extern task write_data(data_t data, byte_enable_t byte_enable = '1);

    extern task write_address(address_t address,
        access_t access = logic_axi4_lite_pkg::DEFAULT_DATA_ACCESS);

    extern task aclk_posedge(int count = 1);

    local vif_t m_vif;
endclass

function logic_axi4_lite_driver_slave::new(vif_t vif);
    m_vif = vif
endfunction

task logic_axi4_lite_driver_slave::write_data(data_t data,
        byte_enable_t byte_enable);
    bit is_running = 1;

    m_vif.cb_slave.wdata <= data;
    m_vif.cb_slave.wstrb <= byte_enable;
    m_vif.sb_slave.wvalid <= 1;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        aclk_posedge();

        is_running = !((1'b1 === m_vif.cb_slave.wvalid) &&
            (1'b1 === m_vif.cb_slave.wready));
    end

    m_vif.cb_slave.wvalid <= 0;
endtask

task logic_axi4_lite_driver_slave::write_address(address_t address,
        access_t access);
    bit is_running = 1;

    m_vif.cb_slave.awaddr <= address;
    m_vif.cb_slave.awprot <= access;
    m_vif.sb_slave.awvalid <= 1;

    while (is_running && (1'b1 === m_vif.areset_n)) begin
        aclk_posedge();

        is_running = !((1'b1 === m_vif.cb_slave.awvalid) &&
            (1'b1 === m_vif.cb_slave.awready));
    end

    m_vif.cb_slave.awvalid <= 0;
endtask

task logic_axi4_lite_driver_slave::aclk_posedge(int count);
    while (count--) begin
        @(m_vif.cb_slave);
    end
endtask

`endif /* LOGIC_AXI4_LITE_DRIVER_SLAVE_SVH */

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

/* Module: logic_axi4_lite_bus_to_stream
 *
 * Translate AXI4-Lite interface to seperate AXI4-Stream interfaces.
 */
module logic_axi4_lite_bus_to_stream (
    `LOGIC_MODPORT(logic_axi4_lite_if, slave) slave,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) write_data,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) write_address,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) write_response,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) read_address,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) read_data
);
    import logic_axi4_lite_pkg::response_t;

    always_comb write_data.tvalid = slave.wvalid;
    always_comb write_data.tlast = '1;
    always_comb write_data.tstrb = slave.wstrb;
    always_comb write_data.tkeep = slave.wstrb;
    always_comb write_data.tdata = slave.wdata;
    always_comb write_data.tuser = '0;
    always_comb write_data.tdest = '0;
    always_comb write_data.tid = '0;
    always_comb slave.wready = write_data.tready;

    always_comb write_address.tvalid = slave.awvalid;
    always_comb write_address.tlast = '1;
    always_comb write_address.tstrb = '1;
    always_comb write_address.tkeep = '1;
    always_comb write_address.tdata = '0;
    always_comb write_address.tuser = slave.awprot;
    always_comb write_address.tdest = slave.awaddr;
    always_comb write_address.tid = '0;
    always_comb slave.awready = write_address.tready;

    always_comb slave.bvalid = write_response.tvalid;
    always_comb slave.bresp = response_t'(write_response.tuser);
    always_comb write_response.bready = write_response.tready;

    always_comb read_address.tvalid = slave.arvalid;
    always_comb read_address.tlast = '1;
    always_comb read_address.tstrb = '1;
    always_comb read_address.tkeep = '1;
    always_comb read_address.tdata = '0;
    always_comb read_address.tuser = slave.arprot;
    always_comb read_address.tdest = slave.araddr;
    always_comb read_address.tid = '0;
    always_comb slave.arready = read_address.tready;

    always_comb slave.rvalid = read_data.tvalid;
    always_comb slave.rdata = read_data.tdata;
    always_comb slave.rresp = data_t'(read_data.tuser);
    always_comb read_data.rready = read_data.tready;

`ifdef VERILATOR
    logic _unused_ports = &{
        1'b0,
        write_response.tlast,
        write_response.tdata,
        write_response.tstrb,
        write_response.tkeep,
        write_response.tdest,
        write_response.tid,
        read_data.tlast,
        read_data.tdata,
        read_data.tstrb,
        read_data.tkeep,
        read_data.tdest,
        read_data.tid,
        1'b0
    };
`endif
endmodule

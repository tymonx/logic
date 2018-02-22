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

/* Interface: logic_avalon_mm_if
 *
 * Avalon-MM interface.
 *
 * Parameters:
 *  DATA_BYTES      - Number of bytes for writedata and readdata signals.
 *  ADDRESS_WIDTH   - Number of bits for address signal.
 *
 * Ports:
 *  clk         - Clock. Used only for internal checkers and assertions
 *  reset_n     - Asynchronous active-low reset. Used only for internal checkers
 *                and assertions
 */
interface logic_avalon_mm_if #(
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1
) (
    input clk,
    input reset_n
);
    import logic_avalon_mm_pkg::response_t;

    initial begin: design_rule_checks
        `LOGIC_DRC_RANGE(ADDRESS_WIDTH, 1, 64)
        `LOGIC_DRC_RANGE(DATA_BYTES, 1, 128)
        `LOGIC_DRC_POWER_OF_2(DATA_BYTES)
    end

    typedef logic [DATA_BYTES-1:0][7:0] data_t;
    typedef logic [DATA_BYTES-1:0] byteenable_t;
    typedef logic [ADDRESS_WIDTH-1:0] address_t;

`ifndef SYNTHESIS
    `define INIT = '0
    `define INIT_RESPONSE = response_t'('0)
`else
    `define INIT
    `define INIT_RESPONSE
`endif

    logic read `INIT;
    logic write `INIT;
    logic waitrequest `INIT;
    logic readdatavalid `INIT;
    logic writeresponsevalid `INIT;
    data_t readdata `INIT;
    data_t writedata `INIT;
    address_t address `INIT;
    response_t response `INIT_RESPONSE;
    byteenable_t byteenable `INIT;

`ifndef LOGIC_MODPORT_DISABLED
    modport slave (
        input read,
        input write,
        input address,
        input writedata,
        input byteenable,
        output response,
        output readdata,
        output waitrequest,
        output readdatavalid,
        output writeresponsevalid
    );

    modport master (
        output read,
        output write,
        output address,
        output writedata,
        output byteenable,
        input response,
        input readdata,
        input waitrequest,
        input readdatavalid,
        input writeresponsevalid
    );

    modport monitor (
        input read,
        input write,
        input address,
        input writedata,
        input byteenable,
        input response,
        input readdata,
        input waitrequest,
        input readdatavalid,
        input writeresponsevalid
    );
`endif

`ifndef SYNTHESIS
    clocking cb_slave @(posedge clk);
        output read;
        output write;
        output address;
        output writedata;
        output byteenable;
        input response;
        input readdata;
        input waitrequest;
        input readdatavalid;
        input writeresponsevalid;
    endclocking

    clocking cb_master @(posedge clk);
        input read;
        input write;
        input address;
        input writedata;
        input byteenable;
        output response;
        output readdata;
        output waitrequest;
        output readdatavalid;
        output writeresponsevalid;
    endclocking

    clocking cb_monitor @(posedge clk);
        input read;
        input write;
        input address;
        input writedata;
        input byteenable;
        input response;
        input readdata;
        input waitrequest;
        input readdatavalid;
        input writeresponsevalid;
    endclocking

    task automatic cb_slave_write_request(address_t addr, data_t data,
            byteenable_t enable = '1);
        bit sent = 0;

        forever begin
            if (!reset_n) begin
                break;
            end
            else if (1'b0 === cb_slave.waitrequest) begin
                if (sent) begin
                    break;
                end

                sent = 1;
                cb_slave.write <= 1;
                cb_slave.address <= addr;
                cb_slave.writedata <= data;
                cb_slave.byteenable <= enable;
            end
            @(cb_slave);
        end

        cb_slave.write <= 0;
    endtask

    task automatic cb_slave_write_response();
        forever begin
            if (!reset_n) begin
                break;
            end
            else if (1'b1 === cb_slave.writeresponsevalid) begin
                @(cb_slave);
                break;
            end
            @(cb_slave);
        end
    endtask

    task automatic cb_slave_read_request(address_t addr,
            byteenable_t enable = '1);
        bit sent = 0;

        forever begin
            if (!reset_n) begin
                break;
            end
            else if (1'b0 === cb_slave.waitrequest) begin
                if (sent) begin
                    break;
                end

                sent = 1;
                cb_slave.read <= 1;
                cb_slave.address <= addr;
                cb_slave.byteenable <= enable;
            end
            @(cb_slave);
        end

        cb_slave.read <= 0;
    endtask

    task automatic cb_slave_read_response(output data_t data);
        forever begin
            if (!reset_n) begin
                break;
            end
            else if (1'b1 === cb_slave.readdatavalid) begin
                data = cb_slave.readdata;
                @(cb_slave);
                break;
            end
            @(cb_slave);
        end
    endtask
`endif

`ifdef VERILATOR
    logic _unused_ports = &{1'b0, clk, reset_n, 1'b0};
`endif

endinterface

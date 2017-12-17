/* Copyright 2017 Tymoteusz Blazejczyk
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

`ifndef LOGIC_STD_OVL_DISABLED
`include "std_ovl_defines.h"
`endif

/* Interface: logic_avalon_mm_if
 *
 * Avalon-MM interface.
 *  DATA_BYTES      - Number of bytes for writedata and readdata signals.
 *  ADDRESS_WIDTH   - Number of bits for address signal.
 *
 * Parameters:
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
    /* verilator lint_off UNUSED */
    input clk,
    input reset_n
    /* verilator lint_on UNUSED */
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

    logic read;
    logic write;
    logic waitrequest;
    logic readdatavalid;
    logic writeresponsevalid;
    data_t readdata;
    data_t writedata;
    address_t address;
    response_t response;
    byteenable_t byteenable;

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

`ifndef LOGIC_SYNTHESIS
    clocking cb_slave @(posedge clk);
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

    clocking cb_master @(posedge clk);
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
`endif

endinterface

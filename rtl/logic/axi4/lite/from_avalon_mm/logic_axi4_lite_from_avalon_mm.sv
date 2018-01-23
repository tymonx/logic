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

/* Module: logic_axi4_lite_from_avalon_mm
 *
 * Avalon-MM interface to AXI4-Lite interface bridge.
 *
 * Parameters:
 *  DATA_BYTES      - Number of bytes for writedata and readdata signals.
 *  ADDRESS_WIDTH   - Number of bits for address signal.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  slave       - Avalon-MM interface.
 *  master      - AXI4-Lite interface.
 */
module logic_axi4_lite_from_avalon_mm #(
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_avalon_mm_if, slave) slave,
    `LOGIC_MODPORT(logic_axi4_lite_if, master) master
);
    logic areset_n_synced;

    logic_avalon_mm_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    buffered (
        .clk(aclk),
        .reset_n(areset_n)
    );

    logic_reset_synchronizer
    reset_service (
        .*
    );

    logic_axi4_lite_from_avalon_mm_buffer #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    buffer_service (
        .areset_n(areset_n_synced),
        .master(buffered),
        .*
    );

    logic_axi4_lite_from_avalon_mm_main
    main (
        .areset_n(areset_n_synced),
        .slave(buffered),
        .*
    );
endmodule

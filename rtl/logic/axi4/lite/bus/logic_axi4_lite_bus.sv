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

/* Module: logic_axi4_lite_bus
 *
 * Multi-master multi-slave bus.
 *
 * Parameters:
 *  SLAVES          - Number of slaves connected to the AXI4-Lite bus.
 *  MASTERS         - Number of masters connected to the AXI4-Lite bus.
 *  DATA_BYTES      - Number of bytes for wdata and rdata signals.
 *  ADDRESS_WIDTH   - Number of bits for awaddr and araddr signals.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  slave       - AXI4-Lite slave interface.
 *  master      - AXI4-Lite master interface.
 */
module logic_axi4_lite_bus #(
    int SLAVES = 1,
    int MASTERS = 1,
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1,
    logic_axi4_lite_bus_pkg::slave_t [SLAVES-1:0] MAP
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_lite_if, slave) slave[MASTERS],
    `LOGIC_MODPORT(logic_axi4_lite_if, master) master[SLAVES]
);
    logic areset_n_synced;

    logic_reset_synchronizer
    reset_synchronized (
        .*
    );

    logic_axi4_lite_bus_main #(
        .SLAVES(SLAVES),
        .MASTERS(MASTERS),
        .MAP(MAP),
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    main (
        .areset_n(areset_n_synced),
        .*
    );
endmodule

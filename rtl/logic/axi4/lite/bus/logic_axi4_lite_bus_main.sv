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

/* Module: logic_axi4_lite_bus_main
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
 *  master      - AXI$-Lite master interface.
 */
module logic_axi4_lite_bus_main #(
    int SLAVES = 1,
    int MASTERS = 1,
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1,
    logic_axi4_lite_bus_pkg::range_t MAP[SLAVES],
    int SLAVES_WIDTH = (SLAVES >= 2) ? $clog2(SLAVES) : 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_lite_if, slave) slave[MASTERS],
    `LOGIC_MODPORT(logic_axi4_lite_if, master) master[SLAVES]
);
    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL(MASTERS, 1)
        `LOGIC_DRC_POWER_OF_2(DATA_BYTES)
        `LOGIC_DRC_RANGE(DATA_BYTES, 4, 8)
    end

    genvar k;

    logic [SLAVES_WIDTH-1:0] slave_id_write[MASTERS];
    logic [SLAVES_WIDTH-1:0] slave_id_read[MASTERS];

    generate
        for (k = 0; k < MASTERS; ++k) begin: slave_id
            always_comb begin
                slave_id_write[k] = '0;

                for (int i = 0; i < SLAVES; ++i) begin
                    if (MAP[k].low[ADDRESS_WIDTH-1:0] ) begin
                        slave_id_write[k] = i[SLAVES_WIDTH-1:0];
                    end
                end
            end

            always_comb begin

            end
        end
    endgenerate
endmodule

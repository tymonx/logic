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

/* Module: logic_axi4_lite_bus_multi_decoder
 *
 * Multi-master multi-slave bus.
 *
 * Parameters:
 *  SLAVES          - Number of slaves connected to the AXI4-Lite bus.
 *  ADDRESS_WIDTH   - Number of bits for awaddr and araddr signals.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Lite slave interface.
 *  tx          - AXI4-Lite master interface.
 */
module logic_axi4_lite_bus_decoder #(
    int SLAVES = 1,
    int SLAVES_WIDTH = (SLAVES >= 2) ? $clog2(SLAVES) : 1,
    int ADDRESS_WIDTH = 1,
    logic_axi4_lite_bus_pkg::slave_t MAP[SLAVES]
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    localparam int SLAVE_ID_LAST = SLAVES - 1;

    logic [SLAVES_WIDTH-1:0] slave_id;

    always_comb begin
        slave_id = SLAVE_ID_LAST[SLAVES_WIDTH-1:0];

        for (int i = 0; i < SLAVES; ++i) begin
            if ((rx.tdest >= MAP[i].address_low[ADDRESS_WIDTH-1:0]) &&
                    (rx.tdest <= MAP[i].address_high[ADDRESS_WIDTH-1:0])) begin
                slave_id = i[SLAVES_WIDTH-1:0];
            end
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.tvalid <= 1'b0;
        end
        else if (tx.tready) begin
            tx.tvalid <= rx.tvalid;
        end
    end

    always_ff @(posedge aclk) begin
        if (tx.tready) begin
            tx.write(rx.read());
            tx.tid <= slave_id;
        end
    end
endmodule

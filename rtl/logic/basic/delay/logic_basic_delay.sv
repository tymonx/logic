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

/* Module: logic_basic_delay
 *
 * Parameters:
 *  WIDTH       - Number of bits for input and output data signals.
 *  STAGES      - Number of stages for delaying input to output.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx_tvalid   - Rx valid signal.
 *  rx_tdata    - Rx data signal.
 *  rx_tready   - Rx ready signal.
 *  tx_tvalid   - Tx valid signal.
 *  tx_tdata    - Tx data signal.
 *  tx_tready   - Tx ready signal.
 */
module logic_basic_delay #(
    int WIDTH = 1,
    int STAGES = 1
) (
    input aclk,
    input areset_n,
    input rx_tvalid,
    input [WIDTH-1:0] rx_tdata,
    output logic rx_tready,
    input tx_tready,
    output logic tx_tvalid,
    output logic [WIDTH-1:0] tx_tdata
);
    genvar k;

    logic [STAGES:0] q_tvalid;
    logic [WIDTH-1:0] q_tdata [STAGES:0];

    always_comb rx_tready = tx_tready;

    always_comb q_tvalid[0] = rx_tvalid;
    always_comb q_tdata[0] = rx_tdata;

    always_comb tx_tvalid = q_tvalid[STAGES];
    always_comb tx_tdata = q_tdata[STAGES];

    generate
        for (k = 1; k <= STAGES; ++k) begin: stages
            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    q_tvalid[k] <= '0;
                end
                else if (tx_tready) begin
                    q_tvalid[k] <= q_tvalid[k - 1];
                end
            end

            always_ff @(posedge aclk) begin
                if (tx_tready) begin
                    q_tdata[k] <= q_tdata[k - 1];
                end
            end
        end
    endgenerate
endmodule

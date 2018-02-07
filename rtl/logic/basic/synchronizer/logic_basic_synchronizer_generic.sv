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

/* Module: logic_basic_synchronizer_generic
 *
 * Synchronize input signal to clock.
 *
 * Parameters:
 *  WIDTH       - Number of bits for input and output signals.
 *  STAGES      - Number of pipeline stages from input to output.
 */
module logic_basic_synchronizer_generic #(
    int WIDTH = 1,
    int STAGES = 2
) (
    input aclk,
    input areset_n,
    input [WIDTH-1:0] i,
    output logic [WIDTH-1:0] o
);
    genvar k;

    logic [WIDTH-1:0] q[STAGES-1:0];

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            q[0] <= '0;
        end
        else begin
            q[0] <= i;
        end
    end

    generate
        for (k = 1; k < STAGES; ++k) begin: stages
            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    q[k] <= '0;
                end
                else begin
                    q[k] <= q[k - 1];
                end
            end
        end
    endgenerate

    always_comb o = q[STAGES-1];
endmodule

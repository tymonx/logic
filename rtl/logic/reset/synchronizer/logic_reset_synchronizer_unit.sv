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

/* Module: logic_reset_synchronizer_unit
 *
 * Synchronize asynchronous reset de-assertion to clock.
 *
 * Parameters:
 *  STAGES          - Number of registers used for reset synchronization.
 *
 * Ports:
 *  aclk            - Clock.
 *  areset_n        - Asynchronous active-low reset.
 *  areset_n_synced - Asynchronous reset assertion.
 *                    Synchronous reset de-assertion.
 */
module logic_reset_synchronizer_unit #(
    int STAGES = 2
) (
    input aclk,
    input areset_n,
    output logic areset_n_synced
);
    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(STAGES, 2)
    end

    logic [STAGES-1:0] q;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            q <= '0;
        end
        else begin
            q <= {1'b1, q[STAGES-1:1]};
        end
    end

    always_comb areset_n_synced = q[0];
endmodule

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

/* Module: logic_basic_synchronizer
 *
 * Synchronize input signal to clock.
 *
 * Parameters:
 *  WIDTH       - Number of bits for input and output signals.
 *  STAGES      - Number of pipeline stages from input to output.
 */
module logic_basic_synchronizer #(
    logic_pkg::target_t TARGET = logic_pkg::TARGET_GENERIC,
    int WIDTH = 1,
    int STAGES = 2
) (
    input aclk,
    input areset_n,
    input [WIDTH-1:0] i,
    output logic [WIDTH-1:0] o
);
    generate
        case (TARGET)
        logic_pkg::TARGET_INTEL,
        logic_pkg::TARGET_INTEL_ARRIA_10,
        logic_pkg::TARGET_INTEL_ARRIA_10_SOC: begin: target_intel
            logic_basic_synchronizer_intel #(
                .WIDTH(WIDTH),
                .STAGES(STAGES)
            )
            unit (
                .*
            );
        end
        default: begin: target_generic
            logic_basic_synchronizer_generic #(
                .WIDTH(WIDTH),
                .STAGES(STAGES)
            )
            unit (
                .*
            );
        end
        endcase
    endgenerate
endmodule

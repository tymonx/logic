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

/* Module: logic_clock_domain_crossing
 *
 * Parameters:
 *  WIDTH       - Number of bits for input and output data signals.
 *  CAPACITY    - Number of elements that can be stored inside module.
 *  GENERIC     - Enable or disable generic implementation.
 *  TARGET      - Target implementation.
 *
 * Ports:
 *  areset_n    - Asynchronous active-low reset.
 *  rx_aclk     - Rx clock.
 *  rx_tvalid   - Rx valid signal.
 *  rx_tdata    - Rx data signal.
 *  rx_tready   - Rx ready signal.
 *  tx_aclk     - Tx clock.
 *  tx_tvalid   - Tx valid signal.
 *  tx_tdata    - Tx data signal.
 *  tx_tready   - Tx ready signal.
 */
module logic_clock_domain_crossing #(
    logic_pkg::target_t TARGET = logic_pkg::TARGET_GENERIC,
    int CAPACITY = 256,
    int GENERIC = 1,
    int WIDTH = 1
) (
    input areset_n,
    input rx_aclk,
    input rx_tvalid,
    input [WIDTH-1:0] rx_tdata,
    output logic rx_tready,
    input tx_aclk,
    input tx_tready,
    output logic tx_tvalid,
    output logic [WIDTH-1:0] tx_tdata
);
    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(CAPACITY, 8)
    end

    localparam logic_pkg::target_t M_TARGET = (GENERIC > 0) ?
        logic_pkg::TARGET_GENERIC : TARGET;

    generate
        case (M_TARGET)
        logic_pkg::TARGET_INTEL,
        logic_pkg::TARGET_INTEL_ARRIA_10,
        logic_pkg::TARGET_INTEL_ARRIA_10_SOC: begin: intel
            logic_clock_domain_crossing_intel #(
                .WIDTH(WIDTH),
                .CAPACITY(CAPACITY)
            ) unit (.*);
        end
        default: begin: generic
            logic_clock_domain_crossing_generic #(
                .WIDTH(WIDTH),
                .TARGET(TARGET),
                .CAPACITY(CAPACITY)
            ) unit (.*);
        end
        endcase
    endgenerate
endmodule

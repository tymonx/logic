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

/* Module: logic_axi4_stream_queue
 *
 * Stores data stream in queue (FIFO)
 *
 * Parameters:
 *  CAPACITY    - Number of single data transactions that can be store in
 *                internal queue memory (FIFO capacity).
 *  TARGET      - Target device.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Stream interface.
 *  tx          - AXI4-Stream interface.
 */
module logic_axi4_stream_queue #(
    int CAPACITY = 256,
    logic_pkg::target_t TARGET = `LOGIC_CONFIG_TARGET
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    generate
        case (TARGET)
        logic_pkg::TARGET_GENERIC: begin: generic
            logic_axi4_stream_queue_generic #(
                .CAPACITY(CAPACITY)
            )
            queue (
                .*
            );
        end
        logic_pkg::TARGET_INTEL,
        logic_pkg::TARGET_INTEL_ARRIA_10: begin: intel
            logic_axi4_stream_queue_intel #(
                .CAPACITY(CAPACITY)
            )
            queue (
                .*
            );
        end
        default: begin: not_supported
            initial begin
                `LOGIC_DRC_NOT_SUPPORTED(TARGET)
            end
        end
        endcase
    endgenerate
endmodule

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

module logic_basic_queue_generic_memory #(
    int DATA_WIDTH = 1,
    int ADDRESS_WIDTH = 1
) (
    input aclk,
    input write_enable,
    input [DATA_WIDTH-1:0] write_data,
    input [ADDRESS_WIDTH-1:0] write_pointer,
    input read_enable,
    input [ADDRESS_WIDTH-1:0] read_pointer,
    output logic [DATA_WIDTH-1:0] read_data
);
    localparam MEMORY_DEPTH = 2**ADDRESS_WIDTH;

    logic [DATA_WIDTH-1:0] memory[0:MEMORY_DEPTH-1];

    always_ff @(posedge aclk) begin
        if (write_enable) begin
            memory[write_pointer] <= write_data;
        end
    end

    always_ff @(posedge aclk) begin
        if (read_enable) begin
            read_data <= memory[read_pointer];
        end
    end
endmodule

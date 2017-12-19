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

module logic_basic_queue_generic_capacity #(
    int ADDRESS_WIDTH = 1
) (
    input aclk,
    input areset_n,
    /* Write */
    input write_enable,
    /* Read */
    input read_enable,
    /* Capacity */
    output logic capacity_valid,
    output logic [ADDRESS_WIDTH-1:0] capacity_data
);
    struct packed {
        logic valid;
        logic [ADDRESS_WIDTH-1:0] data;
    } capacity;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            capacity <= '{valid: 1'b0, data: '1};
        end
        else if (write_enable && !read_enable) begin
            capacity <= capacity + 1'b1;
        end
        else if (!write_enable && read_enable) begin
            capacity <= capacity - 1'b1;
        end
    end

    always_comb capacity_valid = capacity.valid;
    always_comb capacity_data = capacity.data;
endmodule

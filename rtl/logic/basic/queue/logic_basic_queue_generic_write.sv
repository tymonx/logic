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

module logic_basic_queue_generic_write #(
    int DATA_WIDTH = 1,
    int ADDRESS_WIDTH = 1
) (
    input aclk,
    input areset_n,
    input rx_tvalid,
    input [DATA_WIDTH-1:0] rx_tdata,
    output logic rx_tready,
    output logic write_enable,
    output logic [DATA_WIDTH-1:0] write_data,
    output logic [ADDRESS_WIDTH-1:0] write_pointer,
    input [ADDRESS_WIDTH:0] capacity
);
    localparam ALMOST_FULL = (2**ADDRESS_WIDTH) - 1;

    logic almost_full;

    always_comb write_data = rx_tdata;
    always_comb write_enable = rx_tvalid && rx_tready;
    always_comb almost_full = (capacity >= ALMOST_FULL[ADDRESS_WIDTH:0]);

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            rx_tready <= '0;
        end
        else begin
            rx_tready <= !almost_full;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            write_pointer <= '0;
        end
        else if (write_enable) begin
            write_pointer <= write_pointer + 1'b1;
        end
    end
endmodule

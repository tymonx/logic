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

/* Module: logic_clock_domain_crossing_genric_write_service
 *
 * Parameters:
 *  WIDTH       - Number of bits for input and output data signals.
 *  CAPACITY    - Number of elements that can be stored inside module.
 *
 * Ports:
 *  rx_aclk         - Clock.
 *  rx_areset_n     - Asynchronous active-low reset.
 *  rx_tvalid       - Rx valid signal.
 *  rx_tdata        - Rx data signal.
 *  rx_tready       - Rx ready signal.
 *  write_enable    - Write enable.
 *  write_data      - Write data.
 *  write_pointer   - Write pointer.
 *  read_pointer    - Read pointer.
 */
module logic_clock_domain_crossing_generic_write_service #(
    int DATA_WIDTH = 1,
    int ADDRESS_WIDTH = 1
) (
    input rx_aclk,
    input rx_areset_n,
    /* Rx */
    input rx_tvalid,
    input [DATA_WIDTH-1:0] rx_tdata,
    output logic rx_tready,
    /* Write */
    output logic write_enable,
    output logic [DATA_WIDTH-1:0] write_data,
    output logic [ADDRESS_WIDTH-1:0] write_pointer,
    input [ADDRESS_WIDTH-1:0] read_pointer_synced
);
    initial begin: design_rule_checks
        `LOGIC_DRC_EQUAL_OR_GREATER_THAN(ADDRESS_WIDTH, 2)
    end

    localparam ALMOST_FULL = 2**ADDRESS_WIDTH - 3;

    logic [ADDRESS_WIDTH-1:0] difference;

    always_ff @(posedge rx_aclk or negedge rx_areset_n) begin
        if (!rx_areset_n) begin
            difference <= '0;
        end
        else begin
            difference <= write_pointer - read_pointer_synced;
        end
    end

    always_ff @(posedge rx_aclk or negedge rx_areset_n) begin
        if (!rx_areset_n) begin
            rx_tready <= '0;
        end
        else begin
            rx_tready <= (difference > ALMOST_FULL[ADDRESS_WIDTH-1:0]);
        end
    end

    always_ff @(posedge rx_aclk or negedge rx_areset_n) begin
        if (!rx_areset_n) begin
            write_enable <= '0;
        end
        else begin
            write_enable <= rx_tvalid && rx_tready;
        end
    end

    always_ff @(posedge rx_aclk) begin
        write_data <= rx_tdata;
    end

    always_ff @(posedge rx_aclk or negedge rx_areset_n) begin
        if (!rx_areset_n) begin
            write_pointer <= '0;
        end
        else if (write_enable) begin
            write_pointer <= write_pointer + 1'b1;
        end
    end
endmodule

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

module logic_basic_queue_generic #(
    int WIDTH = 1,
    int CAPACITY = 256,
    int ADDRESS_WIDTH = $clog2(CAPACITY)
) (
    input aclk,
    input areset_n,
    /* Rx */
    input rx_tvalid,
    input [WIDTH-1:0] rx_tdata,
    output logic rx_tready,
    /* Tx */
    input tx_tready,
    output logic tx_tvalid,
    output logic [WIDTH-1:0] tx_tdata
);
    localparam DATA_WIDTH = WIDTH;

    logic write_enable;
    logic [DATA_WIDTH-1:0] write_data;
    logic [ADDRESS_WIDTH-1:0] write_pointer;

    logic read_enable;
    logic [DATA_WIDTH-1:0] read_data;
    logic [ADDRESS_WIDTH-1:0] read_pointer;

    logic [ADDRESS_WIDTH:0] capacity;

    logic_basic_queue_generic_write #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    write_service (
        .*
    );

    logic_basic_queue_generic_read #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    read_service (
        .*
    );

    logic_basic_queue_generic_capacity #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    capacity_service (
        .*
    );

    logic_basic_queue_generic_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    memory_service (
        .*
    );
endmodule

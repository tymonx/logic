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

/* Module: logic_clock_domain_crossing_generic
 *
 * Parameters:
 *  WIDTH       - Number of bits for input and output data signals.
 *  CAPACITY    - Number of elements that can be stored inside module.
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
module logic_clock_domain_crossing_generic #(
    int WIDTH = 1,
    int CAPACITY = 256,
    int ADDRESS_WIDTH = $clog2(CAPACITY),
    logic_pkg::target_t TARGET = logic_pkg::TARGET_GENERIC
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
    localparam DATA_WIDTH = WIDTH;

    logic rx_areset_n;
    logic tx_areset_n;

    logic write_aclk;
    logic write_areset_n;
    logic write_enable;
    logic [DATA_WIDTH-1:0] write_data;
    logic [ADDRESS_WIDTH-1:0] write_pointer;
    logic [ADDRESS_WIDTH-1:0] write_pointer_synced;

    logic read_aclk;
    logic read_areset_n;
    logic read_enable;
    logic [DATA_WIDTH-1:0] read_data;
    logic [ADDRESS_WIDTH-1:0] read_pointer;
    logic [ADDRESS_WIDTH-1:0] read_pointer_synced;

    always_comb write_aclk = rx_aclk;
    always_comb write_areset_n = rx_areset_n;

    always_comb read_aclk = tx_aclk;
    always_comb read_areset_n = tx_areset_n;

    logic_reset_synchronizer
    rx_areset_n_synchronized (
        .aclk(rx_aclk),
        .areset_n(areset_n),
        .areset_n_synced(rx_areset_n)
    );

    logic_reset_synchronizer
    tx_areset_n_synchronized (
        .aclk(tx_aclk),
        .areset_n(areset_n),
        .areset_n_synced(tx_areset_n)
    );

    logic_clock_domain_crossing_generic_write #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    write_service (
        .*
    );

    logic_clock_domain_crossing_generic_read #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    read_service (
        .*
    );

    logic_clock_domain_crossing_generic_write_sync #(
        .TARGET(TARGET),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    write_sync (
        .*
    );

    logic_clock_domain_crossing_generic_read_sync #(
        .TARGET(TARGET),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    read_sync (
        .*
    );

    logic_clock_domain_crossing_generic_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    memory_unit (
        .*
    );
endmodule

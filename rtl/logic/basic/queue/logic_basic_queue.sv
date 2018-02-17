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

/* Module: logic_basic_queue
 *
 * Stores data stream in queue (FIFO).
 *
 * Parameters:
 *  WIDTH       - Number of bits for input and output data signals.
 *  CAPACITY    - Number of single data transactions that can be store in
 *                internal queue memory (FIFO capacity).
 *  TARGET      - Target device.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx_tvalid   - Rx valid signal.
 *  rx_tdata    - Rx data signal.
 *  rx_tready   - Rx ready signal.
 *  tx_tvalid   - Tx valid signal.
 *  tx_tdata    - Tx data signal.
 *  tx_tready   - Tx ready signal.
 */
module logic_basic_queue #(
    logic_pkg::target_t TARGET = logic_pkg::TARGET_GENERIC,
    int CAPACITY = 256,
    int WIDTH = 1
) (
    input aclk,
    input areset_n,
    input rx_tvalid,
    input [WIDTH-1:0] rx_tdata,
    output logic rx_tready,
    input tx_tready,
    output logic tx_tvalid,
    output logic [WIDTH-1:0] tx_tdata
);
    logic areset_n_synced;

    logic_reset_synchronizer
    reset_sync (
        .*
    );

    logic_basic_queue_main #(
        .WIDTH(WIDTH),
        .CAPACITY(CAPACITY),
        .TARGET(TARGET)
    )
    main (
        .areset_n(areset_n_synced),
        .*
    );
endmodule

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

/* Module: logic_basic_buffer
 *
 * Improve timings between modules by adding register to ready signal path from
 * tx to rx ports and it keeps zero latency bus transcation on both sides.
 *
 * Parameters:
 *  WIDTH       - Number of bits for input and output data signals.
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
module logic_basic_buffer #(
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
    /* Enum: fsm_state
     *
     * FSM_IDLE     - Data signals that come directly from rx_
     * FSM_BUFFERED - Data signals that come from internal buffer.
     */
    enum logic [0:0] {
        FSM_IDLE,
        FSM_BUFFERED
    } fsm_state;

    /* Logic: buffered
     *
     * Store captured data signals.
     */
    logic [WIDTH-1:0] buffered;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_IDLE;
        end
        else begin
            unique case (fsm_state)
            FSM_IDLE: begin
                if (rx_tvalid && rx_tready && !tx_tready) begin
                    fsm_state <= FSM_BUFFERED;
                end
            end
            FSM_BUFFERED: begin
                if (tx_tready) begin
                    fsm_state <= FSM_IDLE;
                end
            end
            default: begin
                fsm_state <= FSM_IDLE;
            end
            endcase
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            rx_tready <= 1'b0;
        end
        else begin
            rx_tready <= tx_tready;
        end
    end

    always_ff @(posedge aclk) begin
        if (rx_tready) begin
            buffered <= rx_tdata;
        end
    end

    always_comb begin
        unique case (fsm_state)
        FSM_IDLE: begin
            tx_tvalid = rx_tvalid && rx_tready;
        end
        FSM_BUFFERED: begin
            tx_tvalid = '1;
        end
        default: begin
            tx_tvalid = '0;
        end
        endcase
    end

    always_comb begin
        unique case (fsm_state)
        FSM_IDLE: begin
            tx_tdata = rx_tdata;
        end
        FSM_BUFFERED: begin
            tx_tdata = buffered;
        end
        default: begin
            tx_tdata = '0;
        end
        endcase
    end
endmodule

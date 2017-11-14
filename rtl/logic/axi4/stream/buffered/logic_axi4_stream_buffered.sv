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

/* Module: logic_axi4_stream_buffered
 *
 * Improve timings between modules by adding register to ready signal from tx to
 * rx.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Stream interface.
 *  tx          - AXI4-Stream interface.
 */
module logic_axi4_stream_buffered (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    /* Enum: fsm_state
     *
     * FSM_IDLE     - Data signals that come directly from rx.
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
    logic [$bits(rx.read())-1:0] buffered;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_IDLE;
        end
        else begin
            unique case (fsm_state)
            FSM_IDLE: begin
                if (rx.tvalid && rx.tready && !tx.tready) begin
                    fsm_state <= FSM_BUFFERED;
                end
            end
            FSM_BUFFERED: begin
                if (tx.tready) begin
                    fsm_state <= FSM_IDLE;
                end
            end
            endcase
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            rx.tready <= 1'b0;
        end
        else begin
            rx.tready <= tx.tready;
        end
    end

    always_ff @(posedge aclk) begin
        if (rx.tready) begin
            buffered <= rx.read();
        end
    end

    always_comb begin
        unique case (fsm_state)
        FSM_BUFFERED: begin
            tx.tvalid = 1'b1;
        end
        default: begin
            tx.tvalid = rx.tvalid && rx.tready;
        end
        endcase
    end

    always_comb begin
        unique case (fsm_state)
        FSM_BUFFERED: begin
            tx.comb_write(buffered);
        end
        default: begin
            tx.comb_write(rx.read());
        end
        endcase
    end
endmodule

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

/* Module: logic_axi4_lite_buffered_basic
 *
 * Improve timings between modules by adding register to ready signal path from
 * tx to rx ports and it keeps zero latency bus transcation on both sides.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 */
module logic_axi4_lite_buffered_basic #(
    int WIDTH = 1
) (
    input aclk,
    input areset_n,
    /* Slave */
    input slave_valid,
    input [WIDTH-1:0] slave_data,
    output logic slave_ready,
    /* Master */
    output logic master_valid,
    output logic [WIDTH-1:0] master_data,
    input master_ready
);
    /* Enum: fsm_state
     *
     * FSM_IDLE     - Data signals that come directly from slave_
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
                if (slave_valid && slave_ready && !master_ready) begin
                    fsm_state <= FSM_BUFFERED;
                end
            end
            FSM_BUFFERED: begin
                if (master_ready) begin
                    fsm_state <= FSM_IDLE;
                end
            end
            endcase
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            slave_ready <= 1'b0;
        end
        else begin
            slave_ready <= master_ready;
        end
    end

    always_ff @(posedge aclk) begin
        if (slave_ready) begin
            buffered <= slave_data;
        end
    end

    always_comb begin
        unique case (fsm_state)
        FSM_IDLE: begin
            master_valid = slave_valid && slave_ready;
        end
        FSM_BUFFERED: begin
            master_valid = 1'b1;
        end
        endcase
    end

    always_comb begin
        unique case (fsm_state)
        FSM_IDLE: begin
            master_data = slave_data;
        end
        FSM_BUFFERED: begin
            master_data = buffered;
        end
        endcase
    end
endmodule

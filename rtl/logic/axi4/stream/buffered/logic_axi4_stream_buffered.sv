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

module logic_axi4_stream_buffered (
    input aclk,
    input areset_n,
    logic_axi4_stream_if.rx rx,
    logic_axi4_stream_if.tx tx
);
    enum logic [0:0] {
        FSM_IDLE,
        FSM_BUFFERED
    } fsm_state;

    logic [$bits(rx.read())-1:0] buffered;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_IDLE;
        end
        else begin
            case (fsm_state)
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
            default: begin
                fsm_state <= FSM_IDLE;
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

    always_comb tx.tvalid = (FSM_BUFFERED == fsm_state) || rx.tvalid;

    always_comb begin
        if (FSM_BUFFERED == fsm_state) begin
            tx.comb_write(buffered);
        end
        else begin
            tx.comb_write(rx.read());
        end
    end
endmodule

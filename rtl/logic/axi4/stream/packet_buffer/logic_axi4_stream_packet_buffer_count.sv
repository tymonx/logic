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

/* Module: logic_axi4_stream_packet_buffer_count
 *
 * Don't pass data stream packet to next module if we don't first buffer
 * whole data stream packet in queue. Don't block if queue is full.
 *
 * Parameters:
 *  CAPACITY        - Number of single data transactions that can be store in
 *                    internal queue memory (FIFO capacity).
 *  CAPACITY_WIDTH  - Number of bits for queue capacity.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  mon         - AXI4-Stream interface.
 *  rx          - AXI4-Stream interface.
 *  tx          - AXI4-Stream interface.
 */
module logic_axi4_stream_packet_buffer_count #(
    int CAPACITY = 256,
    int CAPACITY_WIDTH = (CAPACITY >= 2) ? $clog2(CAPACITY) : 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, monitor) monitor,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    typedef struct packed {
        logic valid;
        logic [CAPACITY_WIDTH:0] capacity;
    } capacity_t;

    enum logic [0:0] {
        FSM_IDLE,
        FSM_READ
    } fsm_state;

    capacity_t data;
    capacity_t packets;

    logic data_write;
    logic data_read;

    logic packets_write;
    logic packets_read;
    logic packets_more;

    always_comb data_write = monitor.tready && monitor.tvalid;
    always_comb data_read = rx.tready && rx.tvalid;

    always_comb packets_write = data_write && monitor.tlast;
    always_comb packets_read = data_read && rx.tlast;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            data <= '{capacity: '1, default: '0};
        end
        else if (data_write && !data_read) begin
            data <= data + 1'b1;
        end
        else if (!data_write && data_read) begin
            data <= data - 1'b1;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            packets <= '{capacity: '1, default: '0};
        end
        else if (packets_write && !packets_read) begin
            packets <= packets + 1'b1;
        end
        else if (!packets_write && packets_read) begin
            packets <= packets - 1'b1;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            packets_more <= '0;
        end
        else begin
            packets_more <= packets.valid && (0 != packets.capacity);
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_IDLE;
        end
        else begin
            unique case (fsm_state)
            FSM_IDLE: begin
                if (packets.valid || (data.valid && !monitor.tready)) begin
                    fsm_state <= FSM_READ;
                end
            end
            FSM_READ: begin
                if (packets_read && !packets_more) begin
                    fsm_state <= FSM_IDLE;
                end
            end
            default: begin
                fsm_state <= FSM_IDLE;
            end
            endcase
        end
    end

    always_comb begin
        unique case (fsm_state)
        FSM_READ: begin
            rx.tready = tx.tready;
        end
        default: begin
            rx.tready = '0;
        end
        endcase
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.tvalid <= '0;
        end
        else if (tx.tready) begin
            tx.tvalid <= (FSM_READ == fsm_state) && rx.tvalid;
        end
    end

    always_ff @(posedge aclk) begin
        if (tx.tready) begin
            tx.write(rx.read());
        end
    end
endmodule

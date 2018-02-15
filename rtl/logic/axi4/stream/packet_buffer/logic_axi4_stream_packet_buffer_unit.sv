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

/* Module: logic_axi4_stream_packet_buffer_unit
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
module logic_axi4_stream_packet_buffer_unit #(
    int CAPACITY = 256,
    int CAPACITY_WIDTH = (CAPACITY >= 2) ? $clog2(CAPACITY) : 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) packets_counted,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) transfers_counted,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    localparam int ALMOST_EMPTY = 1;
    localparam int ALMOST_FULL = (2**CAPACITY_WIDTH) - 1;

    typedef logic [CAPACITY_WIDTH:0] capacity_t;

    enum logic [1:0] {
        FSM_IDLE,
        FSM_READ,
        FSM_FLUSH
    } fsm_state;

    capacity_t packets;
    capacity_t transfers;

    logic almost_full;
    logic almost_empty;
    logic empty;

    always_comb packets = capacity_t'(packets_counted.tdata);
    always_comb transfers = capacity_t'(transfers_counted.tdata);

    always_comb packets_counted.tready = '1;
    always_comb transfers_counted.tready = '1;

`ifdef VERILATOR
    logic _unused_ports = &{
            1'b0,
            packets_counted.tvalid,
            transfers_counted.tvalid,
            1'b0
        };
`endif

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            almost_empty <= '1;
        end
        else begin
            almost_empty <= (packets <= ALMOST_EMPTY[CAPACITY_WIDTH:0]);
        end
    end

    always_comb empty = almost_empty && (2'b00 == packets[1:0]);

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            almost_full <= '0;
        end
        else begin
            almost_full <= (transfers >= ALMOST_FULL[CAPACITY_WIDTH:0]);
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_IDLE;
        end
        else begin
            unique case (fsm_state)
            FSM_IDLE: begin
                if (!empty) begin
                    fsm_state <= FSM_READ;
                end
                else if (almost_full) begin
                    fsm_state <= FSM_FLUSH;
                end
            end
            FSM_READ: begin
                if (empty) begin
                    fsm_state <= FSM_IDLE;
                end
            end
            FSM_FLUSH: begin
                if (!empty) begin
                    fsm_state <= FSM_READ;
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
            rx.tready = !rx.tvalid || (tx.tready && !empty);
        end
        FSM_FLUSH: begin
            rx.tready = !rx.tvalid || tx.tready;
        end
        default: begin
            rx.tready = !rx.tvalid || ((!empty || almost_full) && tx.tready);
        end
        endcase
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.tvalid <= '0;
        end
        else if (tx.tready) begin
            tx.tvalid <= rx.tvalid && rx.tready;
        end
    end

    always_ff @(posedge aclk) begin
        if (tx.tready) begin
            tx.write(rx.read());
        end
    end
endmodule

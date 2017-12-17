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

/* Module: logic_axi4_lite_write_aligned
 *
 * Align write address channel and write data channel.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  slave       - AXI4-Lite slave interface.
 *  master      - AXI4-Lite master interface.
 */
module logic_axi4_lite_write_aligned #(
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_lite_if, slave) slave,
    `LOGIC_MODPORT(logic_axi4_lite_if, master) master
);
    enum logic [1:0] {
        FSM_IDLE,
        FSM_WAIT_FOR_DATA,
        FSM_WAIT_FOR_ADDRESS
    } fsm_state;

    logic data_ready;
    logic address_ready;

    always_comb data_ready = slave.wvalid && master.wready;
    always_comb address_ready = slave.awvalid && master.awready;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            fsm_state <= FSM_IDLE;
        end
        else begin
            unique case (fsm_state)
            FSM_IDLE: begin
                if (address_ready && !data_ready) begin
                    fsm_state <= FSM_WAIT_FOR_DATA;
                end
                else if (!address_ready && data_ready) begin
                    fsm_state <= FSM_WAIT_FOR_ADDRESS;
                end
            end
            FSM_WAIT_FOR_DATA: begin
                if (address_ready && data_ready) begin
                    fsm_state <= FSM_IDLE;
                end
            end
            FSM_WAIT_FOR_ADDRESS: begin
                if (address_ready && data_ready) begin
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
        FSM_IDLE: begin
            if (address_ready && !data_ready) begin
                slave.awready = 1'b0;
            end
            else begin
                slave.awready = master.awready;
            end
        end
        FSM_WAIT_FOR_DATA: begin
            slave.awready = 1'b0;
        end
        default: begin
            slave.awready = master.awready;
        end
        endcase
    end

    always_comb begin
        unique case (fsm_state)
        FSM_IDLE: begin
            if (!address_ready && data_ready) begin
                slave.wready = 1'b0;
            end
            else begin
                slave.wready = master.wready;
            end
        end
        FSM_WAIT_FOR_ADDRESS: begin
            slave.wready = 1'b0;
        end
        default: begin
            slave.wready = master.wready;
        end
        endcase
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            master.awvalid <= 1'b0;
        end
        else if (master.awready) begin
            master.awvalid <= slave.awvalid && slave.wvalid && master.wready;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            master.wvalid <= 1'b0;
        end
        else if (master.wready) begin
            master.wvalid <= slave.wvalid && slave.awvalid && master.awready;
        end
    end

    always_ff @(posedge aclk) begin
        if (master.wready) begin
            master.wstrb <= slave.wstrb;
            master.wdata <= slave.wdata;
        end
    end

    always_ff @(posedge aclk) begin
        if (master.awready) begin
            master.awprot <= slave.awprot;
            master.awaddr <= slave.awaddr;
        end
    end

    always_comb slave.bvalid = master.bvalid;
    always_comb slave.bresp = master.bresp;
    always_comb master.bready = slave.bready;

    always_comb master.arvalid = slave.arvalid;
    always_comb master.araddr = slave.araddr;
    always_comb master.arprot = slave.arprot;
    always_comb slave.arready = master.arready;

    always_comb slave.rvalid = master.rvalid;
    always_comb slave.rresp = master.rresp;
    always_comb slave.rdata = master.rdata;
    always_comb master.rready = slave.rready;
endmodule

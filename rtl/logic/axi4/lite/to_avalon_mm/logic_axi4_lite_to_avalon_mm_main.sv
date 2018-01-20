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

/* Module: logic_axi4_lite_to_avalon_mm_main
 *
 * AXI4-Lite interface to Avalon-MM interface bridge.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  slave       - AXI4-Lite interface.
 *  master      - Avalon-MM interface.
 */
module logic_axi4_lite_to_avalon_mm_main (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_lite_if, slave) slave,
    `LOGIC_MODPORT(logic_avalon_mm_if, master) master
);
    logic_axi4_lite_pkg::response_t response_decoded;

    always_comb slave.awready = !master.waitrequest;
    always_comb slave.arready = !master.waitrequest;
    always_comb slave.wready = !master.waitrequest;

    always_comb begin
        unique case (master.response)
        logic_avalon_mm_pkg::RESPONSE_OKAY: begin
            response_decoded = logic_axi4_lite_pkg::RESPONSE_OKAY;
        end
        logic_avalon_mm_pkg::RESPONSE_DECODEERROR: begin
            response_decoded = logic_axi4_lite_pkg::RESPONSE_DECERR;
        end
        default: begin
            response_decoded = logic_axi4_lite_pkg::RESPONSE_SLVERR;
        end
        endcase
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            master.write <= 1'b0;
        end
        else if (!master.waitrequest) begin
            master.write <= slave.awvalid && slave.wvalid;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            master.read <= 1'b0;
        end
        else if (!master.waitrequest) begin
            master.read <= slave.arvalid;
        end
    end

    always_ff @(posedge aclk) begin
        if (!master.waitrequest) begin
            master.byteenable <= slave.wvalid ? slave.wstrb : '1;
            master.address <= slave.awvalid ? slave.awaddr : slave.araddr;
            master.writedata <= slave.wdata;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            slave.bvalid <= 1'b0;
        end
        else if (slave.bready) begin
            slave.bvalid <= master.writeresponsevalid;
        end
    end

    always_ff @(posedge aclk) begin
        if (slave.bready) begin
            slave.bresp <= response_decoded;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            slave.rvalid <= 1'b0;
        end
        else if (slave.rready) begin
            slave.rvalid <= master.readdatavalid;
        end
    end

    always_ff @(posedge aclk) begin
        if (slave.rready) begin
            slave.rdata <= master.readdata;
            slave.rresp <= response_decoded;
        end
    end

    wire _unused_ports = &{
        1'b0,
        slave.awprot,
        slave.arprot,
        1'b0
    };
endmodule

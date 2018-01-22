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

/* Module: logic_axi4_lite_from_avalon_mm_main
 *
 * Avalon-MM interface to AXI4-Lite interface bridge.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  slave       - Avalon-MM interface.
 *  master      - AXI4-Lite interface.
 */
module logic_axi4_lite_from_avalon_mm_main (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_avalon_mm_if, slave) slave,
    `LOGIC_MODPORT(logic_axi4_lite_if, master) master
);
    function automatic logic_avalon_mm_pkg::response_t decode_response(
        input logic_axi4_lite_pkg::response_t response
    );
        unique case (response)
        logic_axi4_lite_pkg::RESPONSE_OKAY: begin
            decode_response = logic_avalon_mm_pkg::RESPONSE_OKAY;
        end
        logic_axi4_lite_pkg::RESPONSE_DECERR: begin
            decode_response = logic_avalon_mm_pkg::RESPONSE_DECODEERROR;
        end
        default: begin
            decode_response = logic_avalon_mm_pkg::RESPONSE_SLAVEERROR;
        end
        endcase
    endfunction

    always_comb slave.waitrequest = !master.awready || !master.wready ||
        !master.arready;

    always_comb master.awprot = logic_axi4_lite_pkg::DEFAULT_DATA_ACCESS;
    always_comb master.arprot = logic_axi4_lite_pkg::DEFAULT_DATA_ACCESS;

    always_comb master.bready = 1'b1;
    always_comb master.rready = 1'b1;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            master.awvalid <= 1'b0;
        end
        else if (master.awready) begin
            master.awvalid <= slave.write;
        end
    end

    always_ff @(posedge aclk) begin
        if (master.awready) begin
            master.awaddr <= slave.address;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            master.wvalid <= 1'b0;
        end
        else if (master.wready) begin
            master.wvalid <= slave.write;
        end
    end

    always_ff @(posedge aclk) begin
        if (master.wready) begin
            master.wdata <= slave.writedata;
            master.wstrb <= slave.byteenable;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            master.arvalid <= 1'b0;
        end
        else if (master.arready) begin
            master.arvalid <= slave.read;
        end
    end

    always_ff @(posedge aclk) begin
        if (master.arready) begin
            master.araddr <= slave.address;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            slave.writeresponsevalid <= 1'b0;
        end
        else begin
            slave.writeresponsevalid <= master.bvalid;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            slave.readdatavalid <= 1'b0;
        end
        else begin
            slave.readdatavalid <= master.rvalid;
        end
    end

    always_ff @(posedge aclk) begin
        slave.response <= decode_response(master.bvalid ?
            master.bresp : master.rresp);
        slave.readdata <= master.rdata;
    end
endmodule

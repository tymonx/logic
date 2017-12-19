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

/* Module: logic_axi4_stream_to_avalon_st
 *
 * AXI4-Stream interface to Avalon-ST interface bridge.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Stream interface.
 *  tx          - Avalon-ST interface.
 */
module logic_axi4_stream_to_avalon_st #(
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_avalon_st_if, tx) tx
);
    function automatic bit [$bits(tx.empty)-1:0] tstrb_to_empty(
        input [$bits(rx.tstrb)-1:0] tstrb
    );
        int count = 0;

        for (int i = 0; i < $bits(tstrb); ++i) begin
            if (tstrb[i]) begin
                --count;
            end
        end

        return count[$bits(tx.empty)-1:0];
    endfunction

    always_comb rx.tready = tx.ready;
    always_comb tx.error = '0;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.valid <= 1'b0;
        end
        else if (tx.ready) begin
            tx.valid <= rx.tvalid;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.startofpacket <= 1'b1;
        end
        else if (tx.ready) begin
            if (rx.tlast && rx.tvalid) begin
                tx.startofpacket <= 1'b1;
            end
            else begin
                tx.startofpacket <= 1'b0;
            end
        end
    end

    always_ff @(posedge aclk) begin
        if (tx.ready) begin
            tx.endofpacket <= rx.tlast;
            tx.channel <= rx.tid;
            tx.empty <= tstrb_to_empty(rx.tstrb & rx.tkeep);
            tx.data <= rx.tdata;
        end
    end
endmodule

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

/* Module: logic_axi4_stream_split_unit
 *
 * Split (copy) AXI4-Stream packets from rx input port to all tx outputs ports.
 *
 * Parameters:
 *  OUTPUTS     - Number of tx output ports.
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *  USE_TKEEP   - Enable or disable tkeep signal.
 *  USE_TSTRB   - Enable or disable tstrb signal.
 *  USE_TLAST   - Enable or disable tlast signal.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  rx          - AXI4-Stream Rx interface.
 *  tx          - AXI4-Stream Tx interface.
 */
module logic_axi4_stream_split_unit #(
    int OUTPUTS = 1,
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx[OUTPUTS]
);
    genvar k;

    logic [OUTPUTS-1:0] select;

    always_comb rx.tready = !rx.tvalid || &select;

    generate
        for (k = 0; k < OUTPUTS; ++k) begin: outputs
            always_comb select[k] = tx[k].tready;

            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    tx[k].tvalid <= '0;
                end
                else if (tx[k].tready) begin
                    tx[k].tvalid <= rx.tvalid && rx.tready;
                end
            end

            if (TDATA_BYTES > 0) begin: tdata_enabled
                always_ff @(posedge aclk) begin
                    if (tx[k].tready) begin
                        tx[k].tdata <= rx.tdata;
                    end
                end
            end
            else begin: tdata_disabled
                always_comb tx[k].tdata = '0;
            end

            if ((TDATA_BYTES > 0) && (USE_TKEEP > 0)) begin: tkeep_enabled
                always_ff @(posedge aclk) begin
                    if (tx[k].tready) begin
                        tx[k].tkeep <= rx.tkeep;
                    end
                end
            end
            else begin: tkeep_disabled
                always_comb tx[k].tkeep = '1;
            end

            if ((TDATA_BYTES > 0) && (USE_TSTRB > 0)) begin: tstrb_enabled
                always_ff @(posedge aclk) begin
                    if (tx[k].tready) begin
                        tx[k].tstrb <= rx.tstrb;
                    end
                end
            end
            else begin: tstrb_disabled
                always_comb tx[k].tstrb = '1;
            end

            if (USE_TLAST > 0) begin: tlast_enabled
                always_ff @(posedge aclk) begin
                    if (tx[k].tready) begin
                        tx[k].tlast <= rx.tlast;
                    end
                end
            end
            else begin: tlast_disabled
                always_comb tx[k].tlast = '1;
            end

            if (TUSER_WIDTH > 0) begin: tuser_enabled
                always_ff @(posedge aclk) begin
                    if (tx[k].tready) begin
                        tx[k].tuser <= rx.tuser;
                    end
                end
            end
            else begin: tuser_disabled
                always_comb tx[k].tuser = '0;
            end

            if (TDEST_WIDTH > 0) begin: tdest_enabled
                always_ff @(posedge aclk) begin
                    if (tx[k].tready) begin
                        tx[k].tdest <= rx.tdest;
                    end
                end
            end
            else begin: tdest_disabled
                always_comb tx[k].tdest = '0;
            end

            if (TID_WIDTH > 0) begin: tid_enabled
                always_ff @(posedge aclk) begin
                    if (tx[k].tready) begin
                        tx[k].tid <= rx.tid;
                    end
                end
            end
            else begin: tid_disabled
                always_comb tx[k].tid = '0;
            end
        end
    endgenerate
endmodule

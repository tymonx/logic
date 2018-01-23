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

/* Module: logic_axi4_stream_demux_unit
 *
 * Parameters:
 *  OFFSET      - Offset ID.
 *  OUTPUTS     - Number of outputs.
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *  USE_TKEEP   - Enable or disable tkeep signal.
 *  USE_TSTRB   - Enable or disable tstrb signal.
 *  USE_TLAST   - Enable or disable tlast signal.
 *  USE_TID     - Use tid instead of tdest signal for demultiplexing data.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  prev        - AXI4-Stream Rx interface.
 *  next        - AXI4-Stream Tx interface.
 *  tx          - AXI4-Stream Tx interface.
 */
module logic_axi4_stream_demux_unit #(
    int OFFSET = 0,
    int OUTPUTS = 2,
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int USE_TLAST = 1,
    int USE_TID = 0
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) prev,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) next,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx[OUTPUTS-1:0]
);
    localparam SELECT = OUTPUTS + 1;
    localparam FIRST = OFFSET;
    localparam LAST = OFFSET + OUTPUTS;

    genvar k;

    logic [SELECT-1:0] select;
    logic [SELECT-1:0] tready;

    always_comb prev.tready = !prev.tvalid || |(tready & select);
    always_comb tready[OUTPUTS] = next.tready;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            next.tvalid <= '0;
        end
        else if (next.tready) begin
            next.tvalid <= prev.tvalid && select[OUTPUTS];
        end
    end

    generate
        if (TDATA_BYTES > 0) begin: tdata_enabled
            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    next.tdata <= '0;
                end
                else if (next.tready) begin
                    next.tdata <= prev.tdata;
                end
            end
        end
        else begin: tdata_disabled
            always_comb next.tdata = '0;
        end

        if ((TDATA_BYTES > 0) && (USE_TKEEP > 0)) begin: tkeep_enabled
            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    next.tkeep <= '0;
                end
                else if (next.tready) begin
                    next.tkeep <= prev.tkeep;
                end
            end
        end
        else begin: tkeep_disabled
            always_comb next.tkeep = '1;
        end

        if ((TDATA_BYTES > 0) && (USE_TSTRB > 0)) begin: tstrb_enabled
            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    next.tstrb <= '0;
                end
                else if (next.tready) begin
                    next.tstrb <= prev.tstrb;
                end
            end
        end
        else begin: tstrb_disabled
            always_comb next.tstrb = '1;
        end

        if (USE_TLAST > 0) begin: tlast_enabled
            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    next.tlast <= '0;
                end
                else if (next.tready) begin
                    next.tlast <= prev.tlast;
                end
            end
        end
        else begin: tlast_disabled
            always_comb next.tlast = '1;
        end

        if (TUSER_WIDTH > 0) begin: tuser_enabled
            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    next.tuser <= '0;
                end
                else if (next.tready) begin
                    next.tuser <= prev.tuser;
                end
            end
        end
        else begin: tuser_disabled
            always_comb next.tuser = '0;
        end

        if (TDEST_WIDTH > 0) begin: tdest_enabled
            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    next.tdest <= '0;
                end
                else if (next.tready) begin
                    next.tdest <= prev.tdest;
                end
            end
        end
        else begin: tdest_disabled
            always_comb next.tdest = '0;
        end

        if (TID_WIDTH > 0) begin: tid_enabled
            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    next.tid <= '0;
                end
                else if (next.tready) begin
                    next.tid <= prev.tid;
                end
            end
        end
        else begin: tid_disabled
            always_comb next.tid = '0;
        end

        for (k = 0; k < OUTPUTS; ++k) begin: outputs
            always_comb tready[k] = tx[k].tready;

            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    tx[k].tvalid <= '0;
                end
                else if (tx[k].tready) begin
                    tx[k].tvalid <= prev.tvalid && select[k];
                end
            end

            if (TDATA_BYTES > 0) begin: tdata_enabled
                always_ff @(posedge aclk or negedge areset_n) begin
                    if (!areset_n) begin
                        tx[k].tdata <= '0;
                    end
                    else if (tx[k].tready) begin
                        tx[k].tdata <= prev.tdata;
                    end
                end
            end
            else begin: tdata_disabled
                always_comb tx[k].tdata = '0;
            end

            if ((TDATA_BYTES > 0) && (USE_TKEEP > 0)) begin: tkeep_enabled
                always_ff @(posedge aclk or negedge areset_n) begin
                    if (!areset_n) begin
                        tx[k].tkeep <= '0;
                    end
                    else if (tx[k].tready) begin
                        tx[k].tkeep <= prev.tkeep;
                    end
                end
            end
            else begin: tkeep_disabled
                always_comb tx[k].tkeep = '1;
            end

            if ((TDATA_BYTES > 0) && (USE_TSTRB > 0)) begin: tstrb_enabled
                always_ff @(posedge aclk or negedge areset_n) begin
                    if (!areset_n) begin
                        tx[k].tstrb <= '0;
                    end
                    else if (tx[k].tready) begin
                        tx[k].tstrb <= prev.tstrb;
                    end
                end
            end
            else begin: tstrb_disabled
                always_comb tx[k].tstrb = '1;
            end

            if (USE_TLAST > 0) begin: tlast_enabled
                always_ff @(posedge aclk or negedge areset_n) begin
                    if (!areset_n) begin
                        tx[k].tlast <= '0;
                    end
                    else if (tx[k].tready) begin
                        tx[k].tlast <= prev.tlast;
                    end
                end
            end
            else begin: tlast_disabled
                always_comb tx[k].tlast = '1;
            end

            if (TUSER_WIDTH > 0) begin: tuser_enabled
                always_ff @(posedge aclk or negedge areset_n) begin
                    if (!areset_n) begin
                        tx[k].tuser <= '0;
                    end
                    else if (tx[k].tready) begin
                        tx[k].tuser <= prev.tuser;
                    end
                end
            end
            else begin: tuser_disabled
                always_comb tx[k].tuser = '0;
            end

            if (TDEST_WIDTH > 0) begin: tdest_enabled
                always_ff @(posedge aclk or negedge areset_n) begin
                    if (!areset_n) begin
                        tx[k].tdest <= '0;
                    end
                    else if (tx[k].tready) begin
                        tx[k].tdest <= prev.tdest;
                    end
                end
            end
            else begin: tdest_disabled
                always_comb tx[k].tdest = '0;
            end

            if (TID_WIDTH > 0) begin: tid_enabled
                always_ff @(posedge aclk or negedge areset_n) begin
                    if (!areset_n) begin
                        tx[k].tid <= '0;
                    end
                    else if (tx[k].tready) begin
                        tx[k].tid <= prev.tid;
                    end
                end
            end
            else begin: tid_disabled
                always_comb tx[k].tid = '0;
            end
        end

        if (USE_TID > 0) begin: use_tid
            always_comb begin
                select = '0;
                for (int i = FIRST; i < LAST; ++i) begin
                    select[i - FIRST] = (prev.tid == i[TID_WIDTH-1:0]);
                end
                select[OUTPUTS] = ~|select[OUTPUTS-1:0];
            end
        end
        else begin: use_tdest
            always_comb begin
                select = '0;
                for (int i = FIRST; i < LAST; ++i) begin
                    select[i - FIRST] = (prev.tdest == i[TDEST_WIDTH-1:0]);
                end
                select[OUTPUTS] = ~|select[OUTPUTS-1:0];
            end
        end
    endgenerate
endmodule

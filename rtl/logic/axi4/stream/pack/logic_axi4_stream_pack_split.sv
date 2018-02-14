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

/* Module: logic_axi4_stream_pack_split
 *
 * Count valid bytes.
 *
 * Ports:
 *  rx          - AXI4-Stream Rx interface.
 *  tx          - AXI4-Stream Tx interface.
 */
module logic_axi4_stream_pack_split #(
    int TDATA_BYTES = 4
) (
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx[2]
);
    localparam int OUTPUTS = 2;

    genvar k;

    always_comb rx.tready = tx[0].tready;

    always_comb tx[0].tlast = rx.tlast && ~|rx.tkeep[TDATA_BYTES+:TDATA_BYTES];
    always_comb tx[1].tlast = rx.tlast;

    generate
        for (k = 0; k < OUTPUTS; ++k) begin: map
            always_comb tx[k].tvalid = rx.tvalid;
            always_comb tx[k].tdata = rx.tdata[k*TDATA_BYTES+:TDATA_BYTES];
            always_comb tx[k].tstrb = rx.tstrb[k*TDATA_BYTES+:TDATA_BYTES];
            always_comb tx[k].tkeep = rx.tkeep[k*TDATA_BYTES+:TDATA_BYTES];
            always_comb tx[k].tuser = rx.tuser;
            always_comb tx[k].tdest = rx.tdest;
            always_comb tx[k].tid = rx.tid;
        end
    endgenerate
endmodule

/* Copyright 2017 Tymoteusz Blazejczyk
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * @copyright
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`include "logic.svh"

/* Interface: logic_axi4_stream_if
 *
 * AXI4-Stream interface.
 *
 * Parameters:
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *
 * Ports:
 *  aclk        - Clock. Used only for internal checkers and assertions
 *  areset_n    - Asynchronous active-low reset. Used only for internal checkers
 *                and assertions
 */
interface logic_axi4_stream_if #(
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1
) (
    input aclk,
    input areset_n
);
    localparam TSTRB_WIDTH = TDATA_BYTES;
    localparam TKEEP_WIDTH = TDATA_BYTES;

    typedef logic [TDATA_BYTES-1:0][7:0] tdata_t;
    typedef logic [TSTRB_WIDTH-1:0] tstrb_t;
    typedef logic [TKEEP_WIDTH-1:0] tkeep_t;
    typedef logic [TDEST_WIDTH-1:0] tdest_t;
    typedef logic [TUSER_WIDTH-1:0] tuser_t;
    typedef logic [TID_WIDTH-1:0] tid_t;

    typedef struct packed {
        tuser_t tuser;
        tdest_t tdest;
        tid_t tid;
        logic tlast;
        tkeep_t tkeep;
        tstrb_t tstrb;
        tdata_t tdata;
    } packet_t;

    logic tready;
    logic tvalid;
    logic tlast;
    tdata_t tdata;
    tstrb_t tstrb;
    tkeep_t tkeep;
    tdest_t tdest;
    tuser_t tuser;
    tid_t tid;

    function packet_t read();
        return '{tuser, tdest, tid, tlast, tkeep, tstrb, tdata};
    endfunction

    task write(packet_t packet);
        {tuser, tdest, tid, tlast, tkeep, tstrb, tdata} <= packet;
    endtask

    task comb_write(packet_t packet);
        {tuser, tdest, tid, tlast, tkeep, tstrb, tdata} = packet;
    endtask

`ifndef LOGIC_MODPORT_DISABLED
    modport rx (
        input tvalid,
        input tuser,
        input tdest,
        input tid,
        input tlast,
        input tkeep,
        input tstrb,
        input tdata,
        output tready,
        import read
    );

    modport tx (
        output tvalid,
        output tuser,
        output tdest,
        output tid,
        output tlast,
        output tkeep,
        output tstrb,
        output tdata,
        input tready,
        import write,
        import comb_write
    );

    modport mon (
        input tvalid,
        input tuser,
        input tdest,
        input tid,
        input tlast,
        input tkeep,
        input tstrb,
        input tdata,
        input tready,
        import read
    );
`endif
endinterface

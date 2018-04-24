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

/* Module: logic_axi4_lite_bus_multi_slave
 *
 * Multi-master multi-slave bus.
 *
 * Parameters:
 *  CAPACITY        - Number of single data transactions that can be
 *                    store in internal queue memory (FIFO capacity).
 *  SLAVES          - Number of slaves connected to the AXI4-Lite bus.
 *  MASTERS         - Number of masters connected to the AXI4-Lite bus.
 *  DATA_BYTES      - Number of bytes for wdata and rdata signals.
 *  ADDRESS_WIDTH   - Number of bits for awaddr and araddr signals.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  slave       - AXI4-Lite slave interface.
 *  master      - AXI$-Lite master interface.
 */
module logic_axi4_lite_bus_multi_slave #(
    int CAPACITY = 256,
    int SLAVES = 1,
    int SLAVES_WIDTH = (SLAVES >= 2) ? $clog2(SLAVES) : 1,
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1,
    logic_axi4_lite_bus_pkg::slave_t [SLAVES-1:0] MAP
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_lite_if, slave) slave,
    `LOGIC_MODPORT(logic_axi4_lite_if, master) master[SLAVES]
);
    genvar k;

    logic_axi4_stream_if #(
        .TDATA_BYTES(0),
        .TDEST_WIDTH(0),
        .TUSER_WIDTH(1),
        .TID_WIDTH(SLAVES_WIDTH),
        .USE_TKEEP(0),
        .USE_TSTRB(0),
        .USE_TLAST(0)
    )
    slave_id [5] (
        .aclk(aclk),
        .areset_n(areset_n)
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(0),
        .TDEST_WIDTH(0),
        .TUSER_WIDTH(1),
        .TID_WIDTH(SLAVES_WIDTH),
        .USE_TKEEP(0),
        .USE_TSTRB(0),
        .USE_TLAST(0)
    )
    slave_id_queued [5] (
        .aclk(aclk),
        .areset_n(areset_n)
    );

    logic_axi4_lite_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    buffered (
        .*
    );

    logic_axi4_lite_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    decoded (
        .*
    );

    logic_axi4_lite_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    decoded_queued (
        .*
    );

    logic_axi4_lite_if #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    muxed [SLAVES] (
        .aclk(aclk),
        .areset_n(areset_n)
    );

    logic_axi4_lite_buffer #(
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .WRITE_ADDRESS_CHANNEL(1),
        .WRITE_DATA_CHANNEL(1),
        .WRITE_RESPONSE_CHANNEL(0),
        .READ_ADDRESS_CHANNEL(1),
        .READ_DATA_CHANNEL(0)
    )
    buffer (
        .slave(slave),
        .master(buffered),
        .*
    );

    logic_axi4_lite_bus_multi_slave_decoder #(
        .SLAVES(SLAVES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .MAP(MAP)
    )
    decoder (
        .slave(buffered),
        .master(decoded),
        .write_address_channel(slave_id[0]),
        .write_data_channel(slave_id[1]),
        .write_response_channel(slave_id[2]),
        .read_address_channel(slave_id[3]),
        .read_data_channel(slave_id[4]),
        .*
    );

    logic_axi4_lite_queue #(
        .CAPACITY(CAPACITY),
        .DATA_BYTES(DATA_BYTES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    axi4_lite_queue (
        .slave(decoded),
        .master(decoded_queued),
        .*
    );

    generate
        for (k = 0; k < 5; ++k) begin: channels
            logic_axi4_stream_queue #(
                .CAPACITY(CAPACITY),
                .TDATA_BYTES(0),
                .TDEST_WIDTH(0),
                .TUSER_WIDTH(1),
                .TID_WIDTH(SLAVES_WIDTH),
                .USE_TKEEP(0),
                .USE_TSTRB(0),
                .USE_TLAST(0)
            )
            axi4_stream_queue (
                .rx(slave_id[k]),
                .tx(slave_id_queued[k]),
                .*
            );
        end
    endgenerate

    logic_axi4_lite_bus_multi_slave_mux #(
        .SLAVES(SLAVES),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    mux (
        .slave(decoded_queued),
        .master(muxed),
        .write_address_channel(slave_id_queued[0]),
        .write_data_channel(slave_id_queued[1]),
        .write_response_channel(slave_id_queued[2]),
        .read_address_channel(slave_id_queued[3]),
        .read_data_channel(slave_id_queued[4]),
        .*
    );

    generate
        for (k = 0; k < SLAVES; ++k) begin: buffers
            logic_axi4_lite_buffer #(
                .DATA_BYTES(DATA_BYTES),
                .ADDRESS_WIDTH(ADDRESS_WIDTH),
                .WRITE_ADDRESS_CHANNEL(0),
                .WRITE_DATA_CHANNEL(0),
                .WRITE_RESPONSE_CHANNEL(1),
                .READ_ADDRESS_CHANNEL(0),
                .READ_DATA_CHANNEL(1)
            )
            decode_buffer (
                .slave(muxed[k]),
                .master(master[k]),
                .*
            );
        end
    endgenerate
endmodule

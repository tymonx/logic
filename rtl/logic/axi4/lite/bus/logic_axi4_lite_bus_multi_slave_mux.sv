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

/* Module: logic_axi4_lite_bus_multi_slave_mux
 *
 * Multi-master multi-slave bus.
 *
 * Parameters:
 *  SLAVES          - Number of slaves connected to the AXI4-Lite bus.
 *  DATA_BYTES      - Number of bytes for wdata and rdata signals.
 *  ADDRESS_WIDTH   - Number of bits for awaddr and araddr signals.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  slave       - AXI4-Lite slave interface.
 *  master      - AXI4-Lite master interface.
 */
module logic_axi4_lite_bus_multi_slave_mux #(
    int SLAVES = 1,
    int SLAVES_WIDTH = (SLAVES >= 2) ? $clog2(SLAVES) : 1,
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) write_address_channel,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) write_data_channel,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) write_response_channel,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) read_address_channel,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) read_data_channel,
    `LOGIC_MODPORT(logic_axi4_lite_if, slave) slave,
    `LOGIC_MODPORT(logic_axi4_lite_if, master) master[SLAVES]
);
    localparam SLAVES_MUX = 2**SLAVES_WIDTH;

    genvar k;

    logic [SLAVES-1:0] wready;
    logic [SLAVES-1:0] awready;
    logic [SLAVES-1:0] arready;

    logic [SLAVES_MUX-1:0] rvalid;
    logic [DATA_BYTES-1:0][7:0] rdata[0:SLAVES_MUX-1];
    logic_axi4_lite_pkg::response_t rresp[0:SLAVES_MUX-1];

    logic [SLAVES_MUX-1:0] bvalid;
    logic_axi4_lite_pkg::response_t bresp[0:SLAVES_MUX-1];

    always_comb slave.wready = !slave.wvalid || (
        write_data_channel.tvalid && (
        write_data_channel.tuser[0] ? |wready : 1'b1));

    always_comb slave.awready = !slave.awvalid || (
        write_address_channel.tvalid && (
        write_address_channel.tuser[0] ? |awready : 1'b1));

    always_comb slave.arready = !slave.arvalid || (
        read_address_channel.tvalid && (
        read_address_channel.tuser[0] ? |arready : 1'b1));

    always_comb write_address_channel.tready = !write_address_channel.tvalid ||
        (slave.awvalid && (write_address_channel.tuser[0] ? |awready : 1'b1));

    always_comb write_data_channel.tready = !write_data_channel.tvalid ||
        (slave.wvalid && (write_data_channel.tuser[0] ? |wready : 1'b1));

    always_comb write_response_channel.tready = !write_response_channel.tvalid
        || (slave.bready && (write_response_channel.tuser[0] ?
        bvalid[write_response_channel.tid] : 1'b1));

    always_comb read_address_channel.tready = !read_address_channel.tvalid ||
        (slave.arvalid && (read_address_channel.tuser[0] ? |arready : 1'b1));

    always_comb read_data_channel.tready = !read_data_channel.tvalid
        || (slave.rready && (read_data_channel.tuser[0] ?
        rvalid[read_data_channel.tid] : 1'b1));

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            slave.bvalid <= '0;
        end
        else if (slave.bready) begin
            slave.bvalid <= write_response_channel.tvalid && (
                write_response_channel.tuser[0] ?
                bvalid[write_response_channel.tid] : 1'b1
            );
        end
    end

    always_ff @(posedge aclk) begin
        if (slave.bready) begin
            slave.bresp <= write_response_channel.tuser[0] ?
                bresp[write_response_channel.tid] :
                logic_axi4_lite_pkg::RESPONSE_DECERR;
        end
    end

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            slave.rvalid <= '0;
        end
        else if (slave.rready) begin
            slave.rvalid <= read_data_channel.tvalid && (
                read_data_channel.tuser[0] ?
                rvalid[read_data_channel.tid] : 1'b1
            );
        end
    end

    always_ff @(posedge aclk) begin
        if (slave.rready) begin
            slave.rresp <= write_response_channel.tuser[0] ?
                rresp[read_data_channel.tid] :
                logic_axi4_lite_pkg::RESPONSE_DECERR;
        end
    end

    always_ff @(posedge aclk) begin
        if (slave.rready) begin
            slave.rdata <= write_response_channel.tuser[0] ?
                rdata[read_data_channel.tid] : {DATA_BYTES{8'b0}};
        end
    end

    generate
        for (k = 0; k < SLAVES; ++k) begin: slaves
            always_comb wready[k] = master[k].wready &&
                (write_data_channel.tid == k[SLAVES_WIDTH-1:0]);

            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    master[k].wvalid <= '0;
                end
                else if (master[k].wready) begin
                    master[k].wvalid <= slave.wvalid && wready[k];
                end
            end

            always_ff @(posedge aclk) begin
                if (master[k].wready) begin
                    master[k].wdata <= slave.wdata;
                    master[k].wstrb <= slave.wstrb;
                end
            end

            always_comb awready[k] = master[k].awready &&
                (write_address_channel.tid == k[SLAVES_WIDTH-1:0]);

            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    master[k].awvalid <= '0;
                end
                else if (master[k].awready) begin
                    master[k].awvalid <= slave.awvalid && awready[k];
                end
            end

            always_ff @(posedge aclk) begin
                if (master[k].awready) begin
                    master[k].awaddr <= slave.awaddr;
                    master[k].awprot <= slave.awprot;
                end
            end

            always_comb arready[k] = master[k].arready &&
                (read_address_channel.tid == k[SLAVES_WIDTH-1:0]);

            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    master[k].arvalid <= '0;
                end
                else if (master[k].arready) begin
                    master[k].arvalid <= slave.arvalid && arready[k];
                end
            end

            always_ff @(posedge aclk) begin
                if (master[k].arready) begin
                    master[k].araddr <= slave.araddr;
                    master[k].arprot <= slave.arprot;
                end
            end

            always_comb bvalid[k] = master[k].bvalid;
            always_comb bresp[k] = master[k].bresp;
            always_comb master[k].bready = !master[k].bvalid ||
                (slave.bready && write_response_channel.tvalid &&
                write_response_channel.tuser[0] &&
                (write_response_channel.tid == k[SLAVES_WIDTH-1:0]));

            always_comb rvalid[k] = master[k].rvalid;
            always_comb rresp[k] = master[k].rresp;
            always_comb rdata[k] = master[k].rdata;
            always_comb master[k].rready = !master[k].rvalid ||
                (slave.rready && read_data_channel.tvalid &&
                read_data_channel.tuser[0] &&
                (read_data_channel.tid == k[SLAVES_WIDTH-1:0]));
        end

        for (k = SLAVES; k < SLAVES_MUX; ++k) begin: assign_unknown
            always_comb bvalid[k] = 'X;
            always_comb bresp[k] = logic_axi4_lite_pkg::response_t'('X);

            always_comb rvalid[k] = 'X;
            always_comb rresp[k] = logic_axi4_lite_pkg::response_t'('X);
            always_comb rdata[k] = 'X;
        end
    endgenerate
endmodule

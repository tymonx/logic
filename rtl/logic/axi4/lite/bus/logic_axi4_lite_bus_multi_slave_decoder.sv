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

/* Module: logic_axi4_lite_bus_multi_slave_decoder
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
module logic_axi4_lite_bus_multi_slave_decoder #(
    int SLAVES = 1,
    int SLAVES_WIDTH = (SLAVES >= 2) ? $clog2(SLAVES) : 1,
    int ADDRESS_WIDTH = 1,
    logic_axi4_lite_bus_pkg::slave_t [SLAVES-1:0] MAP
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) write_address_channel,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) write_data_channel,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) write_response_channel,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) read_address_channel,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) read_data_channel,
    `LOGIC_MODPORT(logic_axi4_lite_if, slave) slave,
    `LOGIC_MODPORT(logic_axi4_lite_if, master) master
);
    genvar k;

    typedef struct packed {
        logic valid;
        logic [SLAVES_WIDTH-1:0] value;
    } slave_id_t;

    slave_id_t write_slave_id;
    slave_id_t read_slave_id;

    logic [SLAVES-1:0] write_slave;
    logic [SLAVES-1:0] read_slave;

    always_comb slave.wready = !slave.wvalid || (master.wready &&
        write_data_channel.tready && write_address_channel.tready &&
        write_response_channel.tready);

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            master.wvalid <= '0;
        end
        else if (master.wready) begin
            master.wvalid <= slave.wvalid && write_data_channel.tready &&
                write_address_channel.tready && write_response_channel.tready;
        end
    end

    always_ff @(posedge aclk) begin
        if (master.wready) begin
            master.wdata <= slave.wdata;
            master.wstrb <= slave.wstrb;
        end
    end

    always_comb slave.awready = !slave.awvalid || (master.awready &&
        write_data_channel.tready && write_address_channel.tready &&
        write_response_channel.tready);

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            master.awvalid <= '0;
        end
        else if (master.awready) begin
            master.awvalid <= slave.awvalid && write_data_channel.tready &&
                write_address_channel.tready && write_response_channel.tready;
        end
    end

    always_ff @(posedge aclk) begin
        if (master.awready) begin
            master.awaddr <= slave.awaddr;
            master.awprot <= slave.awprot;
        end
    end

    always_comb slave.arready = !slave.arvalid || (master.arready &&
        read_data_channel.tready && read_address_channel.tready);

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            master.arvalid <= '0;
        end
        else if (master.arready) begin
            master.arvalid <= slave.arvalid && read_data_channel.tready &&
                read_address_channel.tready;
        end
    end

    always_ff @(posedge aclk) begin
        if (master.arready) begin
            master.araddr <= slave.araddr;
            master.arprot <= slave.arprot;
        end
    end

    always_comb slave.rvalid = master.rvalid;
    always_comb slave.rdata = master.rdata;
    always_comb slave.rresp = master.rresp;
    always_comb master.rready = slave.rready;

    always_comb slave.bvalid = master.bvalid;
    always_comb slave.bresp = master.bresp;
    always_comb master.bready = slave.bready;

    /* verilator lint_off UNSIGNED */

    generate
        for (k = 0; k < SLAVES; ++k) begin: mapping
            always_comb write_slave[k] =
                (slave.awaddr >= MAP[k].address_low[ADDRESS_WIDTH-1:0]) &&
                (slave.awaddr < MAP[k].address_high[ADDRESS_WIDTH-1:0]);

            always_comb read_slave[k] =
                (slave.araddr >= MAP[k].address_low[ADDRESS_WIDTH-1:0]) &&
                (slave.araddr < MAP[k].address_high[ADDRESS_WIDTH-1:0]);
        end
    endgenerate

    /* verilator lint_on UNSIGNED */

    always_comb begin
        write_slave_id = '0;

        for (int i = 0; i < SLAVES; ++i) begin
           if (write_slave[i]) begin
                write_slave_id = '{valid: '1, value: i[SLAVES_WIDTH-1:0]};
            end
        end
    end

    always_comb begin
        read_slave_id = '0;

        for (int i = 0; i < SLAVES; ++i) begin
           if (read_slave[i]) begin
                read_slave_id = '{valid: '1, value: i[SLAVES_WIDTH-1:0]};
            end
        end
    end

    always_comb write_address_channel.tlast = '1;
    always_comb write_address_channel.tstrb = '1;
    always_comb write_address_channel.tkeep = '1;
    always_comb write_address_channel.tdata = '0;
    always_comb write_address_channel.tdest = '0;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            write_address_channel.tvalid <= 1'b0;
        end
        else if (write_address_channel.tready) begin
            write_address_channel.tvalid <= slave.awvalid && master.awready &&
                write_data_channel.tready && write_response_channel.tready;
        end
    end

    always_ff @(posedge aclk) begin
        if (write_address_channel.tready) begin
            write_address_channel.tid <= write_slave_id.value;
            write_address_channel.tuser <= write_slave_id.valid;
        end
    end

    always_comb write_data_channel.tlast = '1;
    always_comb write_data_channel.tstrb = '1;
    always_comb write_data_channel.tkeep = '1;
    always_comb write_data_channel.tdata = '0;
    always_comb write_data_channel.tdest = '0;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            write_data_channel.tvalid <= 1'b0;
        end
        else if (write_data_channel.tready) begin
            write_data_channel.tvalid <= slave.awvalid && master.awready &&
                write_address_channel.tready && write_response_channel.tready;
        end
    end

    always_ff @(posedge aclk) begin
        if (write_data_channel.tready) begin
            write_data_channel.tid <= write_slave_id.value;
            write_data_channel.tuser <= write_slave_id.valid;
        end
    end

    always_comb write_response_channel.tlast = '1;
    always_comb write_response_channel.tstrb = '1;
    always_comb write_response_channel.tkeep = '1;
    always_comb write_response_channel.tdata = '0;
    always_comb write_response_channel.tdest = '0;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            write_response_channel.tvalid <= 1'b0;
        end
        else if (write_response_channel.tready) begin
            write_response_channel.tvalid <= slave.awvalid && master.awready &&
                write_address_channel.tready && write_data_channel.tready;
        end
    end

    always_ff @(posedge aclk) begin
        if (write_response_channel.tready) begin
            write_response_channel.tid <= write_slave_id.value;
            write_response_channel.tuser <= write_slave_id.valid;
        end
    end

    always_comb read_address_channel.tlast = '1;
    always_comb read_address_channel.tstrb = '1;
    always_comb read_address_channel.tkeep = '1;
    always_comb read_address_channel.tdata = '0;
    always_comb read_address_channel.tdest = '0;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            read_address_channel.tvalid <= 1'b0;
        end
        else if (read_address_channel.tready) begin
            read_address_channel.tvalid <= slave.arvalid && master.arready &&
                read_data_channel.tready;
        end
    end

    always_ff @(posedge aclk) begin
        if (read_address_channel.tready) begin
            read_address_channel.tid <= read_slave_id.value;
            read_address_channel.tuser <= read_slave_id.valid;
        end
    end

    always_comb read_data_channel.tlast = '1;
    always_comb read_data_channel.tstrb = '1;
    always_comb read_data_channel.tkeep = '1;
    always_comb read_data_channel.tdata = '0;
    always_comb read_data_channel.tdest = '0;

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            read_data_channel.tvalid <= 1'b0;
        end
        else if (read_data_channel.tready) begin
            read_data_channel.tvalid <= slave.arvalid && master.arready &&
                read_address_channel.tready;
        end
    end

    always_ff @(posedge aclk) begin
        if (read_data_channel.tready) begin
            read_data_channel.tid <= read_slave_id.value;
            read_data_channel.tuser <= read_slave_id.valid;
        end
    end
endmodule

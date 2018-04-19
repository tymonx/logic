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

/* Module: logic_axi4_lite_queue
 *
 * Improve timings between modules by adding register to ready signal path from
 * tx to rx ports and it keeps zero latency bus transcation on both sides.
 *
 * Parameters:
 *  CAPACITY                - Number of single data transactions that can be
 *                            store in internal queue memory (FIFO capacity).
 *  DATA_BYTES              - Number of bytes for wdata and rdata signals.
 *  ADDRESS_WIDTH           - Number of bits for awaddr and araddr signals.
 *  WRITE_ADDRESS_CAPACITY  - Enable or disable queue for write address
 *                            channel.
 *  WRITE_DATA_CAPACITY     - Enable or disable queue for write data channel.
 *  WRITE_RESPONSE_CAPACITY - Enable or disable queue for write response
 *                            channel.
 *  READ_ADDRESS_CAPACITY   - Enable or disable queue for read address channel.
 *  READ_DATA_CAPACITY      - Enable or disable queue for read data channel.
 *  MASTER                  - Enable or disable queue for master port.
 *
 * Ports:
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  slave       - AXI4-Lite slave interface.
 *  master      - AXI4-Lite master interface.
 */
module logic_axi4_lite_queue #(
    int CAPACITY = 256,
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1,
    int WRITE_ADDRESS_CAPACITY = CAPACITY,
    int WRITE_DATA_CAPACITY = CAPACITY,
    int WRITE_RESPONSE_CAPACITY = CAPACITY,
    int READ_ADDRESS_CAPACITY = CAPACITY,
    int READ_DATA_CAPACITY = CAPACITY
) (
    input aclk,
    input areset_n,
    `LOGIC_MODPORT(logic_axi4_lite_if, slave) slave,
    `LOGIC_MODPORT(logic_axi4_lite_if, master) master
);
    localparam STRB_WIDTH = DATA_BYTES;
    localparam DATA_WIDTH = 8 * DATA_BYTES;
    localparam PROT_WIDTH = $bits(logic_axi4_lite_pkg::access_t);
    localparam RESP_WIDTH = $bits(logic_axi4_lite_pkg::response_t);

    typedef logic [ADDRESS_WIDTH-1:0] araddr_t;
    typedef logic [ADDRESS_WIDTH-1:0] awaddr_t;
    typedef logic [DATA_BYTES-1:0][7:0] wdata_t;
    typedef logic [DATA_BYTES-1:0][7:0] rdata_t;
    typedef logic [DATA_BYTES-1:0] wstrb_t;
    typedef logic_axi4_lite_pkg::response_t rresp_t;
    typedef logic_axi4_lite_pkg::response_t bresp_t;
    typedef logic_axi4_lite_pkg::access_t awprot_t;
    typedef logic_axi4_lite_pkg::access_t arprot_t;

    /* Write address channel */
    logic slave_awvalid;
    logic slave_awready;
    awaddr_t slave_awaddr;
    awprot_t slave_awprot;

    /* Write data channel */
    logic slave_wvalid;
    logic slave_wready;
    wdata_t slave_wdata;
    wstrb_t slave_wstrb;

    /* Write response channel */
    logic slave_bvalid;
    logic slave_bready;
    bresp_t slave_bresp;

    /* Read address channel */
    logic slave_arvalid;
    logic slave_arready;
    araddr_t slave_araddr;
    arprot_t slave_arprot;

    /* Read data channel */
    logic slave_rvalid;
    logic slave_rready;
    rdata_t slave_rdata;
    rresp_t slave_rresp;

    /* Write address channel */
    logic master_awvalid;
    logic master_awready;
    awaddr_t master_awaddr;
    awprot_t master_awprot;

    /* Write data channel */
    logic master_wvalid;
    logic master_wready;
    wdata_t master_wdata;
    wstrb_t master_wstrb;

    /* Write response channel */
    logic master_bvalid;
    logic master_bready;
    bresp_t master_bresp;

    /* Read address channel */
    logic master_arvalid;
    logic master_arready;
    araddr_t master_araddr;
    arprot_t master_arprot;

    /* Read data channel */
    logic master_rvalid;
    logic master_rready;
    rdata_t master_rdata;
    rresp_t master_rresp;

    `LOGIC_AXI4_LITE_IF_MASTER_ASSIGN(slave, slave);

    generate
        if (WRITE_ADDRESS_CAPACITY > 0) begin: write_address_channel_enabled
            logic_basic_queue #(
                .WIDTH(PROT_WIDTH + ADDRESS_WIDTH)
            )
            write_address_channel (
                /* Slave */
                .rx_tvalid(slave_awvalid),
                .rx_tready(slave_awready),
                .rx_tdata({slave_awprot, slave_awaddr}),
                /* Master */
                .tx_tvalid(master_awvalid),
                .tx_tready(master_awready),
                .tx_tdata({master_awprot, master_awaddr}),
                .*
            );
        end
        else begin: write_address_channel_disabled
            always_comb master_awvalid = slave_awvalid;
            always_comb master_awaddr = slave_awaddr;
            always_comb master_awprot = slave_awprot;
            always_comb slave_awready = master_awready;
        end

        if (WRITE_DATA_CAPACITY > 0) begin: write_data_channel_enabled
            logic_basic_queue #(
                .WIDTH(STRB_WIDTH + DATA_WIDTH)
            )
            write_data_channel (
                /* Slave */
                .rx_tvalid(slave_wvalid),
                .rx_tready(slave_wready),
                .rx_tdata({slave_wstrb, slave_wdata}),
                /* Master */
                .tx_tvalid(master_wvalid),
                .tx_tready(master_wready),
                .tx_tdata({master_wstrb, master_wdata}),
                .*
            );
        end
        else begin: write_data_channel_disabled
            always_comb master_wvalid = slave_wvalid;
            always_comb master_wdata = slave_wdata;
            always_comb master_wstrb = slave_wstrb;
            always_comb slave_wready = master_wready;
        end

        if (WRITE_RESPONSE_CAPACITY > 0) begin: write_response_channel_enabled
            logic_basic_queue #(
                .WIDTH(RESP_WIDTH)
            )
            write_response_channel (
                /* Slave */
                .rx_tvalid(master_bvalid),
                .rx_tready(master_bready),
                .rx_tdata(master_bresp),
                /* Master */
                .tx_tvalid(slave_bvalid),
                .tx_tready(slave_bready),
                .tx_tdata({slave_bresp}),
                .*
            );
        end
        else begin: write_response_channel_disabled
            always_comb slave_bvalid = master_bvalid;
            always_comb slave_bresp = master_bresp;
            always_comb master_bready = slave_bready;
        end

        if (READ_ADDRESS_CAPACITY > 0) begin: read_address_channel_enabled
            logic_basic_queue #(
                .WIDTH(PROT_WIDTH + ADDRESS_WIDTH)
            )
            read_address_channel (
                /* Slave */
                .rx_tvalid(slave_arvalid),
                .rx_tready(slave_arready),
                .rx_tdata({slave_arprot, slave_araddr}),
                /* Master */
                .tx_tvalid(master_arvalid),
                .tx_tready(master_arready),
                .tx_tdata({master_arprot, master_araddr}),
                .*
            );

        end
        else begin: read_address_channel_disabled
            always_comb master_arvalid = slave_arvalid;
            always_comb master_araddr = slave_araddr;
            always_comb master_arprot = slave_arprot;
            always_comb slave_arready = master_arready;
        end

        if (READ_DATA_CAPACITY > 0) begin: read_data_channel_enabled
            logic_basic_queue #(
                .WIDTH(RESP_WIDTH + DATA_WIDTH)
            )
            read_data_channel (
                /* Slave */
                .rx_tvalid(master_rvalid),
                .rx_tready(master_rready),
                .rx_tdata({master_rresp, master_rdata}),
                /* Master */
                .tx_tvalid(slave_rvalid),
                .tx_tready(slave_rready),
                .tx_tdata({slave_rresp, slave_rdata}),
                .*
            );
        end
        else begin: read_data_channel_disabled
            always_comb slave_rvalid = master_rvalid;
            always_comb slave_rdata = master_rdata;
            always_comb slave_rresp = master_rresp;
            always_comb master_rready = slave_rready;
        end
    endgenerate

    `LOGIC_AXI4_LITE_IF_SLAVE_ASSIGN(master, master);
endmodule

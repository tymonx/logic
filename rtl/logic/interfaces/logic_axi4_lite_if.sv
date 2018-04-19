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

/* Interface: logic_axi4_lite_if
 *
 * AXI4-Lite interface.
 *
 * Parameters:
 *  DATA_BYTES      - Number of bytes for wdata and rdata signals.
 *  ADDRESS_WIDTH   - Number of bits for awaddr and araddr signals.
 *
 * Ports:
 *  aclk        - Clock. Used only for internal checkers and assertions
 *  areset_n    - Asynchronous active-low reset. Used only for internal checkers
 *                and assertions
 */
interface logic_axi4_lite_if #(
    int DATA_BYTES = 4,
    int ADDRESS_WIDTH = 1,
    int AWADDR_WIDTH = ADDRESS_WIDTH,
    int ARADDR_WIDTH = ADDRESS_WIDTH
) (
    input aclk,
    input areset_n
);
    initial begin: design_rule_checks
        `LOGIC_DRC_POWER_OF_2(DATA_BYTES)
        `LOGIC_DRC_RANGE(DATA_BYTES, 4, 8)
    end

    typedef logic [ARADDR_WIDTH-1:0] araddr_t;
    typedef logic [AWADDR_WIDTH-1:0] awaddr_t;
    typedef logic [DATA_BYTES-1:0][7:0] wdata_t;
    typedef logic [DATA_BYTES-1:0][7:0] rdata_t;
    typedef logic [DATA_BYTES-1:0] wstrb_t;
    typedef logic_axi4_lite_pkg::response_t rresp_t;
    typedef logic_axi4_lite_pkg::response_t bresp_t;
    typedef logic_axi4_lite_pkg::access_t awprot_t;
    typedef logic_axi4_lite_pkg::access_t arprot_t;

`ifdef SYNTHESIS
    /* Write address channel */
    logic awvalid;
    logic awready;
    awaddr_t awaddr;
    awprot_t awprot;

    /* Write data channel */
    logic wvalid;
    logic wready;
    wdata_t wdata;
    wstrb_t wstrb;

    /* Write response channel */
    logic bvalid;
    logic bready;
    bresp_t bresp;

    /* Read address channel */
    logic arvalid;
    logic arready;
    araddr_t araddr;
    arprot_t arprot;

    /* Read data channel */
    logic rvalid;
    logic rready;
    rdata_t rdata;
    rresp_t rresp;
`else
    /* Write address channel */
    logic awvalid = 'X;
    logic awready = 'X;
    awaddr_t awaddr = 'X;
    awprot_t awprot = logic_axi4_lite_pkg::access_t'('X);

    /* Write data channel */
    logic wvalid = 'X;
    logic wready = 'X;
    wdata_t wdata = 'X;
    wstrb_t wstrb = 'X;

    /* Write response channel */
    logic bvalid = 'X;
    logic bready = 'X;
    bresp_t bresp = logic_axi4_lite_pkg::response_t'('X);

    /* Read address channel */
    logic arvalid = 'X;
    logic arready = 'X;
    araddr_t araddr = 'X;
    arprot_t arprot = logic_axi4_lite_pkg::access_t'('X);

    /* Read data channel */
    logic rvalid = 'X;
    logic rready = 'X;
    rdata_t rdata = 'X;
    rresp_t rresp = logic_axi4_lite_pkg::response_t'('X);
`endif

`ifndef LOGIC_MODPORT_DISABLED
    modport slave (
        /* Write address channel */
        input awvalid,
        output awready,
        input awaddr,
        input awprot,
        /* Write data channel */
        input wvalid,
        output wready,
        input wdata,
        input wstrb,
        /* Write response channel */
        output bvalid,
        input bready,
        output bresp,
        /* Read address channel */
        input arvalid,
        output arready,
        input araddr,
        input arprot,
        /* Read data channel */
        output rvalid,
        input rready,
        output rdata,
        output rresp
    );

    modport master (
        /* Write address channel */
        output awvalid,
        input awready,
        output awaddr,
        output awprot,
        /* Write data channel */
        output wvalid,
        input wready,
        output wdata,
        output wstrb,
        /* Write response channel */
        input bvalid,
        output bready,
        input bresp,
        /* Read address channel */
        output arvalid,
        input arready,
        output araddr,
        output arprot,
        /* Read data channel */
        input rvalid,
        output rready,
        input rdata,
        input rresp
    );

    modport monitor (
        /* Write address channel */
        input awvalid,
        input awready,
        input awaddr,
        input awprot,
        /* Write data channel */
        input wvalid,
        input wready,
        input wdata,
        input wstrb,
        /* Write response channel */
        input bvalid,
        input bready,
        input bresp,
        /* Read address channel */
        input arvalid,
        input arready,
        input araddr,
        input arprot,
        /* Read data channel */
        input rvalid,
        input rready,
        input rdata,
        input rresp
    );
`endif

`ifndef SYNTHESIS
    clocking cb_slave @(posedge aclk);
        /* Write address channel */
        inout awvalid;
        input awready;
        inout awaddr;
        inout awprot;
        /* Write data channel */
        inout wvalid;
        input wready;
        inout wdata;
        inout wstrb;
        /* Write response channel */
        input bvalid;
        inout bready;
        input bresp;
        /* Read address channel */
        inout arvalid;
        input arready;
        inout araddr;
        inout arprot;
        /* Read data channel */
        input rvalid;
        inout rready;
        input rdata;
        input rresp;
    endclocking

    modport cb_slave_modport (
        input areset_n,
        clocking cb_slave
    );

    clocking cb_master @(posedge aclk);
        /* Write address channel */
        input awvalid;
        inout awready;
        input awaddr;
        input awprot;
        /* Write data channel */
        input wvalid;
        inout wready;
        input wdata;
        input wstrb;
        /* Write response channel */
        inout bvalid;
        input bready;
        inout bresp;
        /* Read address channel */
        input arvalid;
        inout arready;
        input araddr;
        input arprot;
        /* Read data channel */
        inout rvalid;
        input rready;
        inout rdata;
        inout rresp;
    endclocking

    modport cb_master_modport (
        input areset_n,
        clocking cb_master
    );

    clocking cb_monitor @(posedge aclk);
        /* Write address channel */
        input awvalid;
        input awready;
        input awaddr;
        input awprot;
        /* Write data channel */
        input wvalid;
        input wready;
        input wdata;
        input wstrb;
        /* Write response channel */
        input bvalid;
        input bready;
        input bresp;
        /* Read address channel */
        input arvalid;
        input arready;
        input araddr;
        input arprot;
        /* Read data channel */
        input rvalid;
        input rready;
        input rdata;
        input rresp;
    endclocking

    modport cb_monitor_modport (
        input areset_n,
        clocking cb_monitor
    );
`endif

`ifdef OVL_ASSERT_ON
    generate
        if (1) begin: assertions
            logic write_address_bus_hold;
            logic write_data_bus_hold;
            logic write_response_bus_hold;
            logic read_address_bus_hold;
            logic read_data_bus_hold;

            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    write_data_bus_hold <= '0;
                end
                else if (!write_data_bus_hold && wvalid && !wready) begin
                    write_data_bus_hold <= '1;
                end
                else if (write_data_bus_hold && wready) begin
                    write_data_bus_hold <= '0;
                end
            end

            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    write_address_bus_hold <= '0;
                end
                else if (!write_address_bus_hold && awvalid && !awready) begin
                    write_address_bus_hold <= '1;
                end
                else if (write_address_bus_hold && awready) begin
                    write_address_bus_hold <= '0;
                end
            end

            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    write_response_bus_hold <= '0;
                end
                else if (!write_response_bus_hold && bvalid && !bready) begin
                    write_response_bus_hold <= '1;
                end
                else if (write_response_bus_hold && bready) begin
                    write_response_bus_hold <= '0;
                end
            end

            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    read_data_bus_hold <= '0;
                end
                else if (!read_data_bus_hold && rvalid && !rready) begin
                    read_data_bus_hold <= '1;
                end
                else if (read_data_bus_hold && rready) begin
                    read_data_bus_hold <= '0;
                end
            end

            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    read_address_bus_hold <= '0;
                end
                else if (!read_address_bus_hold && arvalid && !arready) begin
                    read_address_bus_hold <= '1;
                end
                else if (read_address_bus_hold && arready) begin
                    read_address_bus_hold <= '0;
                end
            end

            /* verilator lint_off UNUSED */
            /* verilator coverage_off */
            genvar k;

            logic [`OVL_FIRE_WIDTH-1:0] assert_wvalid_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("wvalid signal always must be in known 0 or 1 state")
            )
            assert_wvalid_never_unknown (
                .clock(aclk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(wvalid),
                .fire(assert_wvalid_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_wready_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("wready signal always must be in known 0 or 1 state")
            )
            assert_wready_never_unknown (
                .clock(aclk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(wready),
                .fire(assert_wready_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_wdata_never_unknown_fire;

            ovl_never_unknown #(
                .width(8 * DATA_BYTES),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("wdata signal cannot be unknown during active transfer")
            )
            assert_wdata_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(wvalid),
                .test_expr(wdata),
                .fire(assert_wdata_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_wstrb_never_unknown_fire;

            ovl_never_unknown #(
                .width(DATA_BYTES),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("wstrb signal cannot be unknown during active transfer")
            )
            assert_wstrb_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(wvalid),
                .test_expr(wstrb),
                .fire(assert_wstrb_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_awvalid_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("awvalid signal always must be in known 0 or 1 state")
            )
            assert_awvalid_never_unknown (
                .clock(aclk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(awvalid),
                .fire(assert_awvalid_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_awready_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("awready signal always must be in known 0 or 1 state")
            )
            assert_awready_never_unknown (
                .clock(aclk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(awready),
                .fire(assert_awready_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_awaddr_never_unknown_fire;

            ovl_never_unknown #(
                .width(ADDRESS_WIDTH),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("awaddr signal cannot be unknown during active transfer")
            )
            assert_awaddr_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(awvalid),
                .test_expr(awaddr),
                .fire(assert_awaddr_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_awprot_never_unknown_fire;

            ovl_never_unknown #(
                .width($bits(awprot_t)),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("awprot signal cannot be unknown during active transfer")
            )
            assert_awprot_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(awvalid),
                .test_expr(awprot),
                .fire(assert_awprot_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_arvalid_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("arvalid signal always must be in known 0 or 1 state")
            )
            assert_arvalid_never_unknown (
                .clock(aclk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(arvalid),
                .fire(assert_arvalid_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_arready_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("arready signal always must be in known 0 or 1 state")
            )
            assert_arready_never_unknown (
                .clock(aclk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(arready),
                .fire(assert_arready_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_araddr_never_unknown_fire;

            ovl_never_unknown #(
                .width(ADDRESS_WIDTH),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("araddr signal cannot be unknown during active transfer")
            )
            assert_araddr_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(arvalid),
                .test_expr(araddr),
                .fire(assert_araddr_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_arprot_never_unknown_fire;

            ovl_never_unknown #(
                .width($bits(arprot_t)),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("arprot signal cannot be unknown during active transfer")
            )
            assert_arprot_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(arvalid),
                .test_expr(arprot),
                .fire(assert_arprot_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_rvalid_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("rvalid signal always must be in known 0 or 1 state")
            )
            assert_rvalid_never_unknown (
                .clock(aclk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(rvalid),
                .fire(assert_rvalid_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_rready_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("rready signal always must be in known 0 or 1 state")
            )
            assert_rready_never_unknown (
                .clock(aclk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(rready),
                .fire(assert_rready_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_rdata_never_unknown_fire;

            ovl_never_unknown #(
                .width(8 * DATA_BYTES),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("rdata signal cannot be unknown during active transfer")
            )
            assert_rdata_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(rvalid),
                .test_expr(rdata),
                .fire(assert_rdata_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_rresp_never_unknown_fire;

            ovl_never_unknown #(
                .width($bits(rresp_t)),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("rresp signal cannot be unknown during active transfer")
            )
            assert_rresp_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(rvalid),
                .test_expr(rresp),
                .fire(assert_rresp_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_bvalid_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("bvalid signal always must be in known 0 or 1 state")
            )
            assert_bvalid_never_unknown (
                .clock(aclk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(bvalid),
                .fire(assert_bvalid_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_bready_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("bready signal always must be in known 0 or 1 state")
            )
            assert_bready_never_unknown (
                .clock(aclk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(bready),
                .fire(assert_bready_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_bresp_never_unknown_fire;

            ovl_never_unknown #(
                .width($bits(bresp_t)),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("bresp signal cannot be unknown during active transfer")
            )
            assert_bresp_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(bvalid),
                .test_expr(bresp),
                .fire(assert_bresp_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_wvalid_always_reset_fire;

            ovl_always #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("wvalid signal must be low during reset phase")
            )
            assert_wvalid_always_reset (
                .clock(aclk),
                .reset(!areset_n),
                .enable(1'b1),
                .test_expr(!wvalid),
                .fire(assert_wvalid_always_reset_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_awvalid_always_reset_fire;

            ovl_always #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("awvalid signal must be low during reset phase")
            )
            assert_awvalid_always_reset (
                .clock(aclk),
                .reset(!areset_n),
                .enable(1'b1),
                .test_expr(!awvalid),
                .fire(assert_awvalid_always_reset_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_arvalid_always_reset_fire;

            ovl_always #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("arvalid signal must be low during reset phase")
            )
            assert_arvalid_always_reset (
                .clock(aclk),
                .reset(!areset_n),
                .enable(1'b1),
                .test_expr(!arvalid),
                .fire(assert_arvalid_always_reset_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_rvalid_always_reset_fire;

            ovl_always #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("rvalid signal must be low during reset phase")
            )
            assert_rvalid_always_reset (
                .clock(aclk),
                .reset(!areset_n),
                .enable(1'b1),
                .test_expr(!rvalid),
                .fire(assert_rvalid_always_reset_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_bvalid_always_reset_fire;

            ovl_always #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("bvalid signal must be low during reset phase")
            )
            assert_bvalid_always_reset (
                .clock(aclk),
                .reset(!areset_n),
                .enable(1'b1),
                .test_expr(!bvalid),
                .fire(assert_bvalid_always_reset_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_wvalid_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("wvalid signal cannot change value during bus hold")
            )
            assert_wvalid_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!write_data_bus_hold && wvalid && !wready),
                .test_expr(wvalid),
                .end_event(write_data_bus_hold && wready),
                .fire(assert_wvalid_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_wdata_unchange_fire;

            ovl_win_unchange #(
                .width(8 * DATA_BYTES),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("wdata signal cannot change value during bus hold")
            )
            assert_wdata_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!write_data_bus_hold && wvalid && !wready),
                .test_expr(wdata),
                .end_event(write_data_bus_hold && wready),
                .fire(assert_wdata_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_wstrb_unchange_fire;

            ovl_win_unchange #(
                .width(DATA_BYTES),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("wstrb signal cannot change value during bus hold")
            )
            assert_wstrb_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!write_data_bus_hold && wvalid && !wready),
                .test_expr(wstrb),
                .end_event(write_data_bus_hold && wready),
                .fire(assert_wstrb_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_awvalid_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("awvalid signal cannot change value during bus hold")
            )
            assert_awvalid_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!write_address_bus_hold && awvalid && !awready),
                .test_expr(awvalid),
                .end_event(write_address_bus_hold && awready),
                .fire(assert_awvalid_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_awaddr_unchange_fire;

            ovl_win_unchange #(
                .width(ADDRESS_WIDTH),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("awaddr signal cannot change value during bus hold")
            )
            assert_awaddr_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!write_address_bus_hold && awvalid && !awready),
                .test_expr(awaddr),
                .end_event(write_address_bus_hold && awready),
                .fire(assert_awaddr_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_awprot_unchange_fire;

            ovl_win_unchange #(
                .width($bits(awprot_t)),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("awprot signal cannot change value during bus hold")
            )
            assert_awprot_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!write_address_bus_hold && awvalid && !awready),
                .test_expr(awprot),
                .end_event(write_address_bus_hold && awready),
                .fire(assert_awprot_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_arvalid_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("arvalid signal cannot change value during bus hold")
            )
            assert_arvalid_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!read_address_bus_hold && arvalid && !arready),
                .test_expr(arvalid),
                .end_event(read_address_bus_hold && arready),
                .fire(assert_arvalid_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_araddr_unchange_fire;

            ovl_win_unchange #(
                .width(ADDRESS_WIDTH),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("araddr signal cannot change value during bus hold")
            )
            assert_araddr_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!read_address_bus_hold && arvalid && !arready),
                .test_expr(araddr),
                .end_event(read_address_bus_hold && arready),
                .fire(assert_araddr_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_arprot_unchange_fire;

            ovl_win_unchange #(
                .width($bits(arprot_t)),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("arprot signal cannot change value during bus hold")
            )
            assert_arprot_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!read_address_bus_hold && arvalid && !arready),
                .test_expr(arprot),
                .end_event(read_address_bus_hold && arready),
                .fire(assert_arprot_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_rvalid_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("rvalid signal cannot change value during bus hold")
            )
            assert_rvalid_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!read_data_bus_hold && rvalid && !rready),
                .test_expr(rvalid),
                .end_event(read_data_bus_hold && rready),
                .fire(assert_rvalid_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_rdata_unchange_fire;

            ovl_win_unchange #(
                .width(8 * DATA_BYTES),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("rdata signal cannot change value during bus hold")
            )
            assert_rdata_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!read_data_bus_hold && rvalid && !rready),
                .test_expr(rdata),
                .end_event(read_data_bus_hold && rready),
                .fire(assert_rdata_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_rresp_unchange_fire;

            ovl_win_unchange #(
                .width($bits(rresp_t)),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("rresp signal cannot change value during bus hold")
            )
            assert_rresp_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!read_data_bus_hold && rvalid && !rready),
                .test_expr(rresp),
                .end_event(read_data_bus_hold && rready),
                .fire(assert_rresp_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_bvalid_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("bvalid signal cannot change value during bus hold")
            )
            assert_bvalid_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!write_response_bus_hold && bvalid && !bready),
                .test_expr(bvalid),
                .end_event(write_response_bus_hold && bready),
                .fire(assert_bvalid_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_bresp_unchange_fire;

            ovl_win_unchange #(
                .width($bits(bresp_t)),
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("bresp signal cannot change value during bus hold")
            )
            assert_bresp_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(!write_response_bus_hold && bvalid && !bready),
                .test_expr(bresp),
                .end_event(write_response_bus_hold && bready),
                .fire(assert_bresp_unchange_fire)
            );
        end
    endgenerate
`endif

`ifdef VERILATOR
    logic _unused_ports = &{1'b0, aclk, areset_n, 1'b0};
`endif

endinterface

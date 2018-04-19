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

/* Interface: logic_axi4_stream_if
 *
 * AXI4-Stream interface.
 *
 * Parameters:
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *  USE_TLAST   - Enable or disable tlast signal.
 *  USE_TKEEP   - Enable or disable tkeep signal.
 *  USE_TSTRB   - Enable or disable tstrb signal.
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
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1
) (
    input aclk,
    input areset_n
);
    localparam int TDATA_WIDTH = 8 * TDATA_BYTES;
    localparam int TSTRB_WIDTH = (USE_TSTRB > 0) ? TDATA_BYTES : 0;
    localparam int TKEEP_WIDTH = (USE_TKEEP > 0) ? TDATA_BYTES : 0;
    localparam int TLAST_WIDTH = (USE_TLAST > 0) ? 1 : 0;

    localparam int TOTAL_WIDTH = TUSER_WIDTH + TDEST_WIDTH + TID_WIDTH +
        TLAST_WIDTH + TKEEP_WIDTH + TSTRB_WIDTH + TDATA_WIDTH;

    localparam int M_TDATA_BITS = (TDATA_BYTES > 0) ? 8 : 1;

    localparam int M_TDATA_BYTES = (TDATA_BYTES > 0) ? TDATA_BYTES : 1;
    localparam int M_TDEST_WIDTH = (TDEST_WIDTH > 0) ? TDEST_WIDTH : 1;
    localparam int M_TUSER_WIDTH = (TUSER_WIDTH > 0) ? TUSER_WIDTH : 1;
    localparam int M_TID_WIDTH = (TID_WIDTH > 0) ? TID_WIDTH : 1;

    localparam int M_TDATA_WIDTH = M_TDATA_BYTES * M_TDATA_BITS;
    localparam int M_TSTRB_WIDTH = M_TDATA_BYTES;
    localparam int M_TKEEP_WIDTH = M_TDATA_BYTES;

    localparam int M_TDATA_OFFSET = 0;
    localparam int M_TSTRB_OFFSET = M_TDATA_OFFSET + TDATA_WIDTH;
    localparam int M_TKEEP_OFFSET = M_TSTRB_OFFSET + TSTRB_WIDTH;
    localparam int M_TLAST_OFFSET = M_TKEEP_OFFSET + TKEEP_WIDTH;
    localparam int M_TDEST_OFFSET = M_TLAST_OFFSET + TLAST_WIDTH;
    localparam int M_TUSER_OFFSET = M_TDEST_OFFSET + TDEST_WIDTH;
    localparam int M_TID_OFFSET = M_TUSER_OFFSET + TUSER_WIDTH;

    typedef logic [M_TDATA_BYTES-1:0][M_TDATA_BITS-1:0] tdata_t;
    typedef logic [M_TSTRB_WIDTH-1:0] tstrb_t;
    typedef logic [M_TKEEP_WIDTH-1:0] tkeep_t;
    typedef logic [M_TDEST_WIDTH-1:0] tdest_t;
    typedef logic [M_TUSER_WIDTH-1:0] tuser_t;
    typedef logic [M_TID_WIDTH-1:0] tid_t;
    typedef logic tlast_t;

`ifdef SYNTHESIS
    logic tready;
    logic tvalid;
    tlast_t tlast;
    tdata_t tdata;
    tstrb_t tstrb;
    tkeep_t tkeep;
    tdest_t tdest;
    tuser_t tuser;
    tid_t tid;
`else
    logic tready = 'X;
    logic tvalid = 'X;
    tlast_t tlast = 'X;
    tdata_t tdata = 'X;
    tstrb_t tstrb = 'X;
    tkeep_t tkeep = 'X;
    tdest_t tdest = 'X;
    tuser_t tuser = 'X;
    tid_t tid = 'X;
`endif

    function automatic logic [TOTAL_WIDTH-1:0] read();
        if (TDATA_WIDTH > 0) begin
            read[M_TDATA_OFFSET+:$bits(tdata_t)] = tdata;
        end

        if (TKEEP_WIDTH > 0) begin
            read[M_TKEEP_OFFSET+:$bits(tkeep_t)] = tkeep;
        end

        if (TSTRB_WIDTH > 0) begin
            read[M_TSTRB_OFFSET+:$bits(tstrb_t)] = tstrb;
        end

        if (TDEST_WIDTH > 0) begin
            read[M_TDEST_OFFSET+:$bits(tdest_t)] = tdest;
        end

        if (TUSER_WIDTH > 0) begin
            read[M_TUSER_OFFSET+:$bits(tuser_t)] = tuser;
        end

        if (TLAST_WIDTH > 0) begin
            read[M_TLAST_OFFSET+:$bits(tlast_t)] = tlast;
        end

        if (TID_WIDTH > 0) begin
            read[M_TID_OFFSET+:$bits(tid_t)] = tid;
        end
    endfunction

    task automatic write(input [TOTAL_WIDTH-1:0] packet);
        if (TDATA_WIDTH > 0) begin
            tdata <= packet[M_TDATA_OFFSET+:$bits(tdata_t)];
        end
        else begin
            tdata <= '0;
        end

        if (TKEEP_WIDTH > 0) begin
            tkeep <= packet[M_TKEEP_OFFSET+:$bits(tkeep_t)];
        end
        else begin
            tkeep <= '1;
        end

        if (TSTRB_WIDTH > 0) begin
            tstrb <= packet[M_TSTRB_OFFSET+:$bits(tstrb_t)];
        end
        else begin
            tstrb <= '1;
        end

        if (TDEST_WIDTH > 0) begin
            tdest <= packet[M_TDEST_OFFSET+:$bits(tdest_t)];
        end
        else begin
            tdest <= '0;
        end

        if (TUSER_WIDTH > 0) begin
            tuser <= packet[M_TUSER_OFFSET+:$bits(tuser_t)];
        end
        else begin
            tuser <= '0;
        end

        if (TLAST_WIDTH > 0) begin
            tlast <= packet[M_TLAST_OFFSET+:$bits(tlast_t)];
        end
        else begin
            tlast <= '1;
        end

        if (TID_WIDTH > 0) begin
            tid <= packet[M_TID_OFFSET+:$bits(tid_t)];
        end
        else begin
            tid <= '0;
        end
    endtask

    task automatic comb_write(input [TOTAL_WIDTH-1:0] packet);
        if (TDATA_WIDTH > 0) begin
            tdata = packet[M_TDATA_OFFSET+:$bits(tdata_t)];
        end
        else begin
            tdata = '0;
        end

        if (TKEEP_WIDTH > 0) begin
            tkeep = packet[M_TKEEP_OFFSET+:$bits(tkeep_t)];
        end
        else begin
            tkeep = '1;
        end

        if (TSTRB_WIDTH > 0) begin
            tstrb = packet[M_TSTRB_OFFSET+:$bits(tstrb_t)];
        end
        else begin
            tstrb = '1;
        end

        if (TDEST_WIDTH > 0) begin
            tdest = packet[M_TDEST_OFFSET+:$bits(tdest_t)];
        end
        else begin
            tdest = '0;
        end

        if (TUSER_WIDTH > 0) begin
            tuser = packet[M_TUSER_OFFSET+:$bits(tuser_t)];
        end
        else begin
            tuser = '0;
        end

        if (TLAST_WIDTH > 0) begin
            tlast = packet[M_TLAST_OFFSET+:$bits(tlast_t)];
        end
        else begin
            tlast = '1;
        end

        if (TID_WIDTH > 0) begin
            tid = packet[M_TID_OFFSET+:$bits(tid_t)];
        end
        else begin
            tid = '0;
        end
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

    modport monitor (
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

`ifndef SYNTHESIS
    clocking cb_rx @(posedge aclk);
        output tvalid;
        output tuser;
        output tdest;
        output tid;
        output tlast;
        output tkeep;
        output tstrb;
        output tdata;
        input tready;
    endclocking

    modport cb_rx_modport (
        input areset_n,
        clocking cb_rx
    );

    clocking cb_tx @(posedge aclk);
        input tvalid;
        input tuser;
        input tdest;
        input tid;
        input tlast;
        input tkeep;
        input tstrb;
        input tdata;
        inout tready;
    endclocking

    modport cb_tx_modport (
        input areset_n,
        clocking cb_tx
    );

    clocking cb_monitor @(posedge aclk);
        input tvalid;
        input tuser;
        input tdest;
        input tid;
        input tlast;
        input tkeep;
        input tstrb;
        input tdata;
        input tready;
    endclocking

    modport cb_monitor_modport (
        input areset_n,
        clocking cb_monitor
    );
`endif

`ifdef OVL_ASSERT_ON
    generate
        if (1) begin: assertions
            logic bus_hold;
            logic bus_hold_start;
            logic bus_hold_end;

            always_comb bus_hold_start = !bus_hold && tvalid && !tready;
            always_comb bus_hold_end = bus_hold && tready;

            always_ff @(posedge aclk or negedge areset_n) begin
                if (!areset_n) begin
                    bus_hold <= '0;
                end
                else if (bus_hold_start) begin
                    bus_hold <= '1;
                end
                else if (bus_hold_end) begin
                    bus_hold <= '0;
                end
            end

            /* verilator lint_off UNUSED */
            /* verilator coverage_off */
            genvar k;

            logic [`OVL_FIRE_WIDTH-1:0] assert_tvalid_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("tvalid signal always must be in known 0 or 1 state")
            )
            assert_tvalid_never_unknown (
                .clock(aclk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(tvalid),
                .fire(assert_tvalid_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tready_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("tready signal always must be in known 0 or 1 state")
            )
            assert_tready_never_unknown (
                .clock(aclk),
                .reset(1'b1),
                .enable(1'b1),
                .qualifier(1'b1),
                .test_expr(tready),
                .fire(assert_tready_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tdata_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .width(M_TDATA_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("tdata signal cannot be unknown during active transfer")
            )
            assert_tdata_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(tvalid),
                .test_expr(tdata),
                .fire(assert_tdata_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tkeep_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .width(M_TDATA_BYTES),
                .property_type(`OVL_ASSERT),
                .msg("tkeep signal cannot be unknown during active transfer")
            )
            assert_tkeep_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(tvalid),
                .test_expr(tkeep),
                .fire(assert_tkeep_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tstrb_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .width(M_TDATA_BYTES),
                .property_type(`OVL_ASSERT),
                .msg("tstrb signal cannot be unknown during active transfer")
            )
            assert_tstrb_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(tvalid),
                .test_expr(tstrb),
                .fire(assert_tstrb_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tlast_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("tlast signal cannot be unknown during active transfer")
            )
            assert_tlast_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(tvalid),
                .test_expr(tlast),
                .fire(assert_tlast_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tdest_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .width(M_TDEST_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("tdest signal cannot be unknown during active transfer")
            )
            assert_tdest_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(tvalid),
                .test_expr(tdest),
                .fire(assert_tdest_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tuser_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .width(M_TUSER_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("tuser signal cannot be unknown during active transfer")
            )
            assert_tuser_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(tvalid),
                .test_expr(tuser),
                .fire(assert_tuser_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tid_never_unknown_fire;

            ovl_never_unknown #(
                .severity_level(`OVL_FATAL),
                .width(M_TID_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("tid signal cannot be unknown during active transfer")
            )
            assert_tid_never_unknown (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .qualifier(tvalid),
                .test_expr(tid),
                .fire(assert_tid_never_unknown_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tvalid_always_reset_fire;

            ovl_always #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("tvalid signal must be low during reset phase")
            )
            assert_tvalid_always_reset (
                .clock(aclk),
                .reset(!areset_n),
                .enable(1'b1),
                .test_expr(!tvalid),
                .fire(assert_tvalid_always_reset_fire)
            );

            for (k = 0; k < M_TDATA_BYTES; ++k) begin: tdata_bytes
                logic [`OVL_FIRE_WIDTH-1:0]
                    assert_tkeep_tstrb_always_valid_fire;

                ovl_always #(
                    .severity_level(`OVL_FATAL),
                    .property_type(`OVL_ASSERT),
                    .msg("tstrb cannot be high when tkeep is low")
                )
                assert_tkeep_tstrb_always_valid (
                    .clock(aclk),
                    .reset(areset_n),
                    .enable(1'b1),
                    .test_expr(!tvalid || tkeep[k] ||
                        (!tkeep[k] && !tstrb[k])),
                    .fire(assert_tkeep_tstrb_always_valid_fire)
                );

                logic _unused_assert_fires = &{
                    1'b0,
                    assert_tkeep_tstrb_always_valid_fire,
                    1'b0
                };
            end

            logic [`OVL_FIRE_WIDTH-1:0] assert_tvalid_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("tvalid signal cannot change value during bus hold")
            )
            assert_tvalid_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(tvalid),
                .end_event(bus_hold_end),
                .fire(assert_tvalid_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tlast_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .property_type(`OVL_ASSERT),
                .msg("tlast signal cannot change value during bus hold")
            )
            assert_tlast_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(tlast),
                .end_event(bus_hold_end),
                .fire(assert_tlast_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tdata_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .width(M_TDATA_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("tdata signal cannot change value during bus hold")
            )
            assert_tdata_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(tdata),
                .end_event(bus_hold_end),
                .fire(assert_tdata_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tkeep_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .width(M_TDATA_BYTES),
                .property_type(`OVL_ASSERT),
                .msg("tkeep signal cannot change value during bus hold")
            )
            assert_tkeep_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(tkeep),
                .end_event(bus_hold_end),
                .fire(assert_tkeep_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tstrb_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .width(M_TDATA_BYTES),
                .property_type(`OVL_ASSERT),
                .msg("tstrb signal cannot change value during bus hold")
            )
            assert_tstrb_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(tstrb),
                .end_event(bus_hold_end),
                .fire(assert_tstrb_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tuser_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .width(M_TUSER_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("tuser signal cannot change value during bus hold")
            )
            assert_tuser_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(tuser),
                .end_event(bus_hold_end),
                .fire(assert_tuser_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tdest_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .width(M_TDEST_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("tdest signal cannot change value during bus hold")
            )
            assert_tdest_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(tdest),
                .end_event(bus_hold_end),
                .fire(assert_tdest_unchange_fire)
            );

            logic [`OVL_FIRE_WIDTH-1:0] assert_tid_unchange_fire;

            ovl_win_unchange #(
                .severity_level(`OVL_FATAL),
                .width(M_TID_WIDTH),
                .property_type(`OVL_ASSERT),
                .msg("tid signal cannot change value during bus hold")
            )
            assert_tid_unchange (
                .clock(aclk),
                .reset(areset_n),
                .enable(1'b1),
                .start_event(bus_hold_start),
                .test_expr(tid),
                .end_event(bus_hold_end),
                .fire(assert_tid_unchange_fire)
            );

            logic _unused_assert_fires = &{
                1'b0,
                assert_tvalid_always_reset_fire,
                assert_tvalid_unchange_fire,
                assert_tlast_unchange_fire,
                assert_tdata_unchange_fire,
                assert_tkeep_unchange_fire,
                assert_tstrb_unchange_fire,
                assert_tuser_unchange_fire,
                assert_tdest_unchange_fire,
                assert_tid_unchange_fire,
                1'b0
            };
            /* verilator coverage_on */
            /* verilator lint_on UNUSED */
        end
    endgenerate
`endif

`ifdef VERILATOR
    logic _unused_ports = &{1'b0, aclk, areset_n, 1'b0};
`endif
endinterface

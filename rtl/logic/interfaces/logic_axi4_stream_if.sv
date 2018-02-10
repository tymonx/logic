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
    localparam TDATA_WIDTH = TDATA_BYTES * 8;
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

`ifndef LOGIC_SYNTHESIS
    `define INIT = '0
`else
    `define INIT
`endif

    logic tready `INIT;
    logic tvalid `INIT;
    logic tlast `INIT;
    tdata_t tdata `INIT;
    tstrb_t tstrb `INIT;
    tkeep_t tkeep `INIT;
    tdest_t tdest `INIT;
    tuser_t tuser `INIT;
    tid_t tid `INIT;

    function automatic packet_t read();
        return '{tuser, tdest, tid, tlast, tkeep, tstrb, tdata};
    endfunction

    task automatic write(input packet_t packet);
        {tuser, tdest, tid, tlast, tkeep, tstrb, tdata} <= packet;
    endtask

    task automatic comb_write(input packet_t packet);
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

`ifndef LOGIC_SYNTHESIS
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

    task automatic cb_rx_clear();
        cb_rx.tid <= '0;
        cb_rx.tuser <= '0;
        cb_rx.tdest <= '0;
        cb_rx.tlast <= '0;
        cb_rx.tkeep <= '0;
        cb_rx.tstrb <= '0;
        cb_rx.tdata <= '0;
        cb_rx.tvalid <= '0;
    endtask

    task automatic cb_tx_clear();
        cb_tx.tready <= '0;
    endtask

    task automatic cb_write(const ref byte data[], input int id = 0,
            int dest = 0, int idle_max = 0, int idle_min = 0);
        int total_size = data.size();
        int index = 0;
        int idle = 0;

        if (0 == data.size()) begin
            return;
        end

        forever begin
            if (!areset_n) begin
                break;
            end
            else if (1'b1 === cb_rx.tready) begin
                if (index >= total_size) begin
                    break;
                end
                else if (0 == idle) begin
                    idle = $urandom_range(idle_max, idle_min);

                    for (int i = 0; i < TDATA_BYTES; ++i) begin
                        if (index < total_size) begin
                            cb_rx.tkeep[i] <= '1;
                            cb_rx.tstrb[i] <= '1;
                            cb_rx.tdata[i] <= data[index++];
                        end
                        else begin
                            cb_rx.tkeep[i] <= '0;
                            cb_rx.tstrb[i] <= '0;
                            cb_rx.tdata[i] <= '0;
                        end
                    end

                    cb_rx.tid <= tid_t'(id);
                    cb_rx.tdest <= tdest_t'(dest);
                    cb_rx.tlast <= (index >= total_size);
                    cb_rx.tvalid <= '1;
                end
                else begin
                    --idle;
                    cb_rx.tvalid <= '0;
                end
            end
            @(cb_rx);
        end

        cb_rx.tvalid <= '0;
    endtask

    task automatic cb_read(ref byte data[], input int id = 0, int dest = 0,
            int idle_max = 0, int idle_min = 0);
        int idle = 0;
        byte q[$];

        cb_tx.tready <= '1;

        forever begin
            if (!areset_n) begin
                break;
            end
            else if ((1'b1 === cb_tx.tready) && (1'b1 === cb_tx.tvalid) &&
                    (tid_t'(id) === cb_tx.tid) &&
                    (tdest_t'(dest) === cb_tx.tdest)) begin
                for (int i = 0; i < TDATA_BYTES; ++i) begin
                    if ((1'b1 === cb_tx.tkeep[i]) &&
                            (1'b1 === cb_tx.tstrb[i])) begin
                        q.push_back(byte'(cb_tx.tdata[i]));
                    end
                end

                if (1'b1 === cb_tx.tlast) begin
                    cb_tx.tready <= '1;
                    @(cb_tx);
                    break;
                end
            end

            if (0 == idle) begin
                idle = $urandom_range(idle_max, idle_min);
                cb_tx.tready <= '1;
            end
            else begin
                --idle;
                cb_tx.tready <= '0;
            end

            @(cb_tx);
        end

        cb_tx.tready <= '0;

        data = new [q.size()];
        foreach (q[i]) begin
            data[i] = q[i];
        end
    endtask
`endif

`ifndef LOGIC_STD_OVL_DISABLED
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
                .width(TDATA_WIDTH),
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
                .width(TDATA_BYTES),
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
                .width(TDATA_BYTES),
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
                .width(TDEST_WIDTH),
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
                .width(TUSER_WIDTH),
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
                .width(TID_WIDTH),
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

            for (k = 0; k < TDATA_BYTES; ++k) begin: tdata_bytes
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
                .width(TDATA_WIDTH),
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
                .width(TDATA_BYTES),
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
                .width(TDATA_BYTES),
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
                .width(TUSER_WIDTH),
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
                .width(TDEST_WIDTH),
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
                .width(TID_WIDTH),
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
        end
    endgenerate
`endif

`ifdef VERILATOR
    logic _unused_ports = &{1'b0, aclk, areset_n, 1'b0};
`endif
endinterface

/* Copyright 2017 Tymoteusz Blazejczyk
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

`include "svunit_defines.svh"

module logic_axi4_stream_timer_unit_test;
    import svunit_pkg::svunit_testcase;

    string name = "logic_axi4_stream_timer_unit_test";
    svunit_testcase svunit_ut;

    localparam TDATA_BYTES = 4;
    localparam PERIODIC_DEFAULT = 8;
    localparam COUNTER_MAX = 256;

    logic aclk = 0;
    logic areset_n = 0;

    initial forever #1 aclk = ~aclk;

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) rx (.*);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) tx (.*);

    logic_axi4_stream_timer #(
        .PERIODIC_DEFAULT(PERIODIC_DEFAULT),
        .COUNTER_MAX(COUNTER_MAX)
    )
    dut (
        .*
    );

    function void build();
        svunit_ut = new (name);
    endfunction

    task setup();
        svunit_ut.setup();

        areset_n = 0;
        @(posedge aclk);

        areset_n = 1;
        tx.cb_tx.tready <= 1;
        @(posedge aclk);
    endtask

    task teardown();
        svunit_ut.teardown();

        areset_n = 0;
        tx.cb_tx.tready <= 0;
    endtask

`SVUNIT_TESTS_BEGIN

`SVTEST(basic_default)
    @(tx.cb_tx);

    for (int i = 0; i < 16; ++i) begin
        for (int j = 0; j < PERIODIC_DEFAULT; ++j) begin
            if ((PERIODIC_DEFAULT - 1) == j) begin
                `FAIL_UNLESS(tx.cb_tx.tlast)
            end

            `FAIL_UNLESS_EQUAL(j, tx.cb_tx.tdata)
            @(tx.cb_tx);
        end
    end
`SVTEST_END

`SVTEST(basic_reload_short)
    const int periodic = PERIODIC_DEFAULT - 3;

    repeat (17) @(tx.cb_tx);

    rx.cb_rx.tvalid <= 1;
    rx.cb_rx.tdata <= periodic;
    @(rx.cb_rx);

    rx.cb_rx.tvalid <= 0;
    rx.cb_rx.tdata <= 0;
    @(rx.cb_rx);

    for (int i = 0; i < 16; ++i) begin
        for (int j = 0; j < periodic; ++j) begin
            if ((periodic - 1) == j) begin
                `FAIL_UNLESS(tx.cb_tx.tlast)
            end

            `FAIL_UNLESS_EQUAL(j, tx.cb_tx.tdata)
            @(tx.cb_tx);
        end
    end
`SVTEST_END

`SVTEST(basic_reload_long)
    const int periodic = PERIODIC_DEFAULT + 5;

    repeat (17) @(tx.cb_tx);

    rx.cb_rx.tvalid <= 1;
    rx.cb_rx.tdata <= periodic;
    @(rx.cb_rx);

    rx.cb_rx.tvalid <= 0;
    rx.cb_rx.tdata <= 0;
    @(rx.cb_rx);

    for (int i = 0; i < 16; ++i) begin
        for (int j = 0; j < periodic; ++j) begin
            if ((periodic - 1) == j) begin
                `FAIL_UNLESS(tx.cb_tx.tlast)
            end

            `FAIL_UNLESS_EQUAL(j, tx.cb_tx.tdata)
            @(tx.cb_tx);
        end
    end
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

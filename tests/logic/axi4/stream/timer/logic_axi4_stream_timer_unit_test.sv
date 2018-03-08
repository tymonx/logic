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

`include "svunit_defines.svh"

module logic_axi4_stream_timer_unit_test;
    import svunit_pkg::svunit_testcase;
    import logic_unit_test_pkg::logic_axi4_stream_driver_rx;
    import logic_unit_test_pkg::logic_axi4_stream_driver_tx;

    string name = "logic_axi4_stream_timer_unit_test";
    svunit_testcase svunit_ut;

    parameter TDATA_BYTES = 4;
    parameter PERIODIC_DEFAULT = 8;
    parameter COUNTER_MAX = 256;

    logic aclk = 0;
    logic areset_n = 0;

    initial forever #1 aclk = ~aclk;

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) rx (.*);

    logic_axi4_stream_driver_rx #(
        .TDATA_BYTES(TDATA_BYTES)
    ) rx_drv = new (rx);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) tx (.*);

    logic_axi4_stream_driver_tx #(
        .TDATA_BYTES(TDATA_BYTES)
    ) tx_drv = new (tx);

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

        rx_drv.reset();
        tx_drv.reset();

        areset_n = 0;
        fork
            rx_drv.aclk_posedge();
            tx_drv.aclk_posedge();
        join

        areset_n = 1;
        fork
            rx_drv.aclk_posedge();
            tx_drv.aclk_posedge();
        join
    endtask

    task teardown();
        svunit_ut.teardown();

        areset_n = 0;
    endtask

`SVUNIT_TESTS_BEGIN

`SVTEST(basic_default)
    for (int n = 0; n < 16; ++n) begin
        byte captured[];

        tx_drv.read(captured);

        `FAIL_UNLESS_EQUAL(captured.size(), TDATA_BYTES * PERIODIC_DEFAULT)

        for (int i = 0; i < PERIODIC_DEFAULT; ++i) begin
            `FAIL_UNLESS_EQUAL(captured[TDATA_BYTES * i], i)
        end
    end
`SVTEST_END

`SVTEST(short_reload)
    const int reload = 5;

    byte data[] = new [TDATA_BYTES];
    byte captured[];

    tx_drv.read(captured);
    tx_drv.ready();

    `FAIL_UNLESS_EQUAL(captured.size(), TDATA_BYTES * PERIODIC_DEFAULT)

    for (int i = 0; i < PERIODIC_DEFAULT; ++i) begin
        `FAIL_UNLESS_EQUAL(captured[TDATA_BYTES * i], i)
    end

    {<<8{data}} = reload;

    fork
    begin
        rx_drv.write(data);
        tx_drv.read(captured);
    end
    join

    `FAIL_UNLESS_EQUAL(captured.size(), TDATA_BYTES * reload)

    for (int i = 0; i < reload; ++i) begin
        `FAIL_UNLESS_EQUAL(captured[TDATA_BYTES * i], i)
    end
`SVTEST_END

`SVTEST(long_reload)
    const int reload = 17;

    byte data[] = new [TDATA_BYTES];
    byte captured[];

    tx_drv.read(captured);
    tx_drv.ready();

    `FAIL_UNLESS_EQUAL(captured.size(), TDATA_BYTES * PERIODIC_DEFAULT)

    for (int i = 0; i < PERIODIC_DEFAULT; ++i) begin
        `FAIL_UNLESS_EQUAL(captured[TDATA_BYTES * i], i)
    end

    {<<8{data}} = reload;

    fork
    begin
        rx_drv.write(data);
        tx_drv.read(captured);
    end
    join

    `FAIL_UNLESS_EQUAL(captured.size(), TDATA_BYTES * reload)

    for (int i = 0; i < reload; ++i) begin
        `FAIL_UNLESS_EQUAL(captured[TDATA_BYTES * i], i)
    end
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

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
`timescale 1ns / 1ps

`include "svunit_defines.svh"

module logic_pll_lock_service_unit_test;
    import svunit_pkg::svunit_testcase;

    string name = "logic_pll_lock_service_unit_test";
    svunit_testcase svunit_ut;

    parameter CLOCK_FREQUENCY_HZ = 100_000_000;
    parameter RESET_DURATION_NS = 100;
    parameter WAIT_FOR_LOCK_NS = 1_000;
    parameter PLL_LOCKED_STAGES = 4;

    parameter real TIME_BASE = 1_000_000_000;
    parameter real TIME_CLOCK = (TIME_BASE / real'(CLOCK_FREQUENCY_HZ)) / 2;

    logic aclk = 0;
    logic areset_n = 0;
    logic pll_locked = 0;
    logic pll_reset;
    logic locked;

    initial forever #(TIME_CLOCK) aclk = ~aclk;

    clocking cb @(posedge aclk);
        input locked;
        input pll_reset;
        output pll_locked;
    endclocking

    logic_pll_lock_service #(
        .CLOCK_FREQUENCY_HZ(CLOCK_FREQUENCY_HZ),
        .RESET_DURATION_NS(RESET_DURATION_NS),
        .WAIT_FOR_LOCK_NS(WAIT_FOR_LOCK_NS),
        .PLL_LOCKED_STAGES(PLL_LOCKED_STAGES)
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
        @(cb);

        areset_n = 1;
        cb.pll_locked <= 0;
        @(cb);
    endtask

    task teardown();
        svunit_ut.teardown();

        areset_n = 0;
        cb.pll_locked <= 0;
    endtask

`SVUNIT_TESTS_BEGIN

`SVTEST(basic)
    int timeout;

    timeout = 1000;
    while (timeout--) begin
        `FAIL_IF(cb.locked)
        if (!cb.pll_reset) begin
            break;
        end
        @(cb);
    end

    `FAIL_IF(cb.locked)
    `FAIL_UNLESS(timeout)

    repeat (16) @(cb);
    cb.pll_locked <= 1;

    timeout = 1000;
    while (timeout--) begin
        `FAIL_IF(cb.pll_reset)
        if (cb.locked) begin
            break;
        end
        @(cb);
    end

    `FAIL_IF(cb.pll_reset)
    `FAIL_UNLESS(timeout)
    `FAIL_UNLESS(cb.locked)
`SVTEST_END

`SVTEST(lost_lock)
    int timeout;

    repeat (64) @(cb);

    cb.pll_locked <= 1;
    repeat (16) @(cb);

    `FAIL_UNLESS(cb.locked)

    cb.pll_locked <= 0;

    timeout = 1000;
    while (timeout--) begin
        if (cb.pll_reset) begin
            break;
        end
        @(cb);
    end

    `FAIL_UNLESS(timeout)
    `FAIL_IF(cb.locked)

    timeout = 1000;
    while (timeout--) begin
        `FAIL_IF(cb.locked)
        if (!cb.pll_reset) begin
            break;
        end
        @(cb);
    end

    `FAIL_UNLESS(timeout)
    `FAIL_IF(cb.locked)
    repeat(32) @(cb);

    cb.pll_locked <= 1;

    timeout = 1000;
    while (timeout--) begin
        `FAIL_IF(cb.pll_reset)
        if (cb.locked) begin
            break;
        end
        @(cb);
    end

    `FAIL_UNLESS(timeout)
    `FAIL_UNLESS(cb.locked)
    `FAIL_IF(cb.pll_reset)
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

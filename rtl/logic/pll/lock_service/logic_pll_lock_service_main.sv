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

/* Module: logic_pll_lock_service_main
 *
 * It provides PLL control by using PLL input reset and PLL output locked
 * signals.
 *
 * Parameters:
 *  CLOCK_FREQUENCY_HZ  - Clock frequency in Hz.
 *  RESET_DURATION_NS   - PLL reset duration in nanoseconds.
 *  WAIT_FOR_LOCK_NS    - PLL wait for lock timeout in nanoseconds.
 *  PLL_LOCKED_STAGES   - Number of registers used for filtering PLL locked
 *                        signal.
 *
 * Ports:
 *  aclk            - Clock.
 *  areset_n        - Asynchronous active-low reset.
 *  pll_locked      - PLL locked signal from PLL.
 *  pll_reset       - PLL reset signal to PLL.
 *  locked          - Filtered and stable PLL locked output signal.
 */
module logic_pll_lock_service_main #(
    int CLOCK_FREQUENCY_HZ = 100_000_000,
    int RESET_DURATION_NS = 20,
    int WAIT_FOR_LOCK_NS = 1_000_000,
    int PLL_LOCKED_STAGES = 8
) (
    input aclk,
    input areset_n,
    input pll_locked,
    output logic pll_reset,
    output logic locked
);
    localparam real TIME_BASE = 1_000_000_000.0;
    localparam real TIME_UNIT = (TIME_BASE / real'(CLOCK_FREQUENCY_HZ));

    localparam int RESET_DURATION_CLOCKS = int'(
        (real'(RESET_DURATION_NS) / TIME_UNIT) + 0.5);

    localparam int WAIT_FOR_LOCK_CLOCKS = int'(
        (real'(WAIT_FOR_LOCK_NS) / TIME_UNIT) + 0.5);

    localparam int RESET_DURATION = (RESET_DURATION_CLOCKS >= 2) ?
        RESET_DURATION_CLOCKS : 2;

    localparam int WAIT_FOR_LOCK = (WAIT_FOR_LOCK_CLOCKS >= 2) ?
        WAIT_FOR_LOCK_CLOCKS : 2;

    localparam int COUNTER_MAX = (RESET_DURATION < WAIT_FOR_LOCK) ?
        WAIT_FOR_LOCK : RESET_DURATION;

    localparam int TDATA_BYTES = 4;

    initial begin: design_rule_checks
        `LOGIC_DRC_GREATER_THAN(CLOCK_FREQUENCY_HZ, 0)
        `LOGIC_DRC_EQUAL_OR_LESS_THAN(CLOCK_FREQUENCY_HZ, TIME_BASE)
    end

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    )
    timer_config (
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    )
    timer (
        .*
    );

    logic_axi4_stream_timer #(
        .TDATA_BYTES(TDATA_BYTES),
        .PERIODIC_DEFAULT(RESET_DURATION),
        .COUNTER_MAX(COUNTER_MAX)
    )
    timer_unit (
        .rx(timer_config),
        .tx(timer),
        .*
    );

    logic_pll_lock_service_unit #(
        .RESET_DURATION(RESET_DURATION),
        .WAIT_FOR_LOCK(WAIT_FOR_LOCK),
        .PLL_LOCKED_STAGES(PLL_LOCKED_STAGES)
    )
    unit (
        .*
    );
endmodule

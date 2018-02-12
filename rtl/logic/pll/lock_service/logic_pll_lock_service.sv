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

/* Module: logic_pll_lock_service
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
module logic_pll_lock_service #(
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
    logic areset_n_synced;

    logic_reset_synchronizer
    reset_synchronizer (
        .*
    );

    logic_pll_lock_service_main #(
        .CLOCK_FREQUENCY_HZ(CLOCK_FREQUENCY_HZ),
        .RESET_DURATION_NS(RESET_DURATION_NS),
        .WAIT_FOR_LOCK_NS(WAIT_FOR_LOCK_NS),
        .PLL_LOCKED_STAGES(PLL_LOCKED_STAGES)
    )
    main (
        .areset_n(areset_n_synced),
        .*
    );
endmodule

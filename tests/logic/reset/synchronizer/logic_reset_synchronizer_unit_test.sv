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

module logic_reset_synchronizer_unit_test;
    import svunit_pkg::svunit_testcase;

    string name = "logic_reset_synchronizer_unit_test";
    svunit_testcase svunit_ut;

    logic aclk = 0;
    logic areset_n = 0;
    logic areset_n_synced;

    initial forever #1 aclk = ~aclk;

    logic_reset_synchronizer dut (
        .*
    );

    function void build();
        svunit_ut = new (name);
    endfunction

    task setup();
        svunit_ut.setup();

        areset_n = 0;
        @(posedge aclk);
    endtask

    task teardown();
        svunit_ut.teardown();

        areset_n = 0;
    endtask

`SVUNIT_TESTS_BEGIN

`SVTEST(simple)
    areset_n = 0;
    repeat (3) @(posedge aclk);

    `FAIL_UNLESS_EQUAL(areset_n_synced, 0)

    areset_n = 1;
    repeat (3) @(posedge aclk);

    `FAIL_UNLESS_EQUAL(areset_n_synced, 1)
`SVTEST_END

`SVTEST(deassertion)
    areset_n = 1;
    repeat (3) @(posedge aclk);

    `FAIL_UNLESS_EQUAL(areset_n_synced, 1)

    areset_n = 0;
    #1;

    `FAIL_UNLESS_EQUAL(areset_n_synced, 0)
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

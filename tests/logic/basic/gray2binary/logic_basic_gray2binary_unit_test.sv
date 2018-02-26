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

`ifdef OVL_ASSERT_ON
`include "std_ovl_defines.h"
`endif

module logic_basic_gray2binary_unit_test;
    import svunit_pkg::svunit_testcase;

    string name = "logic_basic_gray2binary_unit_test";
    svunit_testcase svunit_ut;

    parameter WIDTH = 16;

    function automatic bit [WIDTH-1:0] gray2binary(bit [WIDTH-1:0] gray);
        gray2binary[WIDTH-1] = gray[WIDTH-1];

        for (int k = (WIDTH - 1); k > 0; --k) begin
            gray2binary[k - 1] = gray[k - 1] ^ gray2binary[k];
        end
    endfunction

    logic aclk = '0;
    logic areset_n = '0;

    logic [WIDTH-1:0] i = '0;
    logic [WIDTH-1:0] o;

    initial forever #1 aclk = ~aclk;

    clocking cb @(posedge aclk);
        output i;
        input o;
    endclocking

    logic_basic_gray2binary #(
        .WIDTH(WIDTH)
    )
    dut (
        .*
    );

    function void build();
        svunit_ut = new (name);
    endfunction

    task setup();
        svunit_ut.setup();

        cb.i <= '0;
        areset_n = '0;
        @(cb);
        areset_n = '1;
        @(cb);
    endtask

    task teardown();
        svunit_ut.teardown();

        areset_n = '0;
    endtask

`ifdef OVL_ASSERT_ON
    logic [`OVL_FIRE_WIDTH-1:0] assert_unknown_output_fire;

    ovl_never_unknown_async #(
        .severity_level(`OVL_FATAL),
        .width(WIDTH),
        .property_type(`OVL_ASSERT),
        .msg("output signal o cannot be unknown")
    )
    assert_unknown_input (
        .reset(areset_n),
        .enable(1'b1),
        .test_expr(i),
        .fire(assert_unknown_output_fire)
    );
`endif

`SVUNIT_TESTS_BEGIN

`SVTEST(basic)
    bit [WIDTH-1:0] gray[] = new [64];
    bit [WIDTH-1:0] binary[] = new [64];

    foreach (gray[i]) begin
        gray[i] = $urandom;
        binary[i] = gray2binary(gray[i]);

        cb.i <= gray[i];
        @(cb);
        `FAIL_UNLESS_EQUAL(binary[i], cb.o)
    end
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

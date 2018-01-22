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

`include "std_ovl_defines.h"
`include "svunit_defines.svh"

module logic_basic_binary2gray_unit_test;
    import svunit_pkg::svunit_testcase;

    string name = "logic_basic_binary2gray_unit_test";
    svunit_testcase svunit_ut;

    localparam WIDTH = 16;

    function automatic bit [WIDTH-1:0] binary2gray(bit [WIDTH-1:0] binary);
        binary2gray[WIDTH-1] = binary[WIDTH-1];

        for (int k = 0; k < (WIDTH - 1); ++k) begin
            binary2gray[k] = binary[k] ^ binary[k + 1];
        end
    endfunction

    logic aclk = '0;
    logic areset_n = '0;
    logic [`OVL_FIRE_WIDTH-1:0] assert_unknown_output_fire;

    logic [WIDTH-1:0] i = '0;
    logic [WIDTH-1:0] o;

    initial forever #1 aclk = ~aclk;

    clocking cb @(posedge aclk);
        output i;
        input o;
    endclocking

    logic_basic_binary2gray #(
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

`SVUNIT_TESTS_BEGIN

`SVTEST(basic)
    bit [WIDTH-1:0] binary[] = new [64];
    bit [WIDTH-1:0] gray[] = new [64];

    foreach (binary[i]) begin
        binary[i] = $urandom;
        gray[i] = binary2gray(binary[i]);

        cb.i <= binary[i];
        @(cb);
        `FAIL_UNLESS_EQUAL(gray[i], cb.o)
    end
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

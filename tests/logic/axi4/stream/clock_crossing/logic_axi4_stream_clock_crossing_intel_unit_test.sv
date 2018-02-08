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

module logic_axi4_stream_clock_crossing_intel_unit_test;
    import svunit_pkg::svunit_testcase;

    string name = "logic_axi4_stream_clock_crossing_intel_unit_test";
    svunit_testcase svunit_ut;

    localparam TDATA_BYTES = 4;

    logic rx_aclk = 0;
    logic tx_aclk = 0;
    logic areset_n = 0;

    initial forever #3 rx_aclk = ~rx_aclk;
    initial forever #27 tx_aclk = ~tx_aclk;

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) rx (
        .aclk(rx_aclk),
        .*
    );

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) tx (
        .aclk(tx_aclk),
        .*
    );

    logic_axi4_stream_clock_crossing #(
        .TDATA_BYTES(TDATA_BYTES),
        .TARGET(logic_pkg::TARGET_INTEL)
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
        @(rx.cb_rx);
        @(tx.cb_tx);

        areset_n = 1;
        @(rx.cb_rx);
        @(tx.cb_tx);
    endtask

    task teardown();
        svunit_ut.teardown();

        areset_n = 0;
    endtask

`SVUNIT_TESTS_BEGIN

`SVTEST(short)
    byte data[] = new [123];
    byte captured[];

    foreach (data[i]) begin
        data[i] = $urandom;
    end

    fork
    begin
        rx.cb_write(data);
    end
    begin
        tx.cb_read(captured);
    end
    join

    `FAIL_UNLESS_EQUAL(data.size(), captured.size())
    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i], captured[i])
    end
`SVTEST_END

`SVTEST(long)
    byte data[] = new [7654];
    byte captured[];

    foreach (data[i]) begin
        data[i] = $urandom;
    end

    fork
    begin
        rx.cb_write(data);
    end
    begin
        tx.cb_read(captured);
    end
    join

    `FAIL_UNLESS_EQUAL(data.size(), captured.size())
    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i], captured[i])
    end
`SVTEST_END

`SVTEST(multi)
    byte data[16][];
    byte captured[16][];

    foreach (data[i]) begin
        data[i] = new [$urandom_range(1, 256)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            rx.cb_write(data[i]);
        end
    end
    begin
        foreach (captured[i]) begin
            tx.cb_read(captured[i]);
        end
    end
    join

    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i].size(), captured[i].size())
        foreach (data[i, j]) begin
            `FAIL_UNLESS_EQUAL(data[i][j], captured[i][j])
        end
    end
`SVTEST_END

`SVTEST(slow_read)
    byte data[] = new [7654];
    byte captured[];

    foreach (data[i]) begin
        data[i] = $urandom;
    end

    fork
    begin
        rx.cb_write(data);
    end
    begin
        tx.cb_read(captured, 0, 0, 3, 0);
    end
    join

    `FAIL_UNLESS_EQUAL(data.size(), captured.size())
    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i], captured[i])
    end
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

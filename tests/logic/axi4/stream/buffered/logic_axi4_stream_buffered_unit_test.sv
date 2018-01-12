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

module logic_axi4_stream_buffered_unit_test;
    import svunit_pkg::svunit_testcase;

    string name = "logic_axi4_stream_buffered_unit_test";
    svunit_testcase svunit_ut;

    localparam TDATA_BYTES = 4;

    logic aclk = 0;
    logic areset_n = 0;

    initial forever #1 aclk = ~aclk;

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) rx (.*);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) tx (.*);

    logic_axi4_stream_buffered #(
        .TDATA_BYTES(TDATA_BYTES)
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
        tx.cb_read(captured);
    end
    begin
        for (int i = 0; i < (data.size() / TDATA_BYTES); ++i) begin
            tx.cb_tx.tready <= 0;
            repeat (2) @(tx.cb_tx);

            tx.cb_tx.tready <= 1;
            repeat (1) @(tx.cb_tx);
        end
    end
    join

    `FAIL_UNLESS_EQUAL(data.size(), captured.size())
    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i], captured[i])
    end
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

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

module logic_axi4_stream_demux_unit_test;
    import svunit_pkg::svunit_testcase;

    string name = "logic_axi4_stream_demux_unit_test";
    svunit_testcase svunit_ut;

    parameter OUTPUTS = 13;
    parameter TDATA_BYTES = 4;
    parameter TID_WIDTH = (OUTPUTS >= 2) ? $clog2(OUTPUTS) : 1;

    logic aclk = 0;
    logic areset_n = 0;

    initial forever #1 aclk = ~aclk;

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TID_WIDTH(TID_WIDTH)
    ) rx (.*);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TID_WIDTH(TID_WIDTH)
    ) tx [OUTPUTS-1:0] (.*);

    virtual logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TID_WIDTH(TID_WIDTH)
    ) tx_if [OUTPUTS-1:0];

    generate
        for (genvar k = 0; k < OUTPUTS; ++k) begin: map
            initial tx_if[k] = tx[k];
        end
    endgenerate

    logic_axi4_stream_demux #(
        .USE_TID(1),
        .OUTPUTS(OUTPUTS),
        .TDATA_BYTES(TDATA_BYTES),
        .TID_WIDTH(TID_WIDTH)
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

        areset_n = 1;
        @(rx.cb_rx);
    endtask

    task teardown();
        svunit_ut.teardown();

        areset_n = 0;
    endtask

`SVUNIT_TESTS_BEGIN

`SVTEST(basic)
    byte data[OUTPUTS][];
    byte captured[OUTPUTS][];

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            rx.cb_write(data[i], i);
        end
    end
    begin
        foreach (captured[i]) begin
            fork
                automatic int index = i;
                tx_if[index].cb_read(captured[index], index);
            join_none
        end
        wait fork;
    end
    join

    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i].size(), captured[i].size())
    end

    foreach (data[i, j]) begin
        `FAIL_UNLESS_EQUAL(data[i][j], captured[i][j])
    end
`SVTEST_END

`SVTEST(basic_short)
    byte data[OUTPUTS][];
    byte captured[OUTPUTS][];

    foreach (data[i]) begin
        data[i] = new [$urandom_range(4, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            rx.cb_write(data[i], i);
        end
    end
    begin
        foreach (captured[i]) begin
            fork
                automatic int index = i;
                tx_if[index].cb_read(captured[index], index);
            join_none
        end
        wait fork;
    end
    join

    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i].size(), captured[i].size())
    end

    foreach (data[i, j]) begin
        `FAIL_UNLESS_EQUAL(data[i][j], captured[i][j])
    end
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

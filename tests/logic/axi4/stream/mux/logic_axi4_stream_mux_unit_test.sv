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

module logic_axi4_stream_mux_unit_test;
    import svunit_pkg::svunit_testcase;

    string name = "logic_axi4_stream_mux_unit_test";
    svunit_testcase svunit_ut;

    localparam INPUTS = 13;
    localparam TDATA_BYTES = 4;
    localparam TID_WIDTH = (INPUTS >= 2) ? $clog2(INPUTS) : 1;

    logic aclk = 0;
    logic areset_n = 0;

    initial forever #1 aclk = ~aclk;

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TID_WIDTH(TID_WIDTH)
    ) rx [INPUTS-1:0] (.*);

    virtual logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TID_WIDTH(TID_WIDTH)
    ) rx_if [INPUTS-1:0];

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TID_WIDTH(TID_WIDTH)
    ) tx (.*);

    generate
        for (genvar k = 0; k < INPUTS; ++k) begin: map
            initial rx_if[k] = rx[k];
        end
    endgenerate

    logic_axi4_stream_mux #(
        .INPUTS(INPUTS),
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

`SVTEST(basic)
    byte data[INPUTS][];
    byte captured[INPUTS][];

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            fork
                automatic int index = i;
                rx_if[index].cb_write(data[index], index);
            join_none
        end
        wait fork;
    end
    begin
        foreach (captured[i]) begin
            fork
                automatic int index = i;
                tx.cb_read(captured[index], index);
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
    byte data[INPUTS][];
    byte captured[INPUTS][];

    foreach (data[i]) begin
        data[i] = new [$urandom_range(4, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            fork
                automatic int index = i;
                rx_if[index].cb_write(data[index], index);
            join_none
        end
        wait fork;
    end
    begin
        foreach (captured[i]) begin
            fork
                automatic int index = i;
                tx.cb_read(captured[index], index);
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

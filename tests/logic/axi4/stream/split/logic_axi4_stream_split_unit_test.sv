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

module logic_axi4_stream_split_unit_test;
    import svunit_pkg::svunit_testcase;

    string name = "logic_axi4_stream_split_unit_test";
    svunit_testcase svunit_ut;

    parameter int OUTPUTS = 5;
    parameter int TDATA_BYTES = 4;

    logic aclk = 0;
    logic areset_n = 0;

    initial forever #1 aclk = ~aclk;

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) rx (.*);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) tx[OUTPUTS] (.*);

    virtual logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) tx_if[OUTPUTS];

    generate
        for (genvar k = 0; k < OUTPUTS; ++k) begin: map
            initial tx_if[k] = tx[k];
        end
    endgenerate

    logic_axi4_stream_split #(
        .OUTPUTS(OUTPUTS),
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
    byte data[24][];
    byte captured[OUTPUTS][24][];

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
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
            fork
                automatic int index = i;
            begin
                for (int j = 0; j < $size(data); ++j) begin
                    tx_if[index].cb_read(captured[index][j]);
                end
            end
            join_none
        end
        wait fork;
    end
    join

    foreach (data[i]) begin
        foreach (captured[j]) begin
            `FAIL_UNLESS_EQUAL(data[i].size(), captured[j][i].size())
        end
    end

    foreach (data[i, j]) begin
        foreach (captured[n]) begin
            `FAIL_UNLESS_EQUAL(data[i][j], captured[n][i][j])
        end
    end
`SVTEST_END

`SVTEST(slow_write)
    byte data[24][];
    byte captured[OUTPUTS][24][];

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            rx.cb_write(data[i], 0, 0, 3, 0);
        end
    end
    begin
        foreach (captured[i]) begin
            fork
                automatic int index = i;
            begin
                for (int j = 0; j < $size(data); ++j) begin
                    tx_if[index].cb_read(captured[index][j]);
                end
            end
            join_none
        end
        wait fork;
    end
    join

    foreach (data[i]) begin
        foreach (captured[j]) begin
            `FAIL_UNLESS_EQUAL(data[i].size(), captured[j][i].size())
        end
    end

    foreach (data[i, j]) begin
        foreach (captured[n]) begin
            `FAIL_UNLESS_EQUAL(data[i][j], captured[n][i][j])
        end
    end
`SVTEST_END

`SVTEST(slow_read)
    byte data[4][];
    byte captured[OUTPUTS][4][];

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
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
            fork
                automatic int index = i;
            begin
                for (int j = 0; j < $size(data); ++j) begin
                    tx_if[index].cb_read(captured[index][j], 0, 0, 3, 0);
                end
            end
            join_none
        end
        wait fork;
    end
    join

    foreach (data[i]) begin
        foreach (captured[j]) begin
            `FAIL_UNLESS_EQUAL(data[i].size(), captured[j][i].size())
        end
    end

    foreach (data[i, j]) begin
        foreach (captured[n]) begin
            `FAIL_UNLESS_EQUAL(data[i][j], captured[n][i][j])
        end
    end
`SVTEST_END

`SVTEST(slow_write_read)
    byte data[4][];
    byte captured[OUTPUTS][4][];

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            rx.cb_write(data[i], 0, 0, 3, 0);
        end
    end
    begin
        foreach (captured[i]) begin
            fork
                automatic int index = i;
            begin
                for (int j = 0; j < $size(data); ++j) begin
                    tx_if[index].cb_read(captured[index][j], 0, 0, 3, 0);
                end
            end
            join_none
        end
        wait fork;
    end
    join

    foreach (data[i]) begin
        foreach (captured[j]) begin
            `FAIL_UNLESS_EQUAL(data[i].size(), captured[j][i].size())
        end
    end

    foreach (data[i, j]) begin
        foreach (captured[n]) begin
            `FAIL_UNLESS_EQUAL(data[i][j], captured[n][i][j])
        end
    end
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

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

module logic_axi4_stream_from_avalon_st_unit_test;
    import svunit_pkg::svunit_testcase;
    import logic_unit_test_pkg::logic_avalon_st_driver_rx;
    import logic_unit_test_pkg::logic_axi4_stream_driver_tx;

    string name = "logic_axi4_stream_from_avalon_st_unit_test";
    svunit_testcase svunit_ut;

    parameter TDATA_BYTES = 4;
    parameter FIRST_SYMBOL_IN_HIGH_ORDER_BITS = 0;

    logic aclk = 0;
    logic areset_n = 0;

    initial forever #1 aclk = ~aclk;

    logic_avalon_st_if #(
        .SYMBOLS_PER_BEAT(TDATA_BYTES)
    ) rx (
        .clk(aclk),
        .reset_n(areset_n),
        .*
    );

    logic_avalon_st_driver_rx #(
        .SYMBOLS_PER_BEAT(TDATA_BYTES)
    ) rx_drv = new (rx);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) tx (.*);

    logic_axi4_stream_driver_tx #(
        .TDATA_BYTES(TDATA_BYTES)
    ) tx_drv = new (tx);

    logic_axi4_stream_from_avalon_st #(
        .TDATA_BYTES(TDATA_BYTES),
        .FIRST_SYMBOL_IN_HIGH_ORDER_BITS(FIRST_SYMBOL_IN_HIGH_ORDER_BITS)
    )
    dut (
        .*
    );

    function void build();
        svunit_ut = new (name);
    endfunction

    task setup();
        svunit_ut.setup();

        rx_drv.reset();
        tx_drv.reset();

        areset_n = 0;
        fork
            rx_drv.clk_posedge();
            tx_drv.aclk_posedge();
        join

        areset_n = 1;
        fork
            rx_drv.clk_posedge();
            tx_drv.aclk_posedge();
        join
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
        rx_drv.write(data);
    end
    begin
        tx_drv.read(captured);
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
        rx_drv.write(data);
    end
    begin
        tx_drv.read(captured);
    end
    join

    `FAIL_UNLESS_EQUAL(data.size(), captured.size())
    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i], captured[i])
    end
`SVTEST_END

`SVTEST(slow_write)
    byte data[] = new [7654];
    byte captured[];

    foreach (data[i]) begin
        data[i] = $urandom;
    end

    fork
    begin
        rx_drv.set_idle(0, 3);
        rx_drv.write(data);
    end
    begin
        tx_drv.read(captured);
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
        rx_drv.write(data);
    end
    begin
        tx_drv.set_idle(0, 3);
        tx_drv.read(captured);
    end
    join

    `FAIL_UNLESS_EQUAL(data.size(), captured.size())
    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i], captured[i])
    end
`SVTEST_END

`SVTEST(mix_write_read)
    byte data[] = new [7654];
    byte captured[];

    foreach (data[i]) begin
        data[i] = $urandom;
    end

    fork
    begin
        rx_drv.set_idle(0, 3);
        rx_drv.write(data);
    end
    begin
        tx_drv.set_idle(0, 3);
        tx_drv.read(captured);
    end
    join

    `FAIL_UNLESS_EQUAL(data.size(), captured.size())
    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i], captured[i])
    end
`SVTEST_END

`SVTEST(mix_write_read_packets)
    byte data[16][];
    byte captured[16][];

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        rx_drv.set_idle(0, 3);

        foreach (data[i]) begin
            rx_drv.write(data[i]);
        end
    end
    begin
        tx_drv.set_idle(0, 3);

        foreach (captured[i]) begin
            tx_drv.read(captured[i]);

            `FAIL_UNLESS_EQUAL(data[i].size(), captured[i].size())
            for (int j = 0; j < data[i].size(); ++j) begin
                `FAIL_UNLESS_EQUAL(data[i][j], captured[i][j])
            end
        end
    end
    join
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

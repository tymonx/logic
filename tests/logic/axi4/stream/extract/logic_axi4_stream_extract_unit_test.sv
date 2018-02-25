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

module logic_axi4_stream_extract_unit_test;
    import svunit_pkg::svunit_testcase;
    import logic_unit_test_pkg::logic_axi4_stream_driver_rx;
    import logic_unit_test_pkg::logic_axi4_stream_driver_tx;

    string name = "logic_axi4_stream_extract_unit_test";
    svunit_testcase svunit_ut;

    parameter int PACKETS = 9;
    parameter int OUTPUTS = 2;
    parameter int TDATA_BYTES = 4;
    parameter int TID_WIDTH = (PACKETS >= 2) ? $clog2(PACKETS) : 1;

    logic aclk = 0;
    logic areset_n = 0;

    initial forever #1 aclk = ~aclk;

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TID_WIDTH(TID_WIDTH)
    ) rx (.*);

    logic_axi4_stream_driver_rx #(
        .TDATA_BYTES(TDATA_BYTES),
        .TID_WIDTH(TID_WIDTH)
    ) rx_drv = new (rx);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES),
        .TID_WIDTH(TID_WIDTH)
    ) tx[OUTPUTS] (.*);

    logic_axi4_stream_driver_tx #(
        .TDATA_BYTES(TDATA_BYTES),
        .TID_WIDTH(TID_WIDTH)
    ) tx_drv[OUTPUTS];

    generate
        for (genvar k = 0; k < OUTPUTS; ++k) begin: map
            initial tx_drv[k] = new (tx[k]);
        end
    endgenerate

    logic_axi4_stream_extract #(
        .USE_TID(1),
        .PACKETS(PACKETS),
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

        rx_drv.reset();
        foreach (tx_drv[k]) begin
            tx_drv[k].reset();
        end

        areset_n = 0;
        fork
            rx_drv.aclk_posedge();
            tx_drv[0].aclk_posedge();
            tx_drv[1].aclk_posedge();
        join

        areset_n = 1;
        fork
            rx_drv.aclk_posedge();
            tx_drv[0].aclk_posedge();
            tx_drv[1].aclk_posedge();
        join
    endtask

    task teardown();
        svunit_ut.teardown();

        areset_n = 0;
    endtask

`SVUNIT_TESTS_BEGIN

`SVTEST(basic)
    byte data[24][];
    byte captured[24][];
    int ids[24];

    foreach (ids[i]) begin
        ids[i] = $urandom_range((2**TID_WIDTH) - 1);
    end

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            rx_drv.set_id(ids[i]);
            rx_drv.write(data[i]);
        end
    end
    begin
        foreach (ids[i]) begin
            if (ids[i] >= PACKETS) begin
                tx_drv[0].set_id(ids[i]);
                tx_drv[0].read(captured[i]);
            end
        end
    end
    begin
        foreach (ids[i]) begin
            if (ids[i] < PACKETS) begin
                tx_drv[1].set_id(ids[i]);
                tx_drv[1].read(captured[i]);
            end
        end
    end
    join

    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i].size(), captured[i].size())
    end

    foreach (data[i, j]) begin
        `FAIL_UNLESS_EQUAL(data[i][j], captured[i][j])
    end
`SVTEST_END

`SVTEST(basic_slow_write)
    byte data[24][];
    byte captured[24][];
    int ids[24];

    foreach (ids[i]) begin
        ids[i] = $urandom_range((2**TID_WIDTH) - 1);
    end

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            rx_drv.set_idle(0, 3);
            rx_drv.set_id(ids[i]);
            rx_drv.write(data[i]);
        end
    end
    begin
        foreach (ids[i]) begin
            if (ids[i] >= PACKETS) begin
                tx_drv[0].set_id(ids[i]);
                tx_drv[0].read(captured[i]);
            end
        end
    end
    begin
        foreach (ids[i]) begin
            if (ids[i] < PACKETS) begin
                tx_drv[1].set_id(ids[i]);
                tx_drv[1].read(captured[i]);
            end
        end
    end
    join

    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i].size(), captured[i].size())
    end

    foreach (data[i, j]) begin
        `FAIL_UNLESS_EQUAL(data[i][j], captured[i][j])
    end
`SVTEST_END

`SVTEST(basic_slow_read_next)
    byte data[24][];
    byte captured[24][];
    int ids[24];

    foreach (ids[i]) begin
        ids[i] = $urandom_range((2**TID_WIDTH) - 1);
    end

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            rx_drv.set_id(ids[i]);
            rx_drv.write(data[i]);
        end
    end
    begin
        foreach (ids[i]) begin
            if (ids[i] >= PACKETS) begin
                tx_drv[0].set_idle(0, 3);
                tx_drv[0].set_id(ids[i]);
                tx_drv[0].read(captured[i]);
            end
        end
    end
    begin
        foreach (ids[i]) begin
            if (ids[i] < PACKETS) begin
                tx_drv[1].set_id(ids[i]);
                tx_drv[1].read(captured[i]);
            end
        end
    end
    join

    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i].size(), captured[i].size())
    end

    foreach (data[i, j]) begin
        `FAIL_UNLESS_EQUAL(data[i][j], captured[i][j])
    end
`SVTEST_END

`SVTEST(basic_slow_read_extract)
    byte data[24][];
    byte captured[24][];
    int ids[24];

    foreach (ids[i]) begin
        ids[i] = $urandom_range((2**TID_WIDTH) - 1);
    end

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            rx_drv.set_id(ids[i]);
            rx_drv.write(data[i]);
        end
    end
    begin
        foreach (ids[i]) begin
            if (ids[i] >= PACKETS) begin
                tx_drv[0].set_id(ids[i]);
                tx_drv[0].read(captured[i]);
            end
        end
    end
    begin
        foreach (ids[i]) begin
            if (ids[i] < PACKETS) begin
                tx_drv[1].set_idle(0, 3);
                tx_drv[1].set_id(ids[i]);
                tx_drv[1].read(captured[i]);
            end
        end
    end
    join

    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i].size(), captured[i].size())
    end

    foreach (data[i, j]) begin
        `FAIL_UNLESS_EQUAL(data[i][j], captured[i][j])
    end
`SVTEST_END

`SVTEST(basic_slow_read_both)
    byte data[24][];
    byte captured[24][];
    int ids[24];

    foreach (ids[i]) begin
        ids[i] = $urandom_range((2**TID_WIDTH) - 1);
    end

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            rx_drv.set_id(ids[i]);
            rx_drv.write(data[i]);
        end
    end
    begin
        foreach (ids[i]) begin
            if (ids[i] >= PACKETS) begin
                tx_drv[0].set_idle(0, 3);
                tx_drv[0].set_id(ids[i]);
                tx_drv[0].read(captured[i]);
            end
        end
    end
    begin
        foreach (ids[i]) begin
            if (ids[i] < PACKETS) begin
                tx_drv[1].set_idle(0, 3);
                tx_drv[1].set_id(ids[i]);
                tx_drv[1].read(captured[i]);
            end
        end
    end
    join

    foreach (data[i]) begin
        `FAIL_UNLESS_EQUAL(data[i].size(), captured[i].size())
    end

    foreach (data[i, j]) begin
        `FAIL_UNLESS_EQUAL(data[i][j], captured[i][j])
    end
`SVTEST_END

`SVTEST(basic_slow_write_read)
    byte data[24][];
    byte captured[24][];
    int ids[24];

    foreach (ids[i]) begin
        ids[i] = $urandom_range((2**TID_WIDTH) - 1);
    end

    foreach (data[i]) begin
        data[i] = new [$urandom_range(256, 1)];
    end

    foreach (data[i, j]) begin
        data[i][j] = $urandom;
    end

    fork
    begin
        foreach (data[i]) begin
            rx_drv.set_idle(0, 3);
            rx_drv.set_id(ids[i]);
            rx_drv.write(data[i]);
        end
    end
    begin
        foreach (ids[i]) begin
            if (ids[i] >= PACKETS) begin
                tx_drv[0].set_idle(0, 3);
                tx_drv[0].set_id(ids[i]);
                tx_drv[0].read(captured[i]);
            end
        end
    end
    begin
        foreach (ids[i]) begin
            if (ids[i] < PACKETS) begin
                tx_drv[1].set_idle(0, 3);
                tx_drv[1].set_id(ids[i]);
                tx_drv[1].read(captured[i]);
            end
        end
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

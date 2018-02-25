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

module logic_axi4_stream_transfer_counter_unit_test;
    import svunit_pkg::svunit_testcase;
    import logic_unit_test_pkg::logic_axi4_stream_driver_rx;
    import logic_unit_test_pkg::logic_axi4_stream_driver_tx;

    string name = "logic_axi4_stream_transfer_counter_unit_test";
    svunit_testcase svunit_ut;

    parameter int PACKETS = 0;
    parameter int TDATA_BYTES = 4;
    parameter int COUNTER_MAX = 256;

    typedef bit [TDATA_BYTES-1:0][7:0] tdata_t;

    typedef byte data_t[];

    function automatic data_t create_data(int length);
        data_t data = new [length];
        foreach (data[i]) begin
            data[i] = $urandom;
        end
        return data;
    endfunction

    logic aclk = 0;
    logic areset_n = 0;

    initial forever #1 aclk = ~aclk;

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) rx (.*);

    logic_axi4_stream_driver_rx #(
        .TDATA_BYTES(TDATA_BYTES)
    ) rx_drv = new (rx);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) tx (.*);

    logic_axi4_stream_driver_tx #(
        .TDATA_BYTES(TDATA_BYTES)
    ) tx_drv = new (tx);

    logic_axi4_stream_if #(
        .TDATA_BYTES(TDATA_BYTES)
    ) counter (.*);

    logic_axi4_stream_driver_tx #(
        .TDATA_BYTES(TDATA_BYTES)
    ) counter_drv = new (counter);

    logic_axi4_stream_transfer_counter #(
        .PACKETS(PACKETS),
        .COUNTER_MAX(COUNTER_MAX),
        .TDATA_BYTES(TDATA_BYTES)
    )
    dut (
        .monitor_rx(rx),
        .monitor_tx(tx),
        .tx(counter),
        .*
    );

    logic_axi4_stream_queue #(
        .CAPACITY(COUNTER_MAX),
        .TDATA_BYTES(TDATA_BYTES)
    )
    queue_unit (
        .*
    );

    function void build();
        svunit_ut = new (name);
    endfunction

    task setup();
        svunit_ut.setup();

        rx_drv.reset();
        tx_drv.reset();
        counter_drv.reset();

        areset_n = 0;
        fork
            rx_drv.aclk_posedge();
            tx_drv.aclk_posedge();
            counter_drv.aclk_posedge();
        join

        areset_n = 1;
        fork
            rx_drv.aclk_posedge();
            tx_drv.aclk_posedge();
            counter_drv.aclk_posedge();
        join

        counter_drv.ready();
    endtask

    task teardown();
        svunit_ut.teardown();

        areset_n = 0;
    endtask

`SVUNIT_TESTS_BEGIN

`SVTEST(short)
    byte data[] = new [COUNTER_MAX * TDATA_BYTES];
    byte captured[];
    byte value[];

    foreach (data[i]) begin
        data[i] = $urandom;
    end

    rx_drv.write(data);

    counter_drv.aclk_posedge();
    counter_drv.read(value);
    counter_drv.ready();

    `FAIL_UNLESS_EQUAL(tdata_t'({<<8{value}}), PACKETS ? 1 : COUNTER_MAX)

    tx_drv.read(captured);

    counter_drv.aclk_posedge();
    counter_drv.read(value);
    `FAIL_UNLESS_EQUAL(tdata_t'({<<8{value}}), 0)
`SVTEST_END

`SVTEST(slow_write)
    byte data[] = new [COUNTER_MAX * TDATA_BYTES];
    byte captured[];
    byte value[];

    foreach (data[i]) begin
        data[i] = $urandom;
    end

    rx_drv.set_idle(0, 3);
    rx_drv.write(data);

    counter_drv.aclk_posedge();
    counter_drv.read(value);
    counter_drv.ready();

    `FAIL_UNLESS_EQUAL(tdata_t'({<<8{value}}), PACKETS ? 1 : COUNTER_MAX)

    tx_drv.read(captured);

    counter_drv.aclk_posedge();
    counter_drv.read(value);
    `FAIL_UNLESS_EQUAL(tdata_t'({<<8{value}}), 0)
`SVTEST_END

`SVTEST(slow_read)
    byte data[] = new [COUNTER_MAX * TDATA_BYTES];
    byte captured[];
    byte value[];

    foreach (data[i]) begin
        data[i] = $urandom;
    end

    rx_drv.write(data);

    counter_drv.aclk_posedge();
    counter_drv.read(value);
    counter_drv.ready();

    `FAIL_UNLESS_EQUAL(tdata_t'({<<8{value}}), PACKETS ? 1 : COUNTER_MAX)

    tx_drv.set_idle(0, 3);
    tx_drv.read(captured);

    counter_drv.aclk_posedge();
    counter_drv.read(value);
    `FAIL_UNLESS_EQUAL(tdata_t'({<<8{value}}), 0)
`SVTEST_END

`SVTEST(slow_read_write)
    byte data[] = new [COUNTER_MAX * TDATA_BYTES];
    byte captured[];
    byte value[];

    foreach (data[i]) begin
        data[i] = $urandom;
    end

    rx_drv.set_idle(0, 3);
    rx_drv.write(data);

    counter_drv.aclk_posedge();
    counter_drv.read(value);
    counter_drv.ready();

    `FAIL_UNLESS_EQUAL(tdata_t'({<<8{value}}), PACKETS ? 1 : COUNTER_MAX)

    tx_drv.set_idle(0, 3);
    tx_drv.read(captured);

    counter_drv.aclk_posedge();
    counter_drv.read(value);
    `FAIL_UNLESS_EQUAL(tdata_t'({<<8{value}}), 0)
`SVTEST_END

`SVTEST(write_data)
    byte data[];
    byte captured[];
    byte value[];

    data = create_data(13 * TDATA_BYTES);
    rx_drv.write(data);

    counter_drv.aclk_posedge();
    counter_drv.read(value);
    counter_drv.ready();

    `FAIL_UNLESS_EQUAL(tdata_t'({<<8{value}}), PACKETS ? 1 : 13)

    data = create_data(7 * TDATA_BYTES);
    rx_drv.write(data);

    counter_drv.aclk_posedge();
    counter_drv.read(value);
    counter_drv.ready();

    `FAIL_UNLESS_EQUAL(tdata_t'({<<8{value}}), PACKETS ? 2 : 20)

    data = create_data(26 * TDATA_BYTES);
    rx_drv.write(data);

    counter_drv.aclk_posedge();
    counter_drv.read(value);
    counter_drv.ready();

    `FAIL_UNLESS_EQUAL(tdata_t'({<<8{value}}), PACKETS ? 3 : 46)
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

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

module logic_axi4_lite_clock_crossing_unit_test;
    import svunit_pkg::svunit_testcase;
    import logic_unit_test_pkg::logic_axi4_lite_driver_slave;
    import logic_unit_test_pkg::logic_axi4_lite_driver_master;
    import logic_axi4_lite_pkg::access_t;
    import logic_axi4_lite_pkg::response_t;

    string name = "logic_axi4_lite_clock_crossing_unit_test";
    svunit_testcase svunit_ut;

    parameter TARGET = logic_pkg::TARGET_GENERIC;
    parameter ADDRESS_WIDTH = 10;

    typedef struct {
        bit [ADDRESS_WIDTH-1:0] address;
        bit [3:0][7:0] data;
        bit [3:0] byte_enable;
        access_t access;
        response_t response;
    } request_t;

    function access_t random_access();
        return access_t'($urandom % $bits(access_t));
    endfunction

    function response_t random_response();
        return response_t'($urandom % $bits(response_t));
    endfunction

    logic slave_aclk = 0;
    logic master_aclk = 0;
    logic areset_n = 0;

    initial forever #1 slave_aclk = ~slave_aclk;
    initial forever #3 master_aclk = ~master_aclk;

    logic_axi4_lite_if #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) slave (
        .aclk(slave_aclk),
        .*
    );

    logic_axi4_lite_driver_slave #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) slave_drv = new (slave);

    logic_axi4_lite_if #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) master (
        .aclk(master_aclk),
        .*
    );

    logic_axi4_lite_driver_master #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) master_drv = new (master);

    logic_axi4_lite_clock_crossing #(
        .TARGET(TARGET),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    dut (
        .*
    );

    function void build();
        svunit_ut = new (name);
    endfunction

    task setup();
        svunit_ut.setup();

        slave_drv.reset();
        master_drv.reset();

        areset_n = 0;
        fork
            slave_drv.aclk_posedge();
            master_drv.aclk_posedge();
        join

        areset_n = 1;
        fork
            slave_drv.aclk_posedge();
            master_drv.aclk_posedge();
        join
    endtask

    task teardown();
        svunit_ut.teardown();

        areset_n = 0;
    endtask

`SVUNIT_TESTS_BEGIN

`SVTEST(simple_write)
    request_t requests[] = new [16];

    foreach (requests[i]) begin
        requests[i].data = $urandom;
        requests[i].address = $urandom;
        requests[i].byte_enable = $urandom;
        requests[i].access = random_access();
        requests[i].response = random_response();
    end

    fork
    begin
        foreach (requests[i]) begin
            slave_drv.write_request(requests[i].address, requests[i].data,
                requests[i].byte_enable, requests[i].access);
        end
    end
    begin
        logic_axi4_lite_pkg::response_t response;

        foreach (requests[i]) begin
            slave_drv.write_response(response);
            `FAIL_UNLESS_EQUAL(response, requests[i].response);
        end
    end
    begin
        request_t captured;

        foreach (requests[i]) begin
            master_drv.write_request(captured.address, captured.data,
                captured.byte_enable, captured.access);

            `FAIL_UNLESS_EQUAL(captured.byte_enable, requests[i].byte_enable)
            `FAIL_UNLESS_EQUAL(captured.access, requests[i].access);
            `FAIL_UNLESS_EQUAL(captured.address, requests[i].address)
            `FAIL_UNLESS_EQUAL(captured.data, requests[i].data)

            master_drv.write_response(requests[i].response);
        end
    end
    join
`SVTEST_END

`SVTEST(simple_read)
    request_t requests[] = new [16];

    foreach (requests[i]) begin
        requests[i].data = $urandom;
        requests[i].address = $urandom;
        requests[i].access = random_access();
        requests[i].response = random_response();
    end

    fork
    begin
        foreach (requests[i]) begin
            slave_drv.read_request(requests[i].address, requests[i].access);
        end
    end
    begin
        request_t captured;

        foreach (requests[i]) begin
            slave_drv.read_response(captured.data, captured.response);
            `FAIL_UNLESS_EQUAL(captured.response, requests[i].response);
            `FAIL_UNLESS_EQUAL(captured.data, requests[i].data)
        end
    end
    begin
        request_t captured;

        foreach (requests[i]) begin
            master_drv.read_request(captured.address, captured.access);

            `FAIL_UNLESS_EQUAL(captured.access, requests[i].access);
            `FAIL_UNLESS_EQUAL(captured.address, requests[i].address)

            master_drv.read_response(requests[i].data, requests[i].response);
        end
    end
    join
`SVTEST_END

`SVUNIT_TESTS_END

endmodule

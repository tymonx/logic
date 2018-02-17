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

#include "logic_axi4_stream_queue_top.h"

#include <logic/trace.hpp>
#include <logic/command_line.hpp>
#include <logic/axi4/stream/bus_if.hpp>
#include <logic/axi4/stream/reset_if.hpp>

#include <uvm>
#include <systemc>

#ifndef TDATA_BYTES
#define TDATA_BYTES 4
#endif

#ifndef TUSER_WIDTH
#define TUSER_WIDTH 1
#endif

#ifndef TDEST_WIDTH
#define TDEST_WIDTH 1
#endif

#ifndef TID_WIDTH
#define TID_WIDTH 1
#endif

int sc_main(int argc, char* argv[]) {
    logic::command_line{argc, argv};

    bool test_passed{false};

    sc_core::sc_clock aclk{"aclk"};
    sc_core::sc_signal<bool> areset_n{"areset_n"};

    logic::axi4::stream::bus_if<
            TDATA_BYTES,
            TID_WIDTH,
            TDEST_WIDTH,
            TUSER_WIDTH
        > rx{"rx"};

    logic::axi4::stream::bus_if<
            TDATA_BYTES,
            TID_WIDTH,
            TDEST_WIDTH,
            TUSER_WIDTH
        > tx{"tx"};

    logic::axi4::stream::reset_if reset{};

    logic_axi4_stream_queue_top dut{"logic_axi4_stream_queue_top"};

    std::string trace_filename{dut.name()};

    uvm::uvm_config_db<std::string>::get(nullptr, "*", "trace_filename",
            trace_filename);

    logic::trace<decltype(dut)> trace{dut, trace_filename};

    uvm::uvm_config_db<logic::axi4::stream::bus_if_base*>::set(
            nullptr, "*.rx_agent.*", "vif", &rx);

    uvm::uvm_config_db<logic::axi4::stream::bus_if_base*>::set(
            nullptr, "*.tx_agent.*", "vif", &tx);

    uvm::uvm_config_db<logic::axi4::stream::reset_if*>::set(
            nullptr, "*.reset_agent.*", "vif", &reset);

    reset.aclk(aclk);
    reset.areset_n(areset_n);

    rx.aclk(aclk);
    rx.areset_n(areset_n);

    tx.aclk(aclk);
    tx.areset_n(areset_n);

    dut.aclk(aclk);
    dut.areset_n(areset_n);
    dut.rx_tready(rx.tready);
    dut.rx_tvalid(rx.tvalid);
    dut.rx_tlast(rx.tlast);
    dut.rx_tkeep(rx.tkeep);
    dut.rx_tstrb(rx.tstrb);
    dut.rx_tuser(rx.tuser);
    dut.rx_tdata(rx.tdata);
    dut.rx_tdest(rx.tdest);
    dut.rx_tid(rx.tid);

    dut.tx_tready(tx.tready);
    dut.tx_tvalid(tx.tvalid);
    dut.tx_tlast(tx.tlast);
    dut.tx_tkeep(tx.tkeep);
    dut.tx_tstrb(tx.tstrb);
    dut.tx_tuser(tx.tuser);
    dut.tx_tdata(tx.tdata);
    dut.tx_tdest(tx.tdest);
    dut.tx_tid(tx.tid);

    uvm::run_test();

    uvm::uvm_config_db<bool>::get(nullptr, "*", "test_passed", test_passed);

    return test_passed ? EXIT_SUCCESS : EXIT_FAILURE;
}

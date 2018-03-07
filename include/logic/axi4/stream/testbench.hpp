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

#ifndef LOGIC_AXI4_STREAM_TESTBENCH_HPP
#define LOGIC_AXI4_STREAM_TESTBENCH_HPP

#include <uvm>

namespace logic {
namespace axi4 {
namespace stream {

class rx_agent;
class tx_agent;
class sequencer;
class scoreboard;
class reset_agent;

class testbench : public uvm::uvm_env {
public:
    UVM_COMPONENT_UTILS(logic::axi4::stream::testbench)

    logic::axi4::stream::sequencer* sequencer;

    testbench();

    explicit testbench(const uvm::uvm_component_name& component_name);

    bool passed() const noexcept;

    bool failed() const noexcept;

    testbench(testbench&&) = delete;

    testbench(const testbench&) = delete;

    testbench& operator=(testbench&&) = delete;

    testbench& operator=(const testbench&) = delete;

    ~testbench() override;
protected:
    void build_phase(uvm::uvm_phase& phase) override;

    void connect_phase(uvm::uvm_phase& phase) override;

    rx_agent* m_rx_agent;
    tx_agent* m_tx_agent;
    scoreboard* m_scoreboard;
    reset_agent* m_reset_agent;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_TESTBENCH_HPP */

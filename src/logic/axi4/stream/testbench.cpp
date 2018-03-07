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

#include "logic/axi4/stream/reset_agent.hpp"
#include "logic/axi4/stream/rx_agent.hpp"
#include "logic/axi4/stream/scoreboard.hpp"
#include "logic/axi4/stream/sequencer.hpp"
#include "logic/axi4/stream/testbench.hpp"
#include "logic/axi4/stream/tx_agent.hpp"

#include <uvm>

using logic::axi4::stream::testbench;

testbench::testbench() :
    testbench{"testbench"}
{ }

testbench::testbench(const uvm::uvm_component_name& component_name) :
    uvm::uvm_env{component_name},
    sequencer{nullptr},
    m_rx_agent{nullptr},
    m_tx_agent{nullptr},
    m_scoreboard{nullptr},
    m_reset_agent{nullptr}
{
    UVM_INFO(get_name(), "Constructor", uvm::UVM_FULL);
}

testbench::~testbench() = default;

void testbench::build_phase(uvm::uvm_phase& phase) {
    uvm::uvm_env::build_phase(phase);

    UVM_INFO(get_name(), "Build phase", uvm::UVM_FULL);

    m_rx_agent = rx_agent::type_id::create("rx_agent", this);
    if (m_rx_agent == nullptr) {
        UVM_FATAL(get_name(), "Cannot create Rx agent!"
                " Simulation aborted!");
    }

    m_tx_agent = tx_agent::type_id::create("tx_agent", this);
    if (m_tx_agent == nullptr) {
        UVM_FATAL(get_name(), "Cannot create Tx agent!"
                " Simulation aborted!");
    }

    m_reset_agent = reset_agent::type_id::create("reset_agent", this);
    if (m_reset_agent == nullptr) {
        UVM_FATAL(get_name(), "Cannot create reset agent!"
                " Simulation aborted!");
    }

    m_scoreboard = scoreboard::type_id::create("scoreboard", this);
    if (m_scoreboard == nullptr) {
        UVM_FATAL(get_name(), "Cannot create scoreboard!"
                " Simulation aborted!");
    }

    sequencer = sequencer::type_id::create("sequencer", this);
    if (sequencer == nullptr) {
        UVM_FATAL(get_name(), "Cannot create sequencer!"
                " Simulation aborted!");
    }

    uvm::uvm_config_db<int>::set(this, "rx_agent", "is_active",
            uvm::UVM_ACTIVE);

    uvm::uvm_config_db<int>::set(this, "tx_agent", "is_active",
            uvm::UVM_ACTIVE);

    uvm::uvm_config_db<int>::set(this, "reset_agent", "is_active",
            uvm::UVM_ACTIVE);
}

void testbench::connect_phase(uvm::uvm_phase& phase) {
    uvm::uvm_env::connect_phase(phase);

    UVM_INFO(get_name(), "Connect phase", uvm::UVM_FULL);

    sequencer->rx_sequencer = m_rx_agent->sequencer;
    sequencer->tx_sequencer = m_tx_agent->sequencer;
    sequencer->reset_sequencer = m_reset_agent->sequencer;

    m_rx_agent->analysis_port.connect(m_scoreboard->rx_analysis_export);
    m_tx_agent->analysis_port.connect(m_scoreboard->tx_analysis_export);
}

bool testbench::passed() const noexcept {
    return m_scoreboard->passed();
}

bool testbench::failed() const noexcept {
    return m_scoreboard->failed();
}

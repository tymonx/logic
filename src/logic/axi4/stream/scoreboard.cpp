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

#include "logic/axi4/stream/scoreboard.hpp"
#include "logic/printer/json.hpp"

using logic::axi4::stream::scoreboard;

scoreboard::scoreboard() :
    scoreboard{"scoreboard"}
{ }

scoreboard::scoreboard(const uvm::uvm_component_name& component_name) :
    uvm::uvm_scoreboard{component_name},
    rx_analysis_export{"rx_analysis_export"},
    tx_analysis_export{"tx_analysis_export"},
    m_error{false},
    m_rx_fifo{"rx_fifo"},
    m_tx_fifo{"tx_fifo"},
    m_rx_packet{packet::type_id::create("rx", this)},
    m_tx_packet{packet::type_id::create("tx", this)}
{
    if (m_rx_packet == nullptr) {
        UVM_FATAL(get_name(), "Cannot create rx packet!");
    }

    if (m_tx_packet == nullptr) {
        UVM_FATAL(get_name(), "Cannot create tx packet!");
    }
}

bool scoreboard::passed() const noexcept {
    return !m_error;
}

bool scoreboard::failed() const noexcept {
    return m_error;
}

scoreboard::~scoreboard() = default;

void scoreboard::connect_phase(uvm::uvm_phase& phase) {
    uvm::uvm_scoreboard::connect_phase(phase);

    rx_analysis_export.connect(m_rx_fifo);
    tx_analysis_export.connect(m_tx_fifo);
}

void scoreboard::run_phase(uvm::uvm_phase& /* phase */) {
    UVM_INFO(get_name(), "Run phase", uvm::UVM_FULL);

    while (true) {
        *m_rx_packet = m_rx_fifo.get(nullptr);
        *m_tx_packet = m_tx_fifo.get(nullptr);

        if (!m_rx_packet->compare(*m_tx_packet)) {
            m_error = true;

            m_rx_packet->set_name("rx");
            m_tx_packet->set_name("tx");

            logic::printer::json json_printer;
            m_rx_packet->print(&json_printer);
            m_tx_packet->print(&json_printer);
        }
    }
}

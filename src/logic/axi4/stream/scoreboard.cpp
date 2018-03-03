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

#include <iomanip>
#include <sstream>
#include <algorithm>

using logic::axi4::stream::scoreboard;

static void print(std::stringstream& ss,
        const logic::axi4::stream::packet& packet, std::size_t index) {
    ss << packet.tdata[index].second << ", 0x";

    std::ios state{nullptr};
    state.copyfmt(ss);

    ss << std::hex << std::setw(2) << std::setfill('0') <<
        unsigned(packet.tdata[index].first);

    ss.copyfmt(state);
}

static void print(std::stringstream& ss, const char* prefix,
        const logic::axi4::stream::packet& packet) {

    ss << "  " << prefix << ".timestamp.start: " <<
        packet.tdata.front().second << std::endl;

    ss << "  " << prefix << ".timestamp.end: " <<
        packet.tdata.back().second << std::endl;

    ss << "  " << prefix << ".transfers: " <<
        packet.transfers << std::endl;

    ss << "  " << prefix << ".bus.width: " <<
        8 * packet.bus_size << std::endl;

    ss << "  " << prefix << ".tid: " <<
        std::uintmax_t(packet.tid) << std::endl;

    ss << "  " << prefix << ".tid.width: " <<
        packet.tid.size() << std::endl;

    ss << "  " << prefix << ".tdest: " <<
        std::uintmax_t(packet.tdest) << std::endl;

    ss << "  " << prefix << ".tdest.width: " <<
        packet.tdest.size() << std::endl;

    ss << "  " << prefix << ".tuser.width: " <<
        packet.tuser.front().size() << std::endl;

    ss << "  " << prefix << ".tdata.length: " <<
        packet.tdata.size() << std::endl;
}

scoreboard::scoreboard() :
    scoreboard{"scoreboard"}
{ }

scoreboard::scoreboard(const uvm::uvm_component_name& name) :
    uvm::uvm_scoreboard{name},
    rx_analysis_export{"rx_analysis_export"},
    tx_analysis_export{"tx_analysis_export"},
    m_error{false},
    m_rx_fifo{"rx_fifo"},
    m_tx_fifo{"tx_fifo"},
    m_rx_packet{packet::type_id::create("rx_packet", this)},
    m_tx_packet{packet::type_id::create("tx_packet", this)}
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

            std::stringstream ss;

            ss << "Packets mismatch:" << std::endl;

            ::print(ss, "rx", *m_rx_packet);
            ss << std::endl;

            ::print(ss, "tx", *m_tx_packet);
            ss << std::endl;

            const auto packet_length = std::min(m_rx_packet->tdata.size(),
                    m_tx_packet->tdata.size());

            for (auto i = 0u; i < packet_length; ++i) {
                if (m_rx_packet->tdata[i].first != m_tx_packet->tdata[i].first) {
                    ss << "  index: " << i << ", rx: {";
                    ::print(ss, *m_rx_packet, i);
                    ss << "}, tx: {";
                    ::print(ss, *m_tx_packet, i);
                    ss << "}" << std::endl;
                }
            }

            UVM_ERROR(get_name(), ss.str());
        }
    }
}

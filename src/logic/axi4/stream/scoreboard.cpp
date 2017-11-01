/* Copyright 2017 Tymoteusz Blazejczyk
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
    ss << packet.tdata_timestamp[index] << ", 0x";

    std::ios state{nullptr};
    state.copyfmt(ss);

    ss << std::hex << std::setw(2) << std::setfill('0') <<
        unsigned(packet.tdata[index]);

    ss.copyfmt(state);
}

static void print(std::stringstream& ss, const char* prefix,
        const logic::axi4::stream::packet& packet) {

    ss << "  " << prefix << ".timestamp.start: " <<
        packet.transfer_timestamp.front() << std::endl;

    ss << "  " << prefix << ".timestamp.end: " <<
        packet.transfer_timestamp.back() << std::endl;

    ss << "  " << prefix << ".transfers: " <<
        packet.transfer_timestamp.size() << std::endl;

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
    m_tx_fifo{"tx_fifo"}
{ }

bool scoreboard::passed() const noexcept {
    return !m_error;
}

bool scoreboard::failed() const noexcept {
    return m_error;
}

scoreboard::~scoreboard() { }

void scoreboard::connect_phase(uvm::uvm_phase& phase) {
    uvm::uvm_scoreboard::connect_phase(phase);

    rx_analysis_export.connect(m_rx_fifo);
    tx_analysis_export.connect(m_tx_fifo);
}

void scoreboard::run_phase(uvm::uvm_phase& /* phase */) {
    UVM_INFO(get_name(), "Run phase", uvm::UVM_FULL);

    while (true) {
        auto rx_packet = m_rx_fifo.get(nullptr);
        auto tx_packet = m_tx_fifo.get(nullptr);

        if (!rx_packet.compare(tx_packet)) {
            m_error = true;

            std::stringstream ss;

            ss << "Packets mismatch:" << std::endl;

            ::print(ss, "rx", rx_packet);
            ss << std::endl;

            ::print(ss, "tx", tx_packet);
            ss << std::endl;

            const auto packet_length = std::min(rx_packet.tdata.size(),
                    tx_packet.tdata.size());

            for (auto i = 0u; i < packet_length; ++i) {
                if (rx_packet.tdata[i] != tx_packet.tdata[i]) {
                    ss << "  index: " << i << ", rx: {";
                    ::print(ss, rx_packet, i);
                    ss << "}, tx: {";
                    ::print(ss, tx_packet, i);
                    ss << "}" << std::endl;
                }
            }

            UVM_ERROR(get_name(), ss.str());
        }
    }
}

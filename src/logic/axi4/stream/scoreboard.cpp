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

#include <algorithm>
#include <iomanip>
#include <sstream>

using logic::axi4::stream::scoreboard;

static std::string print_difference(const logic::axi4::stream::packet& rx,
        const logic::axi4::stream::packet& tx) {
    std::stringstream ss;

    ss << std::endl;

    ss << std::string(71, '-') << std::endl;

    ss << "            |             rx             " <<
                      "|             tx             |" << std::endl;

    ss << std::string(71, '-') << std::endl;

    ss << "time.start  | " << std::setw(26) << rx.tdata.front().second <<
        " | " << std::setw(26) << tx.tdata.front().second << " |" << std::endl;

    ss << "time.end    | " << std::setw(26) << rx.tdata.back().second <<
        " | " << std::setw(26) << tx.tdata.back().second << " |" << std::endl;

    ss << "time.total  | " << std::setw(26) <<
            (rx.tdata.back().second - rx.tdata.front().second) <<
        " | " << std::setw(26) <<
            (tx.tdata.back().second - tx.tdata.front().second) <<
        " |" << std::endl;

    ss << "transfers   | " << std::setw(26) << rx.transfers <<
        " | " << std::setw(26) << tx.transfers << " |" << std::endl;

    ss << "bus.width   | " << std::setw(26) << 8 * rx.bus_size <<
        " | " << std::setw(26) << 8 * tx.bus_size << " |"  << std::endl;

    ss << "tid         | " << std::setw(26) << std::uintmax_t(rx.tid) <<
        " | " << std::setw(26) << std::uintmax_t(tx.tid) << " |"  << std::endl;

    ss << "tid.width   | " << std::setw(26) << rx.tid.size() <<
        " | " << std::setw(26) << tx.tid.size() << " |"  << std::endl;

    ss << "tdest       | " << std::setw(26) << std::uintmax_t(rx.tdest) <<
        " | " << std::setw(26) << std::uintmax_t(tx.tdest) << " |"  <<
        std::endl;

    ss << "tdest.width | " << std::setw(26) << rx.tdest.size() <<
        " | " << std::setw(26) << tx.tdest.size() << " |"  << std::endl;

    auto bytes = [] (const logic::axi4::stream::packet& packet) {
        return std::count_if(packet.tdata.cbegin(), packet.tdata.cend(),
            [] (const logic::axi4::stream::packet::data_type& data) {
                return data.first.is_data_byte();
            }
        );
    };

    ss << "tdata.bytes | " << std::setw(26) << bytes(rx) <<
        " | " << std::setw(26) << bytes(tx) << " |"  << std::endl;

    ss << "tdata.total | " << std::setw(26) << rx.tdata.size() <<
        " | " << std::setw(26) << tx.tdata.size() << " |"  << std::endl;

    ss << std::string(71, '-') << std::endl;

    auto print_type = [] (const logic::axi4::stream::tdata_byte& data) {
        std::string str;

        switch (data.type()) {
            case logic::axi4::stream::tdata_byte::DATA_BYTE:
                str = "  Data  ";
                break;
            case logic::axi4::stream::tdata_byte::POSITION_BYTE:
                str = "Position";
                break;
            case logic::axi4::stream::tdata_byte::NULL_BYTE:
                str = "  Null  ";
                break;
            case logic::axi4::stream::tdata_byte::RESERVED:
            default:
                str = "Reserved";
                break;
        }

        return str;
    };

    ss << "      index |   time   |   type   | data" <<
                     " |   time   |   type   | data |" << std::endl;

    ss << std::string(71, '-') << std::endl;

    const std::size_t max_length = std::max(rx.tdata.size(), tx.tdata.size());

    for (std::size_t i = 0; i < max_length; ++i) {
        ss << std::setw(11) << std::setfill(' ') << std::dec << i;

        if (i < rx.tdata.size()) {
            ss <<
                " | " << std::setw(8) << rx.tdata[i].second <<
                " | " << print_type(rx.tdata[i].first) <<
                " | 0x" << std::setw(2) << std::setfill('0') <<
                    std::hex << unsigned(rx.tdata[i].first.data());
        }
        else {
           ss << " | -------- | -------- | ----";
        }

        if (i < tx.tdata.size()) {
            ss <<
                " | " << std::setw(8) << std::setfill(' ') <<
                    std::dec << tx.tdata[i].second <<
                " | " << print_type(tx.tdata[i].first) <<
                " | 0x" << std::setw(2) << std::setfill('0') <<
                std::hex << unsigned(tx.tdata[i].first.data()) <<
                " |" << std::endl;
        }
        else {
           ss << " | -------- | -------- | ---- |" << std::endl;
        }
    }

    ss << std::string(71, '-') << std::endl;

    return ss.str();
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
            UVM_ERROR(get_name(), print_difference(*m_rx_packet, *m_tx_packet));
        }
    }
}

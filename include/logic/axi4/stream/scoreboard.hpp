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

#ifndef LOGIC_AXI4_STREAM_SCOREBOARD_HPP
#define LOGIC_AXI4_STREAM_SCOREBOARD_HPP

#include "packet.hpp"

#include <tlm>
#include <uvm>

#include <cstddef>

namespace logic {
namespace axi4 {
namespace stream {

class scoreboard : public uvm::uvm_scoreboard {
public:
    UVM_COMPONENT_UTILS(logic::axi4::stream::scoreboard)

    scoreboard();

    explicit scoreboard(const uvm::uvm_component_name& component_name);

    bool passed() const noexcept;

    bool failed() const noexcept;

    scoreboard(scoreboard&&) = delete;

    scoreboard(const scoreboard&) = delete;

    scoreboard& operator=(scoreboard&&) = delete;

    scoreboard& operator=(const scoreboard&) = delete;

    ~scoreboard() override;

    uvm::uvm_analysis_export<packet> rx_analysis_export;
    uvm::uvm_analysis_export<packet> tx_analysis_export;
protected:
    void connect_phase(uvm::uvm_phase& phase) override;

    [[noreturn]] void run_phase(uvm::uvm_phase& phase) override;

    bool m_error;
    tlm::tlm_analysis_fifo<packet> m_rx_fifo;
    tlm::tlm_analysis_fifo<packet> m_tx_fifo;

    packet* m_rx_packet;
    packet* m_tx_packet;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_SCOREBOARD_HPP */

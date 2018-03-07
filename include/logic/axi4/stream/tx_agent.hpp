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

#ifndef LOGIC_AXI4_STREAM_TX_AGENT_HPP
#define LOGIC_AXI4_STREAM_TX_AGENT_HPP

#include <uvm>

namespace logic {
namespace axi4 {
namespace stream {

class packet;
class monitor;
class tx_driver;
class tx_sequencer;

class tx_agent : public uvm::uvm_agent {
public:
    UVM_COMPONENT_UTILS(logic::axi4::stream::tx_agent)

    tx_agent();

    explicit tx_agent(const uvm::uvm_component_name& component_name);

    tx_agent(tx_agent&&) = delete;

    tx_agent(const tx_agent&) = delete;

    tx_agent& operator=(tx_agent&&) = delete;

    tx_agent& operator=(const tx_agent&) = delete;

    ~tx_agent() override;

    uvm::uvm_analysis_port<packet> analysis_port;
    tx_sequencer* sequencer;
protected:
    void build_phase(uvm::uvm_phase& phase) override;

    void connect_phase(uvm::uvm_phase& phase) override;

    monitor* m_monitor;
    tx_driver* m_driver;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_TX_AGENT_HPP */

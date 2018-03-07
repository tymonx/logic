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

#ifndef LOGIC_AXI4_STREAM_RX_SEQUENCER_HPP
#define LOGIC_AXI4_STREAM_RX_SEQUENCER_HPP

#include <uvm>

namespace logic {
namespace axi4 {
namespace stream {

class rx_sequence_item;

class rx_sequencer : public uvm::uvm_sequencer<rx_sequence_item> {
public:
    UVM_COMPONENT_UTILS(logic::axi4::stream::rx_sequencer)

    rx_sequencer();

    explicit rx_sequencer(const uvm::uvm_component_name& component_name);

    rx_sequencer(rx_sequencer&&) = delete;

    rx_sequencer(const rx_sequencer&) = delete;

    rx_sequencer& operator=(rx_sequencer&&) = delete;

    rx_sequencer& operator=(const rx_sequencer&) = delete;

    ~rx_sequencer() override;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_RX_SEQUENCER_HPP */

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

#ifndef LOGIC_AXI4_STREAM_RESET_SEQUENCER_HPP
#define LOGIC_AXI4_STREAM_RESET_SEQUENCER_HPP

#include <uvm>

namespace logic {
namespace axi4 {
namespace stream {

class reset_sequence_item;

class reset_sequencer : public uvm::uvm_sequencer<reset_sequence_item> {
public:
    UVM_COMPONENT_UTILS(logic::axi4::stream::reset_sequencer)

    reset_sequencer();

    explicit reset_sequencer(const uvm::uvm_component_name& component_name);

    reset_sequencer(reset_sequencer&&) = delete;

    reset_sequencer(const reset_sequencer&) = delete;

    reset_sequencer& operator=(reset_sequencer&&) = delete;

    reset_sequencer& operator=(const reset_sequencer&) = delete;

    ~reset_sequencer() override;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_RESET_SEQUENCER_HPP */

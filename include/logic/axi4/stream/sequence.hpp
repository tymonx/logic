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

#ifndef LOGIC_AXI4_STREAM_SEQUENCE_HPP
#define LOGIC_AXI4_STREAM_SEQUENCE_HPP

#include "logic/axi4/stream/reset_sequence.hpp"
#include "logic/axi4/stream/rx_sequence.hpp"
#include "logic/axi4/stream/tx_sequence.hpp"
#include "logic/range.hpp"

#include <uvm>

namespace logic {
namespace axi4 {
namespace stream {

class rx_sequencer;
class tx_sequencer;
class reset_sequencer;

class sequence : public uvm::uvm_sequence<> {
public:
    UVM_OBJECT_UTILS(logic::axi4::stream::sequence)

    reset_sequence* reset;
    rx_sequence* rx;
    tx_sequence* tx;

    sequence();

    explicit sequence(const std::string& name);

    sequence(sequence&&) = delete;

    sequence(const sequence&) = delete;

    sequence& operator=(sequence&&) = delete;

    sequence& operator=(const sequence&) = delete;

    ~sequence() override;
protected:
    void pre_body() override;

    void body() override;

    void post_body() override;

    rx_sequencer* m_rx_sequencer;
    tx_sequencer* m_tx_sequencer;
    reset_sequencer* m_reset_sequencer;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_SEQUENCE_HPP */

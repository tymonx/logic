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

#include "logic/range.hpp"

#include <uvm>

#include <cstddef>
#include <utility>

namespace logic {
namespace axi4 {
namespace stream {

class rx_sequence;
class tx_sequence;
class rx_sequencer;
class tx_sequencer;
class reset_sequence;
class reset_sequencer;

class sequence : public uvm::uvm_sequence<> {
public:
    UVM_OBJECT_UTILS(logic::axi4::stream::sequence)

    range length;
    range packets;
    range rx_idle;
    range tx_idle;

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

    rx_sequence* m_rx_sequence;
    tx_sequence* m_tx_sequence;
    reset_sequence* m_reset_sequence;

    rx_sequencer* m_rx_sequencer;
    tx_sequencer* m_tx_sequencer;
    reset_sequencer* m_reset_sequencer;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_SEQUENCE_HPP */

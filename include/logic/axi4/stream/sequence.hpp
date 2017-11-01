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

#ifndef LOGIC_AXI4_STREAM_SEQUENCE_HPP
#define LOGIC_AXI4_STREAM_SEQUENCE_HPP

#include <uvm>
#include <scv.h>

#include <cstddef>

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
    UVM_OBJECT_UTILS(sequence)

    scv_smart_ptr<std::size_t> reset_idle;
    scv_smart_ptr<std::size_t> reset_duration;
    scv_smart_ptr<std::size_t> reset_repeats;

    scv_smart_ptr<std::size_t> rx_idle_scheme;
    scv_smart_ptr<std::size_t> rx_number_of_packets;
    scv_smart_ptr<std::size_t> rx_packet_length;
    scv_smart_ptr<std::size_t> rx_repeats;

    scv_smart_ptr<std::size_t> tx_idle_scheme;
    scv_smart_ptr<std::size_t> tx_number_of_packets;

    sequence();

    sequence(const std::string& name);

    virtual ~sequence() override;
protected:
    sequence(const sequence&) = delete;

    sequence& operator=(const sequence&) = delete;

    virtual void pre_body() override;

    virtual void body() override;

    virtual void post_body() override;

    void tx_sequence_handler(std::size_t packets_count);

    void rx_sequence_handler(std::size_t packets_count);

    void reset_sequence_handler();

    rx_sequence* m_rx_sequence;
    tx_sequence* m_tx_sequence;
    reset_sequence* m_reset_sequence;

    rx_sequencer* m_rx_sequencer;
    tx_sequencer* m_tx_sequencer;
    reset_sequencer* m_reset_sequencer;
};

}
}
}

#endif /* LOGIC_AXI4_STREAM_SEQUENCE_HPP */

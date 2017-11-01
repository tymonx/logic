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

#include "logic/axi4/stream/sequence.hpp"

#include "logic/axi4/stream/sequencer.hpp"
#include "logic/axi4/stream/rx_sequence.hpp"
#include "logic/axi4/stream/tx_sequence.hpp"
#include "logic/axi4/stream/rx_sequencer.hpp"
#include "logic/axi4/stream/tx_sequencer.hpp"
#include "logic/axi4/stream/reset_sequence.hpp"
#include "logic/axi4/stream/reset_sequencer.hpp"

#include <systemc>

using logic::axi4::stream::sequence;

sequence::sequence() :
    sequence("sequence")
{ }

sequence::sequence(const std::string& name) :
    uvm::uvm_sequence<>{name},
    reset_idle{},
    reset_duration{},
    reset_repeats{},
    rx_idle_scheme{},
    rx_number_of_packets{},
    rx_packet_length{},
    rx_repeats{},
    tx_idle_scheme{},
    tx_number_of_packets{},
    m_rx_sequence{nullptr},
    m_tx_sequence{nullptr},
    m_reset_sequence{nullptr},
    m_rx_sequencer{nullptr},
    m_tx_sequencer{nullptr},
    m_reset_sequencer{nullptr}

{
    m_rx_sequence = rx_sequence::type_id::create("rx_sequence", nullptr);
    if (!m_rx_sequence) {
        UVM_FATAL(get_name(), "Cannot create Rx sequence!"
                " Simulation aborted!");
    }

    m_tx_sequence = tx_sequence::type_id::create("tx_sequence", nullptr);
    if (!m_tx_sequence) {
        UVM_FATAL(get_name(), "Cannot create Tx sequence!"
                " Simulation aborted!");
    }

    m_reset_sequence = reset_sequence::type_id::create("reset_sequence", nullptr);
    if (!m_reset_sequence) {
        UVM_FATAL(get_name(), "Cannot create reset sequence!"
                " Simulation aborted!");
    }
}

sequence::~sequence() { }

void sequence::pre_body() {
    if (starting_phase) {
        starting_phase->raise_objection(this);
    }

    auto sequencer = dynamic_cast<logic::axi4::stream::sequencer*>(get_sequencer());
    if (sequencer) {
        m_rx_sequencer = sequencer->rx_sequencer;
        m_tx_sequencer = sequencer->tx_sequencer;
        m_reset_sequencer = sequencer->reset_sequencer;
    }
    else {
        UVM_FATAL(get_name(), "Cannot get sequencer! Simulation aborted!");
    }

    m_reset_sequence->number_of_resets = reset_repeats;
    m_reset_sequence->idle = reset_idle;
    m_reset_sequence->duration = reset_duration;

    m_rx_sequence->number_of_packets = rx_number_of_packets;
    m_rx_sequence->packet_length = rx_packet_length;
    m_rx_sequence->idle_scheme = rx_idle_scheme;

    m_tx_sequence->number_of_packets = tx_number_of_packets;
    m_tx_sequence->idle_scheme = tx_idle_scheme;
}

void sequence::body() {
    UVM_INFO(get_name(), "Starting sequence", uvm::UVM_FULL);

    rx_repeats->next();
    std::size_t repeat_count = *rx_repeats;

    for (auto i = 0u; i < repeat_count; ++i) {
        reset_sequence_handler();

        rx_number_of_packets->next();
        std::size_t packets_count = *rx_number_of_packets;

        SC_FORK
            sc_core::sc_spawn(sc_bind(&sequence::rx_sequence_handler, this,
                        packets_count), "rx_sequence_handler", nullptr),
            sc_core::sc_spawn(sc_bind(&sequence::tx_sequence_handler, this,
                        packets_count), "tx_sequence_handler", nullptr)
        SC_JOIN
    }

    UVM_INFO(get_name(), "Finishing sequence", uvm::UVM_FULL);
}

void sequence::reset_sequence_handler() {
    m_reset_sequence->start(m_reset_sequencer);
}

void sequence::rx_sequence_handler(std::size_t packets_count) {
    m_rx_sequence->number_of_packets = {};
    m_rx_sequence->number_of_packets->keep_only(packets_count);

    m_rx_sequence->start(m_rx_sequencer);
}

void sequence::tx_sequence_handler(std::size_t packets_count) {
    m_tx_sequence->number_of_packets = {};
    m_tx_sequence->number_of_packets->keep_only(packets_count);

    m_tx_sequence->start(m_tx_sequencer);
}

void sequence::post_body() {
    if (starting_phase) {
        starting_phase->drop_objection(this);
    }
}

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

#include "logic/axi4/stream/sequence.hpp"

#include "logic/axi4/stream/reset_sequence.hpp"
#include "logic/axi4/stream/reset_sequencer.hpp"
#include "logic/axi4/stream/rx_sequence.hpp"
#include "logic/axi4/stream/rx_sequencer.hpp"
#include "logic/axi4/stream/sequencer.hpp"
#include "logic/axi4/stream/tx_sequence.hpp"
#include "logic/axi4/stream/tx_sequencer.hpp"

#include <systemc>

#include <random>
#include <utility>

using logic::axi4::stream::sequence;

sequence::sequence() :
    sequence("sequence")
{ }

sequence::sequence(const std::string& name) :
    uvm::uvm_sequence<>{name},
    length{1, 256},
    packets{1, 8},
    rx_idle{0},
    tx_idle{0},
    m_rx_sequence{nullptr},
    m_tx_sequence{nullptr},
    m_reset_sequence{nullptr},
    m_rx_sequencer{nullptr},
    m_tx_sequencer{nullptr},
    m_reset_sequencer{nullptr}

{
    m_rx_sequence = rx_sequence::type_id::create("rx_sequence", nullptr);
    if (m_rx_sequence == nullptr) {
        UVM_FATAL(get_name(), "Cannot create Rx sequence!"
                " Simulation aborted!");
    }

    m_tx_sequence = tx_sequence::type_id::create("tx_sequence", nullptr);
    if (m_tx_sequence == nullptr) {
        UVM_FATAL(get_name(), "Cannot create Tx sequence!"
                " Simulation aborted!");
    }

    m_reset_sequence = reset_sequence::type_id::create("reset_sequence", nullptr);
    if (m_reset_sequence == nullptr) {
        UVM_FATAL(get_name(), "Cannot create reset sequence!"
                " Simulation aborted!");
    }
}

sequence::~sequence() = default;

void sequence::pre_body() {
    if (starting_phase != nullptr) {
        starting_phase->raise_objection(this);
    }

    auto sequencer = dynamic_cast<logic::axi4::stream::sequencer*>(get_sequencer());
    if (sequencer != nullptr) {
        m_rx_sequencer = sequencer->rx_sequencer;
        m_tx_sequencer = sequencer->tx_sequencer;
        m_reset_sequencer = sequencer->reset_sequencer;
    }
    else {
        UVM_FATAL(get_name(), "Cannot get sequencer! Simulation aborted!");
    }
}

void sequence::body() {
    UVM_INFO(get_name(), "Starting sequence", uvm::UVM_FULL);

    std::random_device rd;
    std::mt19937 random_generator(rd());

    std::uniform_int_distribution<std::size_t>
        random_packets(packets.min(), packets.max());

    const std::size_t packets_count = random_packets(random_generator);

    m_rx_sequence->req.idle = rx_idle;
    m_tx_sequence->req.idle = tx_idle;

    m_reset_sequence->start(m_reset_sequencer);

    SC_FORK
        sc_core::sc_spawn(sc_bind([&] () {
            for (std::size_t i = 0; i < packets_count; ++i) {
                std::uniform_int_distribution<std::size_t>
                    random_length{length.min(), length.max()};

                std::uniform_int_distribution<std::uint8_t> random_data{};

                m_rx_sequence->req.data.resize(
                        random_length(random_generator));

                for (auto& item : m_rx_sequence->req.data) {
                    item = random_data(random_generator);
                }

                m_rx_sequence->start(m_rx_sequencer);
            }
        }), "rx_sequence_handler", nullptr),
        sc_core::sc_spawn(sc_bind([&] () {
            for (std::size_t i = 0; i < packets_count; ++i) {
                m_tx_sequence->start(m_tx_sequencer);
            }
        }), "tx_sequence_handler", nullptr)
    SC_JOIN

    UVM_INFO(get_name(), "Finishing sequence", uvm::UVM_FULL);
}

void sequence::post_body() {
    if (starting_phase != nullptr) {
        starting_phase->drop_objection(this);
    }
}

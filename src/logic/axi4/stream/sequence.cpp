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

using logic::axi4::stream::sequence;

sequence::sequence() :
    sequence("sequence")
{ }

sequence::sequence(const std::string& name) :
    uvm::uvm_sequence<>{name},
    reset{nullptr},
    rx{nullptr},
    tx{nullptr},
    m_rx_sequencer{nullptr},
    m_tx_sequencer{nullptr},
    m_reset_sequencer{nullptr}

{
    rx = rx_sequence::type_id::create("rx_sequence", nullptr);
    if (rx == nullptr) {
        UVM_FATAL(get_name(), "Cannot create Rx sequence!"
                " Simulation aborted!");
    }

    tx = tx_sequence::type_id::create("tx_sequence", nullptr);
    if (tx == nullptr) {
        UVM_FATAL(get_name(), "Cannot create Tx sequence!"
                " Simulation aborted!");
    }

    reset = reset_sequence::type_id::create("reset_sequence", nullptr);
    if (reset == nullptr) {
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

    reset->start(m_reset_sequencer);

    SC_FORK
        sc_core::sc_spawn(
            sc_bind([&] () {
                rx->start(m_rx_sequencer);
            }),
            "rx_sequence_handler",
            nullptr
        ),
        sc_core::sc_spawn(
            sc_bind([&] () {
                tx->start(m_tx_sequencer);
            }),
            "tx_sequence_handler",
            nullptr
        )
    SC_JOIN

    UVM_INFO(get_name(), "Finishing sequence", uvm::UVM_FULL);
}

void sequence::post_body() {
    if (starting_phase != nullptr) {
        starting_phase->drop_objection(this);
    }
}

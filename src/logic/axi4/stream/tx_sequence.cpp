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

#include "logic/axi4/stream/tx_sequence.hpp"

using logic::axi4::stream::tx_sequence;

tx_sequence::tx_sequence() :
    tx_sequence{"tx_sequence"}
{ }

tx_sequence::tx_sequence(const std::string& name) :
    uvm::uvm_sequence<tx_sequence_item>{name},
    idle_scheme{},
    number_of_packets{}
{ }

tx_sequence::~tx_sequence() { }

void tx_sequence::pre_body() {
    if (starting_phase) {
        starting_phase->raise_objection(this);
    }
}

void tx_sequence::body() {
    UVM_INFO(get_name(), "Starting sequence", uvm::UVM_FULL);

    number_of_packets->next();
    const std::size_t packets_count = *number_of_packets;

    for (std::size_t i = 0; i < packets_count; ++i) {
        tx_sequence_item item;
        item.idle_scheme.resize(16);

        item.randomize();

        for (auto& idle : item.idle_scheme) {
            idle_scheme->next();
            idle = *idle_scheme;
        }

        start_item(&item);
        finish_item(&item);
    }

    UVM_INFO(get_name(), "Finishing sequence", uvm::UVM_FULL);
}

void tx_sequence::post_body() {
    if (starting_phase) {
        starting_phase->drop_objection(this);
    }
}

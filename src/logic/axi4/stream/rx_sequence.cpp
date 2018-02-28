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

#include "logic/axi4/stream/rx_sequence.hpp"

using logic::axi4::stream::rx_sequence;

rx_sequence::rx_sequence() :
    rx_sequence{"rx_sequence"}
{ }

rx_sequence::rx_sequence(const std::string& name) :
    uvm::uvm_sequence<rx_sequence_item>{name},
    items{}
{ }

rx_sequence::~rx_sequence() = default;

void rx_sequence::pre_body() {
    if (starting_phase != nullptr) {
        starting_phase->raise_objection(this);
    }
}

void rx_sequence::body() {
    UVM_INFO(get_name(), "Starting sequence", uvm::UVM_FULL);

    for (auto& item : items) {
        start_item(&item);
        finish_item(&item);
    }

    UVM_INFO(get_name(), "Finishing sequence", uvm::UVM_FULL);
}

void rx_sequence::post_body() {
    if (starting_phase != nullptr) {
        starting_phase->drop_objection(this);
    }
}

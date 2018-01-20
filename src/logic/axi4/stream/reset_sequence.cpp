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

#include "logic/axi4/stream/reset_sequence.hpp"

using logic::axi4::stream::reset_sequence;

reset_sequence::reset_sequence() :
    reset_sequence{"reset_sequence"}
{ }

reset_sequence::reset_sequence(const std::string& name) :
    uvm::uvm_sequence<reset_sequence_item>{name},
    duration{},
    idle{},
    number_of_resets{}
{ }

reset_sequence::~reset_sequence() { }

void reset_sequence::pre_body() {
    if (starting_phase) {
        starting_phase->raise_objection(this);
    }
}

void reset_sequence::body() {
    UVM_INFO(get_name(), "Starting reset sequence", uvm::UVM_FULL);

    number_of_resets->next();
    const std::size_t resets = *number_of_resets;

    for (std::size_t i = 0; i < resets; ++i) {
        reset_sequence_item item;

        duration->next();
        idle->next();

        item.randomize();
        item.duration = *duration;
        item.idle = *idle;

        start_item(&item);
        finish_item(&item);
    }

    UVM_INFO(get_name(), "Finishing reset sequence", uvm::UVM_FULL);
}

void reset_sequence::post_body() {
    if (starting_phase) {
        starting_phase->drop_objection(this);
    }
}

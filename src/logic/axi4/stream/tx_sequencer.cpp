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

#include "logic/axi4/stream/tx_sequencer.hpp"
#include "logic/axi4/stream/tx_sequence_item.hpp"

using logic::axi4::stream::tx_sequencer;

tx_sequencer::tx_sequencer() :
    tx_sequencer("tx_sequencer")
{ }

tx_sequencer::tx_sequencer(const uvm::uvm_component_name& component_name) :
    uvm::uvm_sequencer<tx_sequence_item>(component_name)
{ }

tx_sequencer::~tx_sequencer() = default;

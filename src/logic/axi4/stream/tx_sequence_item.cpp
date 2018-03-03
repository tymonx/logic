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

#include "logic/axi4/stream/tx_sequence_item.hpp"

using logic::axi4::stream::tx_sequence_item;

static constexpr std::size_t TIMEOUT{10000};

tx_sequence_item::tx_sequence_item() :
    tx_sequence_item{"sequence_item"}
{ }

tx_sequence_item::tx_sequence_item(const std::string& name) :
    uvm::uvm_sequence_item{name},
    tid{},
    tdest{},
    timeout{TIMEOUT},
    idle{}
{ }

std::string tx_sequence_item::convert2string() const {
    std::ostringstream ss;
    return ss.str();
}

tx_sequence_item::~tx_sequence_item() = default;

void tx_sequence_item::do_print(const uvm::uvm_printer&) const { }

void tx_sequence_item::do_pack(uvm::uvm_packer&) const { }

void tx_sequence_item::do_unpack(uvm::uvm_packer&) { }

void tx_sequence_item::do_copy(const uvm::uvm_object& rhs) {
    auto other = dynamic_cast<const tx_sequence_item*>(&rhs);
    if (other != nullptr) {
        *this = *other;
    }
    else {
        UVM_ERROR(get_name(), "Error in do_copy");
    }
}

bool tx_sequence_item::do_compare(const uvm::uvm_object& rhs,
        const uvm::uvm_comparer* /* comparer */) const {
    auto other = dynamic_cast<const tx_sequence_item*>(&rhs);
    auto status = false;

    if (other != nullptr) {
        status = true;
    }
    else {
        UVM_ERROR(get_name(), "Error in do_compare");
    }

    return status;
}

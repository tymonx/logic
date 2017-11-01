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

#include "logic/axi4/stream/tx_sequence_item.hpp"

using logic::axi4::stream::tx_sequence_item;

tx_sequence_item::tx_sequence_item() :
    tx_sequence_item{"sequence_item"}
{ }

tx_sequence_item::tx_sequence_item(const std::string& name) :
    uvm::uvm_sequence_item{name},
    number_of_packets{},
    idle_scheme{}
{ }

void tx_sequence_item::randomize() {
    number_of_packets->next();
}

std::string tx_sequence_item::convert2string() const {
    std::ostringstream ss;
    ss << "packets: " << std::size_t(*number_of_packets);
    return ss.str();
}

tx_sequence_item::~tx_sequence_item() { }

void tx_sequence_item::do_print(const uvm::uvm_printer& printer) const {
    printer.print_field_int("number_of_packets",
            std::size_t(*number_of_packets), 8 * sizeof(std::size_t));

    printer.print_field_int("idle_scheme",
            std::size_t(*idle_scheme), 8 * sizeof(std::size_t));
}

void tx_sequence_item::do_pack(uvm::uvm_packer& p) const {
    p << std::size_t(*number_of_packets);
}

void tx_sequence_item::do_unpack(uvm::uvm_packer& p) {
    std::size_t value;
    p >> value;
    *number_of_packets = value;
}

void tx_sequence_item::do_copy(const uvm::uvm_object& rhs) {
    auto other = dynamic_cast<const tx_sequence_item*>(&rhs);
    if (other) {
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

    if (other) {
        status = (*number_of_packets == *other->number_of_packets);
    }
    else {
        UVM_ERROR(get_name(), "Error in do_compare");
    }

    return status;
}

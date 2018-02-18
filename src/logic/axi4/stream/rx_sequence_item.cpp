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

#include "logic/axi4/stream/rx_sequence_item.hpp"

#include <iomanip>

static constexpr std::size_t TIMEOUT{10000};

using logic::axi4::stream::rx_sequence_item;

rx_sequence_item::rx_sequence_item() :
    rx_sequence_item{"rx_sequence_item"}
{ }

rx_sequence_item::rx_sequence_item(const std::string& name) :
    uvm::uvm_sequence_item{name},
    idle{},
    timeout{TIMEOUT}
{
    id.resize(1);
    destination.resize(1);
    user.resize(1);
    user[0].resize(1);
}

auto rx_sequence_item::convert2string() const -> std::string {
    std::ostringstream ss;
    ss << " data:";

    for (const auto& value : data) {
        ss << " " << std::hex << std::setfill('0') << std::setw(2) <<
            unsigned(value);
    }

    return ss.str();
}

rx_sequence_item::~rx_sequence_item() = default;

void rx_sequence_item::do_print(const uvm::uvm_printer& printer) const {
    printer.print_array_header("data", int(data.size()),
            "std::vector<std::uint8_t>");

    for (const auto& value : data) {
        printer.print_field_int("", int(value), 8, uvm::UVM_HEX);
    }

    printer.print_array_footer();
}

void rx_sequence_item::do_pack(uvm::uvm_packer& p) const {
    p << data;
}

void rx_sequence_item::do_unpack(uvm::uvm_packer& p) {
    p >> data;
}

void rx_sequence_item::do_copy(const uvm::uvm_object& rhs) {
    auto other = dynamic_cast<const rx_sequence_item*>(&rhs);
    if (other != nullptr) {
        *this = *other;
    }
    else {
        UVM_ERROR(get_name(), "Error in do_copy");
    }
}

bool rx_sequence_item::do_compare(const uvm::uvm_object& rhs,
        const uvm::uvm_comparer* /* comparer */) const {
    auto other = dynamic_cast<const rx_sequence_item*>(&rhs);
    auto status = false;

    if (other != nullptr) {
        status = (data == other->data);
    }
    else {
        UVM_ERROR(get_name(), "Error in do_compare");
    }

    return status;
}

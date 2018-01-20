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

#include <scv.h>

#include <iomanip>

static constexpr std::size_t TIMEOUT{10000};

using logic::axi4::stream::rx_sequence_item;

rx_sequence_item::rx_sequence_item() :
    rx_sequence_item{"rx_sequence_item"}
{ }

rx_sequence_item::rx_sequence_item(const std::string& name) :
    uvm::uvm_sequence_item{name},
    tid{},
    tdest{},
    tuser{},
    tdata{},
    idle_scheme{},
    timeout{TIMEOUT}
{
    tid.resize(1);
    tdest.resize(1);
    tuser.resize(1);
    tuser[0].resize(1);
}

void rx_sequence_item::randomize() {
    scv_smart_ptr<bool> random_bit;
    scv_smart_ptr<std::uint8_t> random_byte;
    scv_smart_ptr<std::size_t> random_idle;

    random_idle->keep_only(0, 3);

    for (auto bit : tid) {
        random_bit->next();
        bit = *random_bit;
    }

    for (auto bit : tdest) {
        random_bit->next();
        bit = *random_bit;
    }

    for (auto& item : tuser) {
        for (auto bit : item) {
            random_bit->next();
            bit = *random_bit;
        }
    }

    for (auto& byte : tdata) {
        random_byte->next();
        byte = *random_byte;
    }

    for (auto& idle : idle_scheme) {
        random_idle->next();
        idle = *random_idle;
    }
}

auto rx_sequence_item::convert2string() const -> std::string {
    std::ostringstream ss;
    ss << " data:";

    for (const auto& value : tdata) {
        ss << " " << std::hex << std::setfill('0') << std::setw(2) <<
            unsigned(value);
    }

    return ss.str();
}

rx_sequence_item::~rx_sequence_item() { }

void rx_sequence_item::do_print(const uvm::uvm_printer& printer) const {
    printer.print_array_header("data", int(tdata.size()),
            "std::vector<std::uint8_t>");

    for (const auto& value : tdata) {
        printer.print_field_int("", value, 8, uvm::UVM_HEX);
    }

    printer.print_array_footer();
}

void rx_sequence_item::do_pack(uvm::uvm_packer& p) const {
    p << tdata;
}

void rx_sequence_item::do_unpack(uvm::uvm_packer& p) {
    p >> tdata;
}

void rx_sequence_item::do_copy(const uvm::uvm_object& rhs) {
    auto other = dynamic_cast<const rx_sequence_item*>(&rhs);
    if (other) {
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

    if (other) {
        status = (tdata == other->tdata);
    }
    else {
        UVM_ERROR(get_name(), "Error in do_compare");
    }

    return status;
}

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

#include "logic/axi4/stream/packet.hpp"

#include <iomanip>

using logic::axi4::stream::packet;

packet::packet() :
    packet{"packet"}
{ }

packet::packet(const std::string& name) :
    uvm::uvm_object{name},
    tid{},
    tdest{},
    tuser{},
    tdata{},
    tdata_timestamp{},
    transfer_timestamp{},
    bus_size{}
{ }

auto packet::clear() -> packet& {
    tid.clear();
    tdest.clear();
    tuser.clear();
    tdata.clear();
    tdata_timestamp.clear();
    transfer_timestamp.clear();
    bus_size = 0;
    return *this;
}

std::string packet::convert2string() const {
    std::ostringstream ss;
    ss << " data:";

    for (const auto& value : tdata) {
        ss << " " << std::hex << std::setfill('0') << std::setw(2) <<
            unsigned(value);
    }

    return ss.str();
}

packet::~packet() { }

void packet::do_print(const uvm::uvm_printer& printer) const {
    printer.print_array_header("data", int(tdata.size()),
            "std::vector<std::uint8_t>");

    for (const auto& value : tdata) {
        printer.print_field_int("", int(value), 8, uvm::UVM_HEX);
    }

    printer.print_array_footer();
}

void packet::do_pack(uvm::uvm_packer& p) const {
    p << tdata;
}

void packet::do_unpack(uvm::uvm_packer& p) {
    p >> tdata;
}

void packet::do_copy(const uvm::uvm_object& rhs) {
    auto other = dynamic_cast<const packet*>(&rhs);
    if (other) {
        *this = *other;
    }
    else {
        UVM_ERROR(get_name(), "Error in do_copy");
    }
}

bool packet::do_compare(const uvm::uvm_object& rhs,
        const uvm::uvm_comparer* /* comparer */) const {
    auto other = dynamic_cast<const packet*>(&rhs);
    auto status = false;

    if (other) {
        status = (tid == other->tid) && (tdest == other->tdest) &&
            (tdata == other->tdata);
    }
    else {
        UVM_ERROR(get_name(), "Error in do_compare");
    }

    return status;
}

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

#include "logic/axi4/stream/rx_sequence_item.hpp"

#include <iomanip>

using logic::axi4::stream::rx_sequence_item;

rx_sequence_item::rx_sequence_item() :
    uvm::uvm_sequence_item{"rx_sequence_item"}
{ }

rx_sequence_item::rx_sequence_item(const std::string& name) :
    uvm::uvm_sequence_item{name}
{ }

auto rx_sequence_item::idle(std::size_t value) noexcept -> rx_sequence_item& {
    m_idle = {value, value};
    return *this;
}

auto rx_sequence_item::idle(std::size_t min, std::size_t max) noexcept
        -> rx_sequence_item& {
    m_idle = {min, max};
    return *this;
}

auto rx_sequence_item::idle(const range& value) noexcept -> rx_sequence_item& {
    m_idle = value;
    return *this;
}

auto rx_sequence_item::idle() const noexcept -> const range& {
    return m_idle;
}

auto rx_sequence_item::reset(std::size_t value) noexcept -> rx_sequence_item& {
    m_reset = value;
    return *this;
}

auto rx_sequence_item::reset() const noexcept -> std::size_t {
    return m_reset;
}

auto rx_sequence_item::data(
        const std::vector<std::uint8_t>& item) -> rx_sequence_item& {
    m_data = item;
    return *this;
}

auto rx_sequence_item::data() -> std::vector<std::uint8_t>& {
    return m_data;
}

auto rx_sequence_item::data() const -> const std::vector<std::uint8_t>& {
    return m_data;
}

void rx_sequence_item::clear() {
    m_data.clear();
    m_tid.clear();
    m_tdest.clear();
    m_tuser.clear();
}

void rx_sequence_item::push(std::uint8_t item) {
    m_data.push_back(item);
}

void rx_sequence_item::tid(const bitstream& bits) {
    m_tid = bits;
}

auto rx_sequence_item::tid() const -> const bitstream& {
    return m_tid;
}

auto rx_sequence_item::tid() -> bitstream& {
    return m_tid;
}

void rx_sequence_item::tdest(const bitstream& bits) {
    m_tdest = bits;
}

auto rx_sequence_item::tdest() const -> const bitstream& {
    return m_tdest;
}

auto rx_sequence_item::tdest() -> bitstream& {
    return m_tdest;
}

void rx_sequence_item::tuser(const bitstream& bits) {
    m_tuser.assign(1, bits);
}

void rx_sequence_item::tuser(const std::vector<bitstream>& bits) {
    m_tuser = bits;
}

auto rx_sequence_item::tuser() -> std::vector<bitstream>& {
    return m_tuser;
}

auto rx_sequence_item::tuser() const -> const std::vector<bitstream>& {
    return m_tuser;
}

auto rx_sequence_item::convert2string() const -> std::string {
    std::ostringstream ss;
    ss << " data:";

    for (const auto& value : m_data) {
        ss << " " << std::hex << std::setfill('0') << std::setw(2) <<
            unsigned(value);
    }

    return ss.str();
}

rx_sequence_item::~rx_sequence_item() { }

void rx_sequence_item::do_print(const uvm::uvm_printer& printer) const {
    printer.print_array_header("data", int(m_data.size()),
            "std::vector<std::uint8_t>");

    for (const auto& value : m_data) {
        printer.print_field_int("", value, 8, uvm::UVM_HEX);
    }

    printer.print_array_footer();
}

void rx_sequence_item::do_pack(uvm::uvm_packer& p) const {
    p << m_data;
}

void rx_sequence_item::do_unpack(uvm::uvm_packer& p) {
    p >> m_data;
}

void rx_sequence_item::do_copy(const uvm::uvm_object& rhs) {
    auto other = dynamic_cast<const rx_sequence_item*>(&rhs);
    if (other) {
        m_data = other->data();
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
        status = (m_data == other->data());
    }
    else {
        UVM_ERROR(get_name(), "Error in do_compare");
    }

    return status;
}

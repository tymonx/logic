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

#include "logic/axi4/stream/tdata_byte.hpp"

#include <uvm>

using logic::axi4::stream::tdata_byte;

tdata_byte::tdata_byte() noexcept :
    m_type{DATA_BYTE},
    m_data{0}
{ }

tdata_byte::tdata_byte(std::uint8_t data_val) noexcept :
    m_type{DATA_BYTE},
    m_data{data_val}
{ }

tdata_byte::tdata_byte(type_t type_val) noexcept :
    m_type{type_val},
    m_data{0}
{ }

tdata_byte::tdata_byte(std::uint8_t data_val, type_t type_val) noexcept :
    m_type{type_val},
    m_data{data_val}
{ }

tdata_byte::tdata_byte(const std::pair<std::uint8_t, type_t>& value) noexcept :
    m_type{value.second},
    m_data{value.first}
{ }

auto tdata_byte::operator=(std::uint8_t data_val) noexcept -> tdata_byte& {
    m_data = data_val;
    return *this;
}

auto tdata_byte::operator=(
        const std::pair<std::uint8_t, type_t>& value) noexcept -> tdata_byte& {
    m_type = value.second;
    m_data = value.first;
    return *this;
}

auto tdata_byte::data(std::uint8_t data_val) noexcept -> tdata_byte& {
    m_data = data_val;
    return *this;
}

auto tdata_byte::data() const noexcept -> std::uint8_t {
    return m_data;
}

auto tdata_byte::type(type_t type_val) noexcept -> tdata_byte& {
    m_type = type_val;
    return *this;
}

auto tdata_byte::type() const noexcept -> type_t {
    return m_type;
}

tdata_byte::operator type_t() const noexcept {
    return m_type;
}

tdata_byte::operator bool() const noexcept {
    return (0 != m_data);
}

bool tdata_byte::operator!() const noexcept {
    return (0 == m_data);
}

bool tdata_byte::is_data_byte() const noexcept {
    return (DATA_BYTE == m_type);
}

bool tdata_byte::is_null_byte() const noexcept {
    return (NULL_BYTE == m_type);
}

bool tdata_byte::is_position_byte() const noexcept {
    return (POSITION_BYTE == m_type);
}

bool tdata_byte::is_reserved() const noexcept {
    return (RESERVED == m_type);
}

bool tdata_byte::operator==(const tdata_byte& other) const noexcept {
    return (m_data == other.m_data) && (m_type == other.m_type);
}

bool tdata_byte::operator!=(const tdata_byte& other) const noexcept {
    return (m_data != other.m_data) || (m_type != other.m_type);
}

bool tdata_byte::operator<(const tdata_byte& other) const noexcept {
    return (m_data < other.m_data);
}

bool tdata_byte::operator<=(const tdata_byte& other) const noexcept {
    return (m_data <= other.m_data);
}

bool tdata_byte::operator>(const tdata_byte& other) const noexcept {
    return (m_data > other.m_data);
}

bool tdata_byte::operator>=(const tdata_byte& other) const noexcept {
    return (m_data >= other.m_data);
}

namespace uvm {

auto operator<<(uvm_packer& packer,
        const logic::axi4::stream::tdata_byte& value) -> uvm_packer& {
    return packer << value.data();
}

auto operator>>(uvm_packer& packer,
        logic::axi4::stream::tdata_byte& value) -> uvm_packer& {
    auto tmp = value.data();
    packer >> tmp;
    value = tmp;
    return packer;
}

} /* namespace uvm */

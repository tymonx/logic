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

#include "logic/range.hpp"

#include <utility>

using logic::range;

range::range() noexcept :
    m_min{0},
    m_max{0}
{ }

range::range(size_type value) noexcept :
    m_min{value},
    m_max{value}
{ }

range::range(size_type lhs, size_type rhs) noexcept :
    m_min{lhs},
    m_max{(lhs < rhs) ? rhs : lhs}
{ }

auto range::min() const noexcept -> size_type {
    return m_min;
}

auto range::max() const noexcept -> size_type {
    return m_max;
}

auto range::operator=(size_type value) noexcept -> range& {
    m_min = m_max = value;
    return *this;
}

range::operator bool() const noexcept {
    return (m_min != 0) || (m_max != 0);
}

bool range::operator!() const noexcept {
    return (m_min == 0) && (m_max == 0);
}

bool range::operator==(const range& other) const noexcept {
    return (m_min == other.m_min) && (m_max == other.m_max);
}

bool range::operator!=(const range& other) const noexcept {
    return (m_min != other.m_min) || (m_max != other.m_max);
}

template<> void
uvm::uvm_config_db<logic::range>::set(uvm_component* cntxt,
        const std::string& instname, const std::string& fieldname,
        const logic::range& value) {
    uvm_config_db<range::size_type>::set(cntxt, instname,
            fieldname + ".min", value.min());

    uvm_config_db<range::size_type>::set(cntxt, instname,
            fieldname + ".max", value.max());
}

template<> bool
uvm::uvm_config_db<logic::range>::get(uvm_component* cntxt,
        const std::string& instname, const std::string& fieldname,
        logic::range& value_range) {
    std::pair<range::size_type, range::size_type> value{};

    auto ok = uvm_config_db<range::size_type>::get(cntxt, instname, fieldname,
            value.first);
    if (ok) {
        value_range = {value.first, value.first};
    }
    else {
        ok = uvm_config_db<range::size_type>::get(cntxt, instname,
                fieldname + ".min", value.first);

        ok |= uvm_config_db<range::size_type>::get(cntxt, instname,
                fieldname + ".max", value.second);

        if (ok) {
            value_range = {value.first, value.second};
        }
    }

    return ok;
}

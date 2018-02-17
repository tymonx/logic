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

#include "logic/bitstream_reference.hpp"

#include <cstdint>

using logic::bitstream_reference;

static constexpr bitstream_reference::size_type BITS{8};

bitstream_reference::bitstream_reference(pointer bits,
        size_type index) noexcept :
    m_bits{bits},
    m_index{index}
{ }

auto bitstream_reference::operator=(
        bool value) noexcept -> bitstream_reference& {
    auto mask = std::uint8_t(1 << (m_index % BITS));
    auto data = static_cast<std::uint8_t*>(m_bits) + (m_index / BITS);

    if (value) {
        *data |= mask;
    }
    else {
        *data &= std::uint8_t(~mask);
    }

    return *this;
}

bitstream_reference::operator bool() const noexcept {
    auto mask = std::uint8_t(1 << (m_index % BITS));
    auto data = static_cast<std::uint8_t*>(m_bits) + (m_index / BITS);

    return (*data & mask) == mask;
}

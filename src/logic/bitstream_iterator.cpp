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

#include "logic/bitstream_iterator.hpp"

#include <cstdint>

using logic::bitstream_iterator;

static constexpr bitstream_iterator::difference_type BITS = 8;

bitstream_iterator::bitstream_iterator(pointer bits) noexcept :
    m_bits{bits},
    m_index{0}
{ }

bitstream_iterator::bitstream_iterator(pointer bits,
        size_type index) noexcept :
    m_bits{bits},
    m_index{difference_type(index)}
{ }

bitstream_iterator::bitstream_iterator(pointer bits,
        difference_type index) noexcept :
    m_bits{bits},
    m_index{index}
{ }

auto bitstream_iterator::operator++() noexcept -> bitstream_iterator& {
    ++m_index;
    return *this;
}

auto bitstream_iterator::operator++(int) noexcept -> const bitstream_iterator {
    bitstream_iterator tmp{*this};
    ++m_index;
    return tmp;
}

auto bitstream_iterator::operator--() noexcept -> bitstream_iterator& {
    --m_index;
    return *this;
}

auto bitstream_iterator::operator--(int) noexcept -> const bitstream_iterator {
    bitstream_iterator tmp{*this};
    --m_index;
    return tmp;
}

auto bitstream_iterator::operator+(
        difference_type n) const noexcept -> bitstream_iterator {
    return {m_bits, m_index + n};
}

auto bitstream_iterator::operator+=(
        difference_type n) noexcept -> bitstream_iterator& {
    m_index += n;
    return *this;
}

auto bitstream_iterator::operator-(
        difference_type n) const noexcept -> bitstream_iterator {
    return {m_bits, m_index - n};
}

auto bitstream_iterator::operator-=(
        difference_type n) noexcept -> bitstream_iterator& {
    m_index -= n;
    return *this;
}

auto bitstream_iterator::operator[](
        difference_type n) noexcept -> reference {
    auto index = m_index + n;
    return {m_bits, (index >= 0) ? size_type(index) : 0};
}

auto bitstream_iterator::operator[](
        difference_type n) const noexcept -> reference {
    auto index = m_index + n;
    return {m_bits, (index >= 0) ? size_type(index) : 0};
}

auto bitstream_iterator::operator*() noexcept -> reference {
    return {m_bits, (m_index >= 0) ? size_type(m_index) : 0};
}

auto bitstream_iterator::operator*() const noexcept -> reference {
    return {m_bits, (m_index >= 0) ? size_type(m_index) : 0};
}

auto bitstream_iterator::operator->() noexcept -> pointer {
    return static_cast<std::uint8_t*>(m_bits) + (m_index / BITS);
}

auto bitstream_iterator::operator->() const noexcept -> pointer {
    return static_cast<std::uint8_t*>(m_bits) + (m_index / BITS);
}

bitstream_iterator::operator bool() const noexcept {
    return (nullptr != m_bits);
}

bool bitstream_iterator::operator<(
        const bitstream_iterator& other) const noexcept {
    return (m_index < other.m_index);
}

bool bitstream_iterator::operator<=(
        const bitstream_iterator& other) const noexcept {
    return (m_index <= other.m_index);
}

bool bitstream_iterator::operator>(
        const bitstream_iterator& other) const noexcept {
    return (m_index > other.m_index);
}

bool bitstream_iterator::operator>=(
        const bitstream_iterator& other) const noexcept {
    return (m_index >= other.m_index);
}

bool bitstream_iterator::operator==(
        const bitstream_iterator& other) const noexcept {
    return (m_index == other.m_index);
}

bool bitstream_iterator::operator!=(
        const bitstream_iterator& other) const noexcept {
    return (m_index != other.m_index);
}

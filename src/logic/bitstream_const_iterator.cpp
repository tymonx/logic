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

#include "logic/bitstream_const_iterator.hpp"

using logic::bitstream_const_iterator;

bitstream_const_iterator::bitstream_const_iterator(
        const bitstream_iterator& other) noexcept :
    m_iterator{other}
{ }

bitstream_const_iterator::bitstream_const_iterator(pointer bits) noexcept :
    m_iterator{const_cast<bitstream_iterator::pointer>(bits)}
{ }

bitstream_const_iterator::bitstream_const_iterator(pointer bits,
        size_type index) noexcept :
    m_iterator{const_cast<bitstream_iterator::pointer>(bits), index}
{ }

bitstream_const_iterator::bitstream_const_iterator(pointer bits,
        difference_type index) noexcept :
    m_iterator{const_cast<bitstream_iterator::pointer>(bits), index}
{ }

auto bitstream_const_iterator::operator++() noexcept
        -> bitstream_const_iterator& {
    ++m_iterator;
    return *this;
}

auto bitstream_const_iterator::operator++(int) noexcept
        -> const bitstream_const_iterator {
    return bitstream_const_iterator{m_iterator++};
}

auto bitstream_const_iterator::operator--() noexcept
        -> bitstream_const_iterator& {
    --m_iterator;
    return *this;
}

auto bitstream_const_iterator::operator--(int) noexcept
        -> const bitstream_const_iterator {
    return bitstream_const_iterator{m_iterator--};
}

auto bitstream_const_iterator::operator+(
        difference_type n) const noexcept -> bitstream_const_iterator {
    return bitstream_const_iterator{m_iterator + n};
}

auto bitstream_const_iterator::operator+=(
        difference_type n) noexcept -> bitstream_const_iterator& {
    m_iterator += n;
    return *this;
}

auto bitstream_const_iterator::operator-(
        difference_type n) const noexcept -> bitstream_const_iterator {
    return bitstream_const_iterator{m_iterator - n};
}

auto bitstream_const_iterator::operator-=(
        difference_type n) noexcept -> bitstream_const_iterator& {
    m_iterator -= n;
    return *this;
}

auto bitstream_const_iterator::operator[](
        difference_type n) noexcept -> reference {
    return reference{m_iterator[n]};
}

auto bitstream_const_iterator::operator[](
        difference_type n) const noexcept -> reference {
    return reference{m_iterator[n]};
}

auto bitstream_const_iterator::operator*() noexcept -> reference {
    return reference{*m_iterator};
}

auto bitstream_const_iterator::operator*() const noexcept -> reference {
    return reference{*m_iterator};
}

auto bitstream_const_iterator::operator->() noexcept -> pointer {
    return m_iterator.operator->();
}

auto bitstream_const_iterator::operator->() const noexcept -> pointer {
    return m_iterator.operator->();
}

bitstream_const_iterator::operator bool() const noexcept {
    return m_iterator.operator bool();
}

bool bitstream_const_iterator::operator<(
        const bitstream_const_iterator& other) const noexcept {
    return m_iterator < other.m_iterator;
}

bool bitstream_const_iterator::operator<=(
        const bitstream_const_iterator& other) const noexcept {
    return m_iterator <= other.m_iterator;
}

bool bitstream_const_iterator::operator>(
        const bitstream_const_iterator& other) const noexcept {
    return m_iterator > other.m_iterator;
}

bool bitstream_const_iterator::operator>=(
        const bitstream_const_iterator& other) const noexcept {
    return m_iterator >= other.m_iterator;
}

bool bitstream_const_iterator::operator==(
        const bitstream_const_iterator& other) const noexcept {
    return m_iterator == other.m_iterator;
}

bool bitstream_const_iterator::operator!=(
        const bitstream_const_iterator& other) const noexcept {
    return m_iterator != other.m_iterator;
}

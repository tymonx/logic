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

#include "logic/bitstream.hpp"

#include <algorithm>

using logic::bitstream;
using size_type = bitstream::size_type;

static constexpr size_type BITS = 8;
static constexpr size_type OFFSET = BITS - 1;

static size_type size(size_type bits) noexcept {
    return ((bits + OFFSET) / BITS);
}

static void copy_n(const void* src, size_type n, void* dst) noexcept {
    std::copy_n(static_cast<const std::uint8_t*>(src), n,
            static_cast<std::uint8_t*>(dst));
}

static void fill_n(void* dst, size_type n, std::uint8_t val) noexcept {
    std::fill_n(static_cast<std::uint8_t*>(dst), n, val);
}

bitstream::bitstream() noexcept :
    m_bits{nullptr},
    m_size{0}
{ }

bitstream::bitstream(size_type n) :
    m_bits{new std::uint8_t[::size(n)] {}},
    m_size{n}
{ }

bitstream::bitstream(bitstream&& other) noexcept :
    m_bits{other.m_bits},
    m_size{other.m_size}
{
    other.m_bits = nullptr;
    other.m_size = 0;
}

bitstream::bitstream(const bitstream& other) :
    m_bits{new std::uint8_t[::size(other.m_size)]},
    m_size{other.m_size}
{
    ::copy_n(other.m_bits, ::size(m_size), m_bits);
}

auto bitstream::operator=(bitstream&& other) noexcept -> bitstream& {
    if (this != &other) {
        delete [] static_cast<std::uint8_t*>(m_bits);

        m_bits = other.m_bits;
        m_size = other.m_size;

        other.m_bits = nullptr;
        other.m_size = 0;
    }
    return *this;
}

auto bitstream::operator=(const bitstream& other) -> bitstream& {
    if (this != &other) {
        auto bits = new std::uint8_t[::size(other.m_size)];
        delete [] static_cast<std::uint8_t*>(m_bits);

        m_bits = bits;
        m_size = other.m_size;
        ::copy_n(other.m_bits, ::size(m_size), m_bits);
    }
    return *this;
}

auto bitstream::size(size_type n) -> bitstream& {
    resize(n);
    return *this;
}

auto bitstream::size() const noexcept -> size_type {
    return m_size;
}

auto bitstream::resize(size_type val) -> bitstream& {
    if (m_size != val) {
        auto bits = new std::uint8_t[::size(val)] {};
        ::copy_n(m_bits, ::size(std::min(m_size, val)), bits);
        delete [] static_cast<std::uint8_t*>(m_bits);
        m_bits = bits;
        m_size = val;
    }
    return *this;
}

auto bitstream::clear() -> bitstream& {
    ::fill_n(m_bits, ::size(m_size), 0);
    return *this;
}

auto bitstream::data() noexcept -> pointer {
    return m_bits;
}

auto bitstream::data() const noexcept -> const_pointer {
    return m_bits;
}

auto bitstream::begin() noexcept -> iterator {
    return iterator{m_bits};
}

auto bitstream::begin() const noexcept -> const_iterator {
    return const_iterator{m_bits};
}

auto bitstream::cbegin() const noexcept -> const_iterator {
    return const_iterator{m_bits};
}

auto bitstream::end() noexcept -> iterator {
    return {m_bits, m_size};
}

auto bitstream::end() const noexcept -> const_iterator {
    return {m_bits, m_size};
}

auto bitstream::cend() const noexcept -> const_iterator {
    return {m_bits, m_size};
}

auto bitstream::rbegin() noexcept -> reverse_iterator {
    return reverse_iterator{iterator{m_bits, m_size - 1}};
}

auto bitstream::rbegin() const noexcept -> const_reverse_iterator {
    return const_reverse_iterator{const_iterator{m_bits, m_size - 1}};
}

auto bitstream::crbegin() const noexcept -> const_reverse_iterator {
    return const_reverse_iterator{const_iterator{m_bits, m_size - 1}};
}

auto bitstream::rend() noexcept -> reverse_iterator {
    return reverse_iterator{iterator{m_bits,
        iterator::difference_type(-1)}};
}

auto bitstream::rend() const noexcept -> const_reverse_iterator {
    return const_reverse_iterator{const_iterator{m_bits,
        const_iterator::difference_type(-1)}};
}

auto bitstream::crend() const noexcept -> const_reverse_iterator {
    return const_reverse_iterator{const_iterator{m_bits,
        const_iterator::difference_type(-1)}};
}

auto bitstream::operator[](size_type index) noexcept -> reference {
    return {m_bits, index};
}

auto bitstream::operator[](size_type index) const noexcept -> const_reference {
    return {m_bits, index};
}

auto bitstream::assign(std::uintmax_t val) noexcept -> bitstream& {
    return assign(val, 8 * sizeof(std::uintmax_t));
}

auto bitstream::assign(std::uintmax_t val,
        size_type bits) noexcept -> bitstream& {
    auto byte = static_cast<std::uint8_t*>(m_bits);

    if (m_size < bits) {
        bits = m_size;
    }

    while (bits >= 8) {
         *byte++ = std::uint8_t(val);
        val >>= 8;
        bits -= 8;
    }

    if (bool(bits)) {
        auto mask = std::uint8_t(~(0xFF << bits));
        *byte &= std::uint8_t(~mask);
        *byte |= (mask & std::uint8_t(val));
    }

    return *this;
}

auto bitstream::assign(const void* src) noexcept -> bitstream& {
    return assign(src, m_size);
}

auto bitstream::assign(const void* src, size_type bits) noexcept -> bitstream& {
    if (m_size < bits) {
        bits = m_size;
    }

    ::copy_n(src, bits / BITS, m_bits);

    bits %= BITS;

    if (bits > 0) {
        auto byte = static_cast<std::uint8_t*>(m_bits);
        auto mask = std::uint8_t(~(0xFF << bits));

        *byte &= std::uint8_t(~mask);
        *byte |= (mask & *static_cast<const std::uint8_t*>(src));
    }

    return *this;
}

auto bitstream::value() const noexcept -> std::uintmax_t {
    return value(8 * sizeof(std::uintmax_t));
}

auto bitstream::value(size_type bits) const noexcept -> std::uintmax_t {
    auto byte = static_cast<const std::uint8_t*>(m_bits);
    size_type offset = 0;
    std::uintmax_t val = 0;

    if (m_size < bits) {
        bits = m_size;
    }

    while (bits >= 8) {
        val |= (std::uintmax_t(*byte++) << offset);
        offset += 8;
        bits -= 8;
    }

    if (bits > 0) {
        auto mask = std::uint8_t(~(0xFF << bits));
        val |= (std::uintmax_t(mask & *byte++) << offset);
    }

    return val;
}

auto bitstream::copy(void* dst) const noexcept -> const bitstream& {
    return copy(dst, m_size);
}

auto bitstream::copy(void* dst,
        size_type bits) const noexcept -> const bitstream& {
    if (m_size < bits) {
        bits = m_size;
    }

    ::copy_n(m_bits, bits / BITS, dst);

    bits %= BITS;

    if (bits > 0) {
        auto byte = static_cast<std::uint8_t*>(dst);
        auto mask = std::uint8_t(~(0xFF << bits));

        *byte &= std::uint8_t(~mask);
        *byte |= (mask & *static_cast<const std::uint8_t*>(m_bits));
    }

    return *this;
}

auto bitstream::operator=(bool val) noexcept -> bitstream& {
    if (m_size > 0) {
        auto byte = static_cast<std::uint8_t*>(m_bits);

        if (val) {
            *byte |= 0x01;
        }
        else {
            *byte &= 0xFE;
        }
    }
    return *this;
}

bitstream::operator bool() const noexcept {
    auto byte = static_cast<const std::uint8_t*>(m_bits);
    return ((m_size > 0) && (0x01 == (*byte & 0x01)));
}

auto bitstream::operator==(const bitstream& other) const noexcept -> bool {
    auto first = static_cast<const std::uint8_t*>(m_bits);
    auto second = static_cast<const std::uint8_t*>(other.m_bits);
    auto bytes = ::size(std::min(m_size, other.m_size));

    auto result = std::equal(first, first + bytes, second);

    if (result) {
        auto it = (m_size < other.m_size) ? second : first;
        auto total_bytes = ::size(std::max(m_size, other.m_size));

        result = std::all_of(it + bytes, it + total_bytes,
            [] (const std::uint8_t& val) {
                return (0 == val);
            }
        );
    }

    return result;
}

auto bitstream::operator!=(const bitstream& other) const noexcept -> bool {
    return !(*this == other);
}

auto bitstream::operator<(const bitstream& /* other */) const noexcept -> bool {
    /* TODO: Implement < */
    return false;
}

auto bitstream::operator>(const bitstream& other) const noexcept -> bool {
    return (other < *this);
}

auto bitstream::operator<=(const bitstream& other) const noexcept -> bool {
    return !(other < *this);
}

auto bitstream::operator>=(const bitstream& other) const noexcept -> bool {
    return !(*this <  other);
}

bitstream::~bitstream() {
    delete [] static_cast<std::uint8_t*>(m_bits);
}

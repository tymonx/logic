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

#ifndef LOGIC_BITSTREAM_ITERATOR_HPP
#define LOGIC_BITSTREAM_ITERATOR_HPP

#include "bitstream_reference.hpp"

#include <cstddef>
#include <iterator>

namespace logic {

class bitstream_iterator {
public:
    using value_type = bool;
    using size_type = std::size_t;
    using pointer = void*;
    using difference_type = std::ptrdiff_t;
    using reference = bitstream_reference;
    using iterator_category = std::random_access_iterator_tag;

    explicit bitstream_iterator(pointer bits) noexcept;

    bitstream_iterator(pointer bits, size_type index) noexcept;

    bitstream_iterator(pointer bits, difference_type index) noexcept;

    bitstream_iterator(bitstream_iterator&& other) noexcept = default;

    bitstream_iterator(const bitstream_iterator& other) noexcept = default;

    bitstream_iterator& operator=(
            bitstream_iterator&& other) noexcept = default;

    bitstream_iterator& operator=(
            const bitstream_iterator& other) noexcept = default;

    bitstream_iterator& operator++() noexcept;

    const bitstream_iterator operator++(int) noexcept;

    bitstream_iterator& operator--() noexcept;

    const bitstream_iterator operator--(int) noexcept;

    bitstream_iterator operator+(difference_type n) const noexcept;

    bitstream_iterator& operator+=(difference_type n) noexcept;

    bitstream_iterator operator-(difference_type n) const noexcept;

    bitstream_iterator& operator-=(difference_type n) noexcept;

    reference operator[](difference_type n) noexcept;

    reference operator[](difference_type n) const noexcept;

    reference operator*() noexcept;

    reference operator*() const noexcept;

    pointer operator->() noexcept;

    pointer operator->() const noexcept;

    explicit operator bool() const noexcept;

    bool operator<(const bitstream_iterator& other) const noexcept;

    bool operator<=(const bitstream_iterator& other) const noexcept;

    bool operator>(const bitstream_iterator& other) const noexcept;

    bool operator>=(const bitstream_iterator& other) const noexcept;

    bool operator==(const bitstream_iterator& other) const noexcept;

    bool operator!=(const bitstream_iterator& other) const noexcept;

    ~bitstream_iterator() = default;
private:
    pointer m_bits;
    difference_type m_index;
};

} /* namespace logic */

#endif /* LOGIC_BITSTREAM_ITERATOR_HPP */

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

#ifndef LOGIC_BITSTREAM_CONST_ITERATOR_HPP
#define LOGIC_BITSTREAM_CONST_ITERATOR_HPP

#include "bitstream_const_reference.hpp"
#include "bitstream_iterator.hpp"

namespace logic {

class bitstream_const_iterator {
public:
    using value_type = bool;
    using size_type = std::size_t;
    using pointer = const void*;
    using difference_type = std::ptrdiff_t;
    using reference = bitstream_const_reference;
    using iterator_category = std::random_access_iterator_tag;

    explicit bitstream_const_iterator(const bitstream_iterator& other) noexcept;

    explicit bitstream_const_iterator(pointer bits) noexcept;

    bitstream_const_iterator(pointer bits, size_type index) noexcept;

    bitstream_const_iterator(pointer bits, difference_type index) noexcept;

    bitstream_const_iterator(
            bitstream_const_iterator&& other) noexcept = default;

    bitstream_const_iterator(
            const bitstream_const_iterator& other) noexcept = default;

    bitstream_const_iterator& operator=(
            bitstream_const_iterator&& other) noexcept = default;

    bitstream_const_iterator& operator=(
            const bitstream_const_iterator& other) noexcept = default;

    bitstream_const_iterator& operator++() noexcept;

    const bitstream_const_iterator operator++(int) noexcept;

    bitstream_const_iterator& operator--() noexcept;

    const bitstream_const_iterator operator--(int) noexcept;

    bitstream_const_iterator operator+(difference_type n) const noexcept;

    bitstream_const_iterator& operator+=(difference_type n) noexcept;

    bitstream_const_iterator operator-(difference_type n) const noexcept;

    bitstream_const_iterator& operator-=(difference_type n) noexcept;

    reference operator[](difference_type n) noexcept;

    reference operator[](difference_type n) const noexcept;

    reference operator*() noexcept;

    reference operator*() const noexcept;

    pointer operator->() noexcept;

    pointer operator->() const noexcept;

    explicit operator bool() const noexcept;

    bool operator<(const bitstream_const_iterator& other) const noexcept;

    bool operator<=(const bitstream_const_iterator& other) const noexcept;

    bool operator>(const bitstream_const_iterator& other) const noexcept;

    bool operator>=(const bitstream_const_iterator& other) const noexcept;

    bool operator==(const bitstream_const_iterator& other) const noexcept;

    bool operator!=(const bitstream_const_iterator& other) const noexcept;

    ~bitstream_const_iterator() = default;
private:
    bitstream_iterator m_iterator;
};

} /* namespace logic */

#endif /* LOGIC_BITSTREAM_CONST_ITERATOR_HPP */

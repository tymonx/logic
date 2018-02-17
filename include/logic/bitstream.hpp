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

#ifndef LOGIC_BITSTREAM_HPP
#define LOGIC_BITSTREAM_HPP

#include "bitstream_const_iterator.hpp"
#include "bitstream_const_reference.hpp"
#include "bitstream_iterator.hpp"
#include "bitstream_reference.hpp"

#include <cstddef>
#include <cstdint>
#include <iterator>
#include <type_traits>

namespace logic {

/* Class: logic::bitstream
 *
 * Class for bit manipulation
 */
class bitstream {
public:
    /* Types: Member Types
     *
     * value_type       - Boolean type.
     * size_type        - Unsigned integer type for any size operations.
     * difference_type  - Signed integer type for iterators.
     * reference        - Bit reference type for write and read operations.
     * const_reference  - Bit reference type only for read operations.
     * iterator         - Bit iterator type for write and read operations.
     * const_iterator   - Bit iterator type only for read operations.
     */
    using value_type = bool;
    using size_type = std::size_t;
    using difference_type = std::ptrdiff_t;
    using pointer = void*;
    using const_pointer = const void*;
    using reference = bitstream_reference;
    using const_reference = bitstream_const_reference;
    using iterator = bitstream_iterator;
    using const_iterator = bitstream_const_iterator;
    using reverse_iterator = std::reverse_iterator<iterator>;
    using const_reverse_iterator = std::reverse_iterator<const_iterator>;

    template<typename T>
    using enable_integral = typename std::enable_if<
            std::is_integral<T>::value, int>::type;

    template<typename T>
    using enable_enum = typename std::enable_if<
            std::is_enum<T>::value, unsigned>::type;

    template<typename T>
    using enable_class = typename std::enable_if<
            std::is_class<T>::value, char>::type;

    /* ----------------------------------------------------------------------
     * Group: Constructors
     * ---------------------------------------------------------------------- */

    /* Constructor: bitstream
     *
     * Default constructor. Creates an empty bit stream object that cannot store
     * any bits.
     */
    bitstream() noexcept;

    /* Constructor: bitstream
     *
     * Creates a bit stream object that can store n bits. All bits are
     * initialized with zero.
     *
     * Parameters:
     *  n - Bits width.
     */
    explicit bitstream(size_type n);

    /* Constructor: bitstream
     *
     * Move constructor. The other bit stream object will be as created with
     * default constructor.
     *
     * Parameters:
     *  other - Other bit stream object to move.
     */
    bitstream(bitstream&& other) noexcept;

    /* Constructor: bitstream
     *
     * Copy constructor.
     *
     * Parameters:
     *  other - Other bit stream object to copy.
     */
    bitstream(const bitstream& other);

    /* ----------------------------------------------------------------------
     * Group: Assignment Operators
     * ---------------------------------------------------------------------- */

    /* Method: operator=
     *
     * Move assignment. The other bit stream object will be as created with
     * default constructor.
     *
     * Parameters:
     *  other - Other bit stream object to move.
     *
     * Returns:
     *  *this
     */
    bitstream& operator=(bitstream&& other) noexcept;

    /* Method: operator=
     *
     * Copy assignment.
     *
     * Parameters:
     *  other - Other bit stream object to copy.
     *
     * Returns:
     *  *this
     */
    bitstream& operator=(const bitstream& other);

    /* ----------------------------------------------------------------------
     * Group: Capacity
     * ---------------------------------------------------------------------- */

    /* Method: size
     *
     * Change bit stream width.
     *
     * Parameters:
     *  n - New bits width.
     *
     * Returns:
     *  *this
     *
     * See Also:
     *  <resize>
     */
    bitstream& size(size_type n);

    /* Method: size
     *
     * Get bit stream width.
     *
     * Returns:
     *  Bit stream width.
     */
    size_type size() const noexcept;

    /* Method: resize
     *
     * Change bit stream width.
     *
     * Parameters:
     *  n - New bits width.
     *
     * Returns:
     *  *this
     */
    bitstream& resize(size_type n);

    /* ----------------------------------------------------------------------
     * Group: Modifiers
     * ---------------------------------------------------------------------- */

    /* Method: clear
     *
     * Clear all bits.
     *
     * Returns:
     *  *this
     */
    bitstream& clear();

    pointer data() noexcept;

    const_pointer data() const noexcept;

    iterator begin() noexcept;

    const_iterator begin() const noexcept;

    const_iterator cbegin() const noexcept;

    reverse_iterator rbegin() noexcept;

    const_reverse_iterator rbegin() const noexcept;

    const_reverse_iterator crbegin() const noexcept;

    iterator end() noexcept;

    const_iterator end() const noexcept;

    const_iterator cend() const noexcept;

    reverse_iterator rend() noexcept;

    const_reverse_iterator rend() const noexcept;

    const_reverse_iterator crend() const noexcept;

    reference operator[](size_type index) noexcept;

    const_reference operator[](size_type index) const noexcept;

    bitstream& assign(std::uintmax_t val) noexcept;

    bitstream& assign(std::uintmax_t val, size_type bits) noexcept;

    bitstream& assign(const void* src) noexcept;

    bitstream& assign(const void* src, size_type bits) noexcept;

    template<typename T>
    bitstream& assign(const T& src) noexcept;

    template<typename T>
    bitstream& assign(const T& src, size_type bits) noexcept;

    std::uintmax_t value() const noexcept;

    std::uintmax_t value(size_type bits) const noexcept;

    const bitstream& copy(void* dst) const noexcept;

    const bitstream& copy(void* dst, size_type bits) const noexcept;

    template<typename T>
    const bitstream& copy(T& dst) const noexcept;

    template<typename T>
    const bitstream& copy(T& dst, size_type bits) const noexcept;

    bitstream& operator=(bool val) noexcept;

    template<typename T, enable_integral<T> = 0>
    bitstream& operator=(T val) noexcept;

    template<typename T, enable_enum<T> = 0>
    bitstream& operator=(T val) noexcept;

    template<typename T, enable_class<T> = 0>
    bitstream& operator=(const T& val) noexcept;

    explicit operator bool() const noexcept;

    template<typename T, enable_integral<T> = 0>
    explicit operator T() const noexcept;

    template<typename T, enable_enum<T> = 0>
    explicit operator T() const noexcept;

    template<typename T, enable_class<T> = 0>
    explicit operator T&() noexcept;

    template<typename T, enable_class<T> = 0>
    explicit operator const T&() const noexcept;

    bool operator==(const bitstream& other) const noexcept;

    bool operator!=(const bitstream& other) const noexcept;

    bool operator<(const bitstream& other) const noexcept;

    bool operator>(const bitstream& other) const noexcept;

    bool operator<=(const bitstream& other) const noexcept;

    bool operator>=(const bitstream& other) const noexcept;

    ~bitstream();
private:
    pointer m_bits;
    size_type m_size;
};

template<typename T> auto
bitstream::assign(const T& src) noexcept -> bitstream& {
    return assign(static_cast<const void*>(&src), 8 * sizeof(T));
}

template<typename T> auto
bitstream::assign(const T& src, size_type bits) noexcept -> bitstream& {
    return assign(static_cast<const void*>(&src), bits);
}

template<typename T> auto
bitstream::copy(T& dst) const noexcept -> const bitstream& {
    return copy(static_cast<void*>(&dst), 8 * sizeof(T));
}

template<typename T> auto
bitstream::copy(T& dst, size_type bits) const noexcept -> const bitstream& {
    return copy(static_cast<void*>(&dst), bits);
}

template<typename T, bitstream::enable_integral<T>>
auto bitstream::operator=(T val) noexcept -> bitstream& {
    return assign(std::uintmax_t(val), 8 * sizeof(T));
}

template<typename T, bitstream::enable_enum<T>>
auto bitstream::operator=(T val) noexcept -> bitstream& {
    return assign(std::uintmax_t(val), 8 * sizeof(T));
}

template<typename T, bitstream::enable_class<T>>
auto bitstream::operator=(const T& val) noexcept -> bitstream& {
    return assign(static_cast<const void*>(&val), 8 * sizeof(T));
}

template<typename T, bitstream::enable_integral<T>>
bitstream::operator T() const noexcept {
    return T(value(8 * sizeof(T)));
}

template<typename T, bitstream::enable_enum<T>>
bitstream::operator T() const noexcept {
    return T(value(8 * sizeof(T)));
}

template<typename T, bitstream::enable_class<T>>
bitstream::operator T&() noexcept {
    return *static_cast<T*>(data());
}

template<typename T, bitstream::enable_class<T>>
bitstream::operator const T&() const noexcept {
    return *static_cast<const T*>(data());
}

template<typename T, bitstream::enable_class<T>> static inline auto
get(bitstream& bits) noexcept -> T& {
    return *static_cast<T*>(bits.data());
}

template<typename T, bitstream::enable_class<T>> static inline auto
get(const bitstream& bits) noexcept -> const T& {
    return *static_cast<const T*>(bits.data());
}

} /* namespace logic */

#endif /* LOGIC_BITSTREAM_HPP */

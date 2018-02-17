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

#ifndef LOGIC_BITSTREAM_CONST_REFERENCE_HPP
#define LOGIC_BITSTREAM_CONST_REFERENCE_HPP

#include "bitstream_reference.hpp"

namespace logic {

class bitstream_const_reference {
public:
    using size_type = std::size_t;
    using const_pointer = const void*;

    explicit bitstream_const_reference(
            const bitstream_reference& other) noexcept;

    bitstream_const_reference(const_pointer bits, size_type index) noexcept;

    bitstream_const_reference(
            bitstream_const_reference&& other) noexcept = default;

    bitstream_const_reference(
            const bitstream_const_reference& other) noexcept = default;

    bitstream_const_reference& operator=(
            bitstream_const_reference&& other) noexcept = default;

    bitstream_const_reference& operator=(
            const bitstream_const_reference& other) noexcept = default;

    explicit operator bool() const noexcept;

    ~bitstream_const_reference() = default;
private:
    bitstream_reference m_reference;
};

} /* namespace logic */

#endif /* LOGIC_BITSTREAM_CONST_REFERENCE_HPP */

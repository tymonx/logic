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

#ifndef LOGIC_AXI4_STREAM_TDATA_BYTE_HPP
#define LOGIC_AXI4_STREAM_TDATA_BYTE_HPP

#include <cstdint>
#include <type_traits>
#include <utility>

namespace logic {
namespace axi4 {
namespace stream {

class tdata_byte {
public:
    template<typename T>
    using enable_integral = typename std::enable_if<
            std::is_integral<T>::value,
        int>::type;

    enum type_t {
        DATA_BYTE,
        NULL_BYTE,
        POSITION_BYTE,
        RESERVED
    };

    tdata_byte() noexcept;

    explicit tdata_byte(std::uint8_t data_val) noexcept;

    explicit tdata_byte(type_t type_val) noexcept;

    tdata_byte(std::uint8_t data_val, type_t type_val) noexcept;

    explicit tdata_byte(const std::pair<std::uint8_t, type_t>& value) noexcept;

    tdata_byte& operator=(std::uint8_t data_val) noexcept;

    tdata_byte& operator=(const std::pair<std::uint8_t, type_t>&) noexcept;

    tdata_byte& data(std::uint8_t data_val) noexcept;

    std::uint8_t data() const noexcept;

    tdata_byte& type(type_t type_val) noexcept;

    type_t type() const noexcept;

    template<typename T, enable_integral<T> = 0>
    explicit operator T() const noexcept;

    explicit operator type_t() const noexcept;

    explicit operator bool() const noexcept;

    bool operator!() const noexcept;

    bool is_data_byte() const noexcept;

    bool is_null_byte() const noexcept;

    bool is_position_byte() const noexcept;

    bool is_reserved() const noexcept;

    bool operator==(const tdata_byte& other) const noexcept;

    bool operator!=(const tdata_byte& other) const noexcept;

    bool operator<(const tdata_byte& other) const noexcept;

    bool operator<=(const tdata_byte& other) const noexcept;

    bool operator>(const tdata_byte& other) const noexcept;

    bool operator>=(const tdata_byte& other) const noexcept;

    tdata_byte(tdata_byte&&) noexcept = default;

    tdata_byte(const tdata_byte&) noexcept = default;

    tdata_byte& operator=(tdata_byte&&) noexcept = default;

    tdata_byte& operator=(const tdata_byte&) noexcept = default;

    ~tdata_byte() noexcept = default;
private:
    type_t m_type;
    std::uint8_t m_data;
};

template<typename T, tdata_byte::enable_integral<T>>
tdata_byte::operator T() const noexcept {
    return T(data());
}

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

namespace uvm {

class uvm_packer;

uvm_packer& operator<<(uvm_packer& packer,
        const logic::axi4::stream::tdata_byte& value);

uvm_packer& operator>>(uvm_packer& packer,
        logic::axi4::stream::tdata_byte& value);

} /* namespace uvm */

#endif /* LOGIC_AXI4_STREAM_TDATA_BYTE_HPP */

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

#ifndef LOGIC_UTILS_HPP
#define LOGIC_UTILS_HPP

#include <systemc>

#include <cstdint>
#include <type_traits>

namespace logic {
namespace utils {
    template<typename T>
    using enable_integral = typename std::enable_if<
        std::is_integral<T>::value, int>::type;

    template<std::size_t N, typename T>
    using enable_systemc_types = typename std::enable_if<
        std::is_same<T, sc_dt::sc_bv<int(N)>>::value ||
        std::is_same<T, sc_dt::sc_lv<int(N)>>::value ||
        std::is_same<T, sc_dt::sc_int<int(N)>>::value ||
        std::is_same<T, sc_dt::sc_uint<int(N)>>::value ||
        std::is_same<T, sc_dt::sc_bigint<int(N)>>::value ||
        std::is_same<T, sc_dt::sc_biguint<int(N)>>::value, unsigned>::type;

    template<std::size_t N, typename T, enable_integral<T> = 0>
    static inline void set(T& lhs, std::size_t offset,
            std::uint8_t rhs) noexcept {
        lhs &= (~(T(0xFF) << offset));
        lhs |= (T(rhs) << offset);
    }

    template<std::size_t N, typename T, enable_integral<T> = 0>
    static inline void set(T& lhs, std::size_t offset, bool rhs) noexcept {
        lhs &= ~(T(1u) << offset);
        lhs |= (T(!!rhs) << offset);
    }

    template<std::size_t N, typename T, enable_systemc_types<N, T> = 0>
    static inline void set(T& lhs, std::size_t offset,
            std::uint8_t rhs) noexcept {
        lhs(int(offset + 7u), int(offset)) = unsigned(rhs);
    }

    template<std::size_t N, typename T, enable_systemc_types<N, T> = 0>
    static inline void set(T& lhs, std::size_t offset, bool rhs) noexcept {
        lhs[offset] = rhs;
    }

    template<std::size_t N, typename T, enable_integral<T> = 0>
    static inline bool get_bool(const T& lhs, std::size_t offset) noexcept {
        return !!(lhs & (1u << offset));
    }

    template<std::size_t N, typename T, enable_integral<T> = 0>
    static inline std::uint8_t get_uint8(const T& lhs,
            std::size_t offset) noexcept {
        return std::uint8_t(lhs >> offset);
    }

    template<std::size_t N, typename T, enable_systemc_types<N, T> = 0>
    static inline bool get_bool(const T& lhs, std::size_t offset) noexcept {
        return lhs[offset].to_bool();
    }

    template<std::size_t N, typename T, enable_systemc_types<N, T> = 0>
    static inline std::uint8_t get_uint8(const T& lhs,
            std::size_t offset) noexcept {
        return std::uint8_t(lhs(int(offset + 7u), int(offset)).to_uint());
    }

    template<std::size_t T> struct bits_helper {
        using type = sc_dt::sc_bv<int(T)>;
    };

    template<> struct bits_helper<0> {
        /* Nothing */
    };

    template<> struct bits_helper<1> {
        using type = bool;
    };

    template<> struct bits_helper<32> {
        using type = std::uint32_t;
    };

    template<> struct bits_helper<64> {
        using type = std::uint64_t;
    };

    template<std::size_t N> struct bits {
        using type = typename bits_helper<
            (N == 0) ? 0 :
            (N == 1) ? 1 :
            (N <= 32) ? 32 :
            (N <= 64) ? 64 : N>::type;
    };
} /* namespace utils */
} /* namespace logic */

#endif /* LOGIC_UTILS_HPP */

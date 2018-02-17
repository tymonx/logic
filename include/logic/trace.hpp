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

#ifndef LOGIC_TRACE_HPP
#define LOGIC_TRACE_HPP

#include "trace_systemc.hpp"
#include "trace_verilated.hpp"

#include <cstddef>
#include <limits>
#include <type_traits>

namespace logic {

template<typename T, typename enable = void>
class trace final : public trace_systemc {
public:
    explicit trace(T& module, const std::string& filename = {},
            std::size_t level = std::numeric_limits<std::size_t>::max()) :
        trace_systemc{module, filename, level}
    { }

    trace(trace&&) = delete;

    trace(const trace&) = delete;

    trace& operator=(trace&&) = delete;

    trace& operator=(const trace&) = delete;

    ~trace() override = default;
};

template<typename T>
class trace<T, typename std::enable_if<has_verilated_vcd_trace_method<T>::value
    >::type> final : public trace_verilated {
public:
    explicit trace(T& module, const std::string& filename = {},
            std::size_t level = std::numeric_limits<std::size_t>::max()) :
        trace_verilated{module, filename, level}
    { }

    trace(trace&&) = delete;

    trace(const trace&) = delete;

    trace& operator=(trace&&) = delete;

    trace& operator=(const trace&) = delete;

    ~trace() override = default;
};

} /* namespace logic */

#endif /* LOGIC_TRACE_HPP */

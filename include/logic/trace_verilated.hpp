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

#ifndef LOGIC_TRACE_VERILATED_HPP
#define LOGIC_TRACE_VERILATED_HPP

#include "trace_base.hpp"

#include <systemc>

#include <cstddef>
#include <string>

class VerilatedVcdC;
class VerilatedVcdSc;

namespace logic {

template<typename T>
class has_verilated_vcd_trace_method {
private:
    template<typename C>
    static std::true_type test(void(C::*)(VerilatedVcdC*, int, int));

    template<typename C>
    static decltype(test(&C::trace)) test(std::nullptr_t);

    template<typename C>
    static std::false_type test(...);
public:
    has_verilated_vcd_trace_method() = delete;

    using type = decltype(test<T>(nullptr));
    static const bool value = type::value;
};

class trace_verilated : public trace_base {
public:
    trace_verilated(const trace_verilated&) = delete;

    trace_verilated& operator=(const trace_verilated&) = delete;

    trace_verilated(trace_verilated&&) = delete;

    trace_verilated& operator=(trace_verilated&&) = delete;
protected:
    template<typename T>
    trace_verilated(T& object, const std::string& filename,
            std::size_t level);

    ~trace_verilated() override;
private:
    trace_verilated(const std::string& name, const std::string& filename);

    void open();

    VerilatedVcdC* get(VerilatedVcdSc* verilated_vcd) const noexcept;

    VerilatedVcdSc* m_trace_file{nullptr};
    std::string m_filename{};
};

template<typename T>
trace_verilated::trace_verilated(T& object, const std::string& filename,
        std::size_t level) :
    trace_verilated{object.basename(), filename}
{
    object.trace(get(m_trace_file), int(level));
    open();
}

} /* namespace logic */

#endif /* LOGIC_TRACE_VERILATED_HPP */

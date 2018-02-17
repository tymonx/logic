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

#include "logic/trace_systemc.hpp"

#include <systemc>
#include <type_traits>

using logic::trace_systemc;

using sc_dt::sc_bv;
using sc_dt::sc_uint;
using sc_dt::sc_biguint;
using sc_core::sc_object;
using sc_core::sc_trace_file;

template<typename T, typename std::enable_if<std::is_class<T>::value,
    int>::type = 0>
static void trace_helper(sc_trace_file* trace_file, const sc_object* object) {
    auto ptr = dynamic_cast<const T*>(object);
    if (ptr) {
        sc_core::sc_trace(trace_file, *ptr, object->name());
    }
}

template<typename T, typename std::enable_if<!std::is_class<T>::value,
    unsigned>::type = 0>
static void trace_helper(sc_trace_file* /* trace_file*/,
        const sc_object* /* object */) { }

template<typename T>
static void trace(sc_trace_file* trace_file, const sc_object* object) {
    trace_helper<sc_core::sc_in<T>>(trace_file, object);
    trace_helper<sc_core::sc_out<T>>(trace_file, object);
    trace_helper<sc_core::sc_signal<T>>(trace_file, object);
    trace_helper<T>(trace_file, object);
}

static void trace(sc_trace_file* trace_file, const sc_object* object) {
    trace<bool>(trace_file, object);

    trace<std::int8_t>(trace_file, object);
    trace<std::int16_t>(trace_file, object);
    trace<std::int32_t>(trace_file, object);
    trace<std::int64_t>(trace_file, object);

    trace<std::uint8_t>(trace_file, object);
    trace<std::uint16_t>(trace_file, object);
    trace<std::uint32_t>(trace_file, object);
    trace<std::uint64_t>(trace_file, object);

    trace<sc_bv<1>>(trace_file, object);
    trace<sc_bv<2>>(trace_file, object);
    trace<sc_bv<4>>(trace_file, object);
    trace<sc_bv<8>>(trace_file, object);
    trace<sc_bv<16>>(trace_file, object);
    trace<sc_bv<32>>(trace_file, object);
    trace<sc_bv<64>>(trace_file, object);
    trace<sc_bv<128>>(trace_file, object);
    trace<sc_bv<256>>(trace_file, object);
    trace<sc_bv<512>>(trace_file, object);

    trace<sc_uint<1>>(trace_file, object);
    trace<sc_uint<2>>(trace_file, object);
    trace<sc_uint<4>>(trace_file, object);
    trace<sc_uint<8>>(trace_file, object);
    trace<sc_uint<16>>(trace_file, object);
    trace<sc_uint<32>>(trace_file, object);
    trace<sc_uint<64>>(trace_file, object);

    trace<sc_biguint<128>>(trace_file, object);
    trace<sc_biguint<256>>(trace_file, object);
    trace<sc_biguint<512>>(trace_file, object);
}

static void trace(sc_trace_file* trace_file, const sc_object* parent,
        std::size_t level) {
    if ((parent != nullptr) && (0 != level--)) {
        for (const auto& object : parent->get_child_objects()) {
            trace(trace_file, object);
            trace(trace_file, object, level);
        }
    }
}

trace_systemc::trace_systemc(const sc_object& object,
        const std::string& filename, std::size_t level) :
    m_trace_file{sc_core::sc_create_vcd_trace_file(
            filename.empty() ? object.basename() : filename.c_str())}
{
    trace(m_trace_file, &object, level);
}

trace_systemc::~trace_systemc() {
    sc_core::sc_close_vcd_trace_file(m_trace_file);
}

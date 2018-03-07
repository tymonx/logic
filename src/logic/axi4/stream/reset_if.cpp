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

#include "logic/axi4/stream/reset_if.hpp"

using logic::axi4::stream::reset_if;

reset_if::reset_if() :
    reset_if{""}
{ }

reset_if::reset_if(const sc_core::sc_module_name& module_name) :
    sc_core::sc_module{module_name},
    aclk{"aclk"},
    areset_n{"areset_n"}
{ }

void reset_if::trace(sc_core::sc_trace_file* trace_file) const {
    if (trace_file != nullptr) {
        sc_core::sc_trace(trace_file, aclk, aclk.name());
        sc_core::sc_trace(trace_file, areset_n, areset_n.name());
    }
}

void reset_if::set_areset_n(bool value) {
    areset_n.write(value);
}

void reset_if::aclk_posedge() {
    sc_core::wait(aclk.posedge_event());
}

reset_if::~reset_if() = default;

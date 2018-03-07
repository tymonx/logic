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

#include "logic/axi4/stream/bus_if_base.hpp"

using logic::axi4::stream::bus_if_base;

bus_if_base::bus_if_base(const sc_core::sc_module_name& module_name) :
    sc_core::sc_module{module_name},
    aclk{"aclk"},
    areset_n{"areset_n"},
    tvalid{"tvalid"},
    tready{"tready"},
    tlast{"tlast"}
{ }

void bus_if_base::trace(sc_core::sc_trace_file* trace_file) const {
    if (trace_file != nullptr) {
        sc_core::sc_trace(trace_file, aclk, aclk.name());
        sc_core::sc_trace(trace_file, areset_n, areset_n.name());
        sc_core::sc_trace(trace_file, tvalid, tvalid.name());
        sc_core::sc_trace(trace_file, tready, tready.name());
        sc_core::sc_trace(trace_file, tlast, tlast.name());
    }
}

void bus_if_base::aclk_posedge() {
    sc_core::wait(aclk.posedge_event());
}

bool bus_if_base::get_areset_n() const {
    return areset_n.read();
}

void bus_if_base::set_tvalid(bool value) {
    tvalid.write(value);
}

bool bus_if_base::get_tvalid() const {
    return tvalid.read();
}

void bus_if_base::set_tready(bool value) {
    tready.write(value);
}

bool bus_if_base::get_tready() const {
    return tready.read();
}

void bus_if_base::set_tlast(bool value) {
    tlast.write(value);
}

bool bus_if_base::get_tlast() const {
    return tlast.read();
}

bus_if_base::~bus_if_base() = default;

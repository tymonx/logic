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

#include "logic/trace_verilated.hpp"

#include <verilated.h>
#include <verilated_cov.h>
#include <verilated_vcd_c.h>
#include <verilated_vcd_sc.h>

using logic::trace_verilated;

trace_verilated::trace_verilated(const std::string& name,
        const std::string& filename) :
    m_trace_file{new VerilatedVcdSc},
    m_filename{filename.empty() ? name : filename}
{
    Verilated::traceEverOn(true);
}

trace_verilated::~trace_verilated() {
        m_trace_file->close();
        Verilated::traceEverOn(false);
        delete m_trace_file;
        VerilatedCov::write((m_filename + ".coverage").c_str());
}

auto trace_verilated::get(
        VerilatedVcdSc* verilated_vcd) const noexcept -> VerilatedVcdC* {
    return verilated_vcd;
}

void trace_verilated::open() {
    m_trace_file->open((m_filename + ".vcd").c_str());
}

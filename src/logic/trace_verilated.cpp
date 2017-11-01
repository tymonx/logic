/* Copyright 2017 Tymoteusz Blazejczyk
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
#include <verilated_vcd_sc.h>

#include <string>

using logic::trace_verilated;

using sc_core::sc_object;

trace_verilated::trace_verilated() :
    m_trace_file{new VerilatedVcdSc}
{
    Verilated::traceEverOn(true);
}

trace_verilated::~trace_verilated() {
        m_trace_file->close();
        Verilated::traceEverOn(false);
        delete m_trace_file;
}

void trace_verilated::open(const char* filename) {
    std::string vcd_filename{filename};
    auto pos = vcd_filename.rfind(".vcd");
    if ((std::string::npos == pos) || ((vcd_filename.size() - 4) != pos)) {
        vcd_filename += ".vcd";
    }
    m_trace_file->open(vcd_filename.c_str());
}

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

#include <systemc>
#include <verilated.h>

static void simulation_stop() {
    if (!Verilated::gotFinish()) {
        Verilated::flushCall();
        sc_core::sc_stop();
    }
    Verilated::gotFinish(true);
}

void vl_finish(const char* filename, int linenum,
        const char* /* hier */) VL_MT_UNSAFE {
    VL_PRINTF("- %s:%d: Verilog $finish\n", filename, linenum);
    simulation_stop();
}

void vl_stop(const char* filename, int linenum,
        const char* /* hier */) VL_MT_UNSAFE {
    VL_PRINTF("- %s:%d: Verilog $stop\n", filename, linenum);
    simulation_stop();
}

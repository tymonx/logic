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

#ifndef DUT_HPP
#define DUT_HPP

#include "logic_reset_synchronizer.h"

#include <logic/trace.hpp>
#include <systemc>

class dut {
public:
    sc_core::sc_clock aclk;
    sc_core::sc_signal<bool> areset_n;
    sc_core::sc_signal<bool> areset_n_synced;

    dut();
private:
    logic_reset_synchronizer m_dut;
    logic::trace<decltype(m_dut)> m_trace;
};

#endif /* DUT_HPP */

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

#include "dut.hpp"

dut::dut() :
    aclk{"aclk"},
    areset_n{"areset_n"},
    areset_n_synced{"areset_n_synced"},
    m_dut{"logic_reset_synchronizer"},
    m_trace{m_dut}
{
    m_dut.aclk(aclk);
    m_dut.areset_n(areset_n);
    m_dut.areset_n_synced(areset_n_synced);
}

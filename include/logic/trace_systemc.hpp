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

#ifndef LOGIC_TRACE_SYSTEMC_HPP
#define LOGIC_TRACE_SYSTEMC_HPP

#include "trace_base.hpp"

#include <systemc>

#include <cstddef>

namespace logic {

class trace_systemc : public trace_base {
protected:
    trace_systemc(const sc_core::sc_object& object,
            const char* filename, std::size_t level);

    virtual ~trace_systemc() override;
private:
    trace_systemc(const trace_systemc&) = delete;

    trace_systemc& operator=(const trace_systemc&) = delete;

    sc_core::sc_trace_file* m_trace_file{nullptr};
};

}

#endif /* LOGIC_TRACE_SYSTEMC_HPP */

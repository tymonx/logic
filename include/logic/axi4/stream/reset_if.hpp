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

#ifndef LOGIC_AXI4_STREAM_RESET_IF_HPP
#define LOGIC_AXI4_STREAM_RESET_IF_HPP

#include <systemc>

namespace logic {
namespace axi4 {
namespace stream {

class reset_if : public sc_core::sc_module {
public:
    sc_core::sc_in<bool> aclk;
    sc_core::sc_out<bool> areset_n;

    reset_if();

    explicit reset_if(const sc_core::sc_module_name& module_name);

    void trace(sc_core::sc_trace_file* trace_file) const override;

    void set_areset_n(bool value);

    void aclk_posedge();

    reset_if(reset_if&&) = delete;

    reset_if(const reset_if& other) = delete;

    reset_if& operator=(reset_if&&) = delete;

    reset_if& operator=(const reset_if& other) = delete;

    ~reset_if() override;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_RESET_IF_HPP */

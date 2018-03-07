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

#ifndef LOGIC_AXI4_STREAM_TEST_HPP
#define LOGIC_AXI4_STREAM_TEST_HPP

#include "logic/axi4/stream/sequence.hpp"
#include "logic/axi4/stream/sequencer.hpp"
#include "logic/axi4/stream/testbench.hpp"

#include <uvm>

namespace logic{
namespace axi4 {
namespace stream {

class sequence;
class testbench;

class test : public uvm::uvm_test {
public:
    UVM_COMPONENT_UTILS(logic::axi4::stream::test)

    test();

    explicit test(const uvm::uvm_component_name& component_name);

    test(test&&) = delete;

    test(const test&) = delete;

    test& operator=(test&&) = delete;

    test& operator=(const test&) = delete;

    ~test() override;
protected:
    void build_phase(uvm::uvm_phase& phase) override;

    void run_phase(uvm::uvm_phase& phase) override;

    void extract_phase(uvm::uvm_phase& phase) override;

    void report_phase(uvm::uvm_phase& phase) override;

    sequence* m_sequence;
    testbench* m_testbench;
    bool m_test_passed;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_TEST_HPP */

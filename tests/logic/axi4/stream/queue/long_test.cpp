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

#include "logic/axi4/stream/rx_sequence.hpp"
#include "logic/axi4/stream/sequence.hpp"
#include "logic/axi4/stream/sequencer.hpp"
#include "logic/axi4/stream/test.hpp"
#include "logic/axi4/stream/testbench.hpp"
#include "logic/axi4/stream/tx_sequence.hpp"

namespace {

class long_test : public logic::axi4::stream::test {
public:
    UVM_COMPONENT_UTILS(long_test)

    using logic::axi4::stream::test::test;

    long_test(long_test&&) = delete;

    long_test(const long_test&) = delete;

    long_test& operator=(long_test&&) = delete;

    long_test& operator=(const long_test&) = delete;

    ~long_test() override = default;
protected:
    void run_phase(uvm::uvm_phase& phase) override {
        phase.raise_objection(this);

        m_sequence->length = {1024, 4096};
        m_sequence->packets = {8, 16};

        m_sequence->rx_idle = {0, 0};
        m_sequence->tx_idle = {0, 0};
        m_sequence->start(m_testbench->sequencer);

        m_sequence->rx_idle = {0, 3};
        m_sequence->tx_idle = {0, 0};
        m_sequence->start(m_testbench->sequencer);

        m_sequence->rx_idle = {0, 0};
        m_sequence->tx_idle = {0, 3};
        m_sequence->start(m_testbench->sequencer);

        m_sequence->rx_idle = {0, 3};
        m_sequence->tx_idle = {0, 3};
        m_sequence->start(m_testbench->sequencer);

        phase.drop_objection(this);
    }
};

} /* namespace */

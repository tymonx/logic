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

#include "logic/axi4/stream/test.hpp"

#include <random>

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

        std::random_device random_device;
        std::mt19937 random_generator(random_device());

        std::uniform_int_distribution<std::size_t> random_packets{8, 16};
        std::uniform_int_distribution<std::size_t> random_length{256, 1024};
        std::uniform_int_distribution<std::uint8_t> random_data{};

        m_sequence->reset->items.resize(1);
        m_sequence->reset->items[0].duration = 1;
        m_sequence->reset->items[0].idle = 0;

        auto randomize = [&] (const logic::range& rx,
                const logic::range& tx) {
            m_sequence->rx->items.resize(random_packets(random_generator));
            m_sequence->tx->items.resize(m_sequence->rx->items.size());

            for (auto& item : m_sequence->rx->items) {
                item.idle = rx;
                item.tdata.resize(random_length(random_generator));
                for (auto& data : item.tdata) {
                    data = random_data(random_generator);
                }
            }

            for (auto& item : m_sequence->tx->items) {
                item.idle = tx;
            }
        };

        randomize({0, 0}, {0, 0});
        m_sequence->start(m_testbench->sequencer);

        randomize({0, 3}, {0, 0});
        m_sequence->start(m_testbench->sequencer);

        randomize({0, 0}, {0, 3});
        m_sequence->start(m_testbench->sequencer);

        randomize({0, 3}, {0, 3});
        m_sequence->start(m_testbench->sequencer);

        phase.drop_objection(this);
    }
};

} /* namespace */

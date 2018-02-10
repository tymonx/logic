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

#include "logic_reset_synchronizer.h"

#include <gtest/gtest.h>
#include <logic/gtest/factory.hpp>
#include <logic/trace.hpp>
#include <systemc>

class dut {
public:
    sc_core::sc_clock aclk{"aclk"};
    sc_core::sc_signal<bool> areset_n{"areset_n"};
    sc_core::sc_signal<bool> areset_n_synced{"areset_n_synced"};

    dut() {
        m_dut.aclk(aclk);
        m_dut.areset_n(areset_n);
        m_dut.areset_n_synced(areset_n_synced);
    }
private:
    logic_reset_synchronizer m_dut{"logic_reset_synchronizer"};
    logic::trace<decltype(m_dut)> m_trace{m_dut};
};

class logic_reset_synchronizer_test : public ::testing::Test {
protected:
    void SetUp() override {
        m_dut->areset_n = false;
        sc_start(1, sc_core::SC_NS);
    }

    void TearDown() override {
        m_dut->areset_n = false;
    }

    dut* m_dut{logic::gtest::factory::get<dut>()};
};

static logic::gtest::factory::add<dut> g;

TEST_F(logic_reset_synchronizer_test, simple) {
    m_dut->areset_n = false;
    sc_start(3, SC_NS);

    EXPECT_FALSE(m_dut->areset_n_synced.read());

    m_dut->areset_n = true;
    sc_start(3, SC_NS);

    EXPECT_TRUE(m_dut->areset_n_synced.read());
}

TEST_F(logic_reset_synchronizer_test, deassertion) {
    m_dut->areset_n = true;
    sc_start(3, SC_NS);

    EXPECT_TRUE(m_dut->areset_n_synced.read());

    m_dut->areset_n = false;
    sc_start(1, SC_NS);

    EXPECT_FALSE(m_dut->areset_n_synced.read());
}

TEST_F(logic_reset_synchronizer_test, deassertion_repeat_10) {
    for (auto i = 0u; i < 10u; ++i) {
        m_dut->areset_n = true;
        sc_start(3, SC_NS);

        EXPECT_TRUE(m_dut->areset_n_synced.read());

        m_dut->areset_n = false;
        sc_start(1, SC_NS);

        EXPECT_FALSE(m_dut->areset_n_synced.read());
    }
}

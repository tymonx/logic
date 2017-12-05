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
#include "test.hpp"

using logic_reset_synchronizer_test = test;

TEST_F(logic_reset_synchronizer_test, simple) {
    m_dut->areset_n = 0;
    sc_start(3, SC_NS);

    EXPECT_FALSE(m_dut->areset_n_synced.read());

    m_dut->areset_n = 1;
    sc_start(3, SC_NS);

    EXPECT_TRUE(m_dut->areset_n_synced.read());
}

TEST_F(logic_reset_synchronizer_test, deassertion) {
    m_dut->areset_n = 1;
    sc_start(3, SC_NS);

    EXPECT_TRUE(m_dut->areset_n_synced.read());

    m_dut->areset_n = 0;
    sc_start(1, SC_NS);

    EXPECT_FALSE(m_dut->areset_n_synced.read());
}

TEST_F(logic_reset_synchronizer_test, deassertion_repeat_10) {
    for (auto i = 0u; i < 10u; ++i) {
        m_dut->areset_n = 1;
        sc_start(3, SC_NS);

        EXPECT_TRUE(m_dut->areset_n_synced.read());

        m_dut->areset_n = 0;
        sc_start(1, SC_NS);

        EXPECT_FALSE(m_dut->areset_n_synced.read());
    }
}

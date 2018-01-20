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

#include "test.hpp"
#include "dut.hpp"

#include <logic/gtest/factory.hpp>

test::test() :
    m_dut{logic::gtest::factory::get<dut>()}
{ }

void test::SetUp() {
    m_dut->areset_n = 0;
    sc_start(1, SC_NS);
}

void test::TearDown() {
    m_dut->areset_n = 0;
}

static logic::gtest::factory::add<dut> g;

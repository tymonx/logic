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

#ifndef BASIC_TEST_HPP
#define BASIC_TEST_HPP

#include "logic/axi4/stream/test.hpp"

class basic_test : public logic::axi4::stream::test {
public:
    UVM_COMPONENT_UTILS(basic_test)

    basic_test(const uvm::uvm_component_name& name);

    virtual ~basic_test() override;
protected:
    virtual void build_phase(uvm::uvm_phase& phase) override;
};

#endif /* BASIC_TEST_HPP */

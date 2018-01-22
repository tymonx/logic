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

#ifndef LONG_TEST_HPP
#define LONG_TEST_HPP

#include "logic/axi4/stream/test.hpp"

class long_test : public logic::axi4::stream::test {
public:
    UVM_COMPONENT_UTILS(long_test)

    long_test(const uvm::uvm_component_name& name);

    virtual ~long_test() override;
protected:
    virtual void build_phase(uvm::uvm_phase& phase) override;
};

#endif /* LONG_TEST_HPP */

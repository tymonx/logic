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

#ifndef LOGIC_AXI4_STREAM_RESET_SEQUENCE_HPP
#define LOGIC_AXI4_STREAM_RESET_SEQUENCE_HPP

#include "reset_sequence_item.hpp"

#include <uvm>
#include <scv.h>

#include <cstddef>

namespace logic {
namespace axi4 {
namespace stream {

class reset_sequence : public uvm::uvm_sequence<reset_sequence_item> {
public:
    UVM_OBJECT_UTILS(reset_sequence)

    scv_smart_ptr<std::size_t> duration;
    scv_smart_ptr<std::size_t> idle;
    scv_smart_ptr<std::size_t> number_of_resets;

    reset_sequence();

    reset_sequence(const std::string& name);

    virtual ~reset_sequence() override;
protected:
    virtual void pre_body() override;

    virtual void body() override;

    virtual void post_body() override;
};

}
}
}

#endif /* LOGIC_AXI4_STREAM_RESET_SEQUENCE_HPP */

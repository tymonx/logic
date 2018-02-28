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

#ifndef LOGIC_AXI4_STREAM_RESET_SEQUENCE_HPP
#define LOGIC_AXI4_STREAM_RESET_SEQUENCE_HPP

#include "reset_sequence_item.hpp"

#include <uvm>

#include <cstddef>
#include <vector>

namespace logic {
namespace axi4 {
namespace stream {

class reset_sequence : public uvm::uvm_sequence<reset_sequence_item> {
public:
    UVM_OBJECT_UTILS(logic::axi4::stream::reset_sequence)

    std::vector<reset_sequence_item> items;

    reset_sequence();

    explicit reset_sequence(const std::string& name);

    reset_sequence(reset_sequence&&) = delete;

    reset_sequence(const reset_sequence& other) = delete;

    reset_sequence& operator=(reset_sequence&&) = delete;

    reset_sequence& operator=(const reset_sequence& other) = delete;

    ~reset_sequence() override;
protected:
    void pre_body() override;

    void body() override;

    void post_body() override;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_RESET_SEQUENCE_HPP */

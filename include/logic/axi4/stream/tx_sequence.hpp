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

#ifndef LOGIC_AXI4_STREAM_TX_SEQUENCE_HPP
#define LOGIC_AXI4_STREAM_TX_SEQUENCE_HPP

#include "logic/axi4/stream/tx_sequence_item.hpp"

#include <uvm>

#include <cstddef>
#include <vector>

namespace logic {
namespace axi4 {
namespace stream {

class tx_sequence : public uvm::uvm_sequence<tx_sequence_item> {
public:
    UVM_OBJECT_UTILS(logic::axi4::stream::tx_sequence)

    std::vector<tx_sequence_item> items;

    tx_sequence();

    explicit tx_sequence(const std::string& name);

    tx_sequence(tx_sequence&&) = delete;

    tx_sequence(const tx_sequence&) = delete;

    tx_sequence& operator=(tx_sequence&&) = delete;

    tx_sequence& operator=(const tx_sequence&) = delete;

    ~tx_sequence() override;
protected:
    void pre_body() override;

    void body() override;

    void post_body() override;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_TX_SEQUENCE_HPP */

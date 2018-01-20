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

#ifndef LOGIC_AXI4_STREAM_RX_SEQUENCE_HPP
#define LOGIC_AXI4_STREAM_RX_SEQUENCE_HPP

#include "logic/range.hpp"
#include "rx_sequence_item.hpp"

#include <uvm>
#include <scv.h>

#include <cstddef>

namespace logic {
namespace axi4 {
namespace stream {

class rx_sequence : public uvm::uvm_sequence<rx_sequence_item> {
public:
    UVM_OBJECT_UTILS(logic::axi4::stream::rx_sequence)

    scv_smart_ptr<std::size_t> packet_length;
    scv_smart_ptr<std::size_t> number_of_packets;
    scv_smart_ptr<std::size_t> idle_scheme;

    rx_sequence();

    rx_sequence(const std::string& name);

    rx_sequence(rx_sequence&&) = default;

    rx_sequence(const rx_sequence& other) = default;

    rx_sequence& operator=(rx_sequence&&) = default;

    rx_sequence& operator=(const rx_sequence& other) = default;

    virtual ~rx_sequence() override;
protected:
    virtual void pre_body() override;

    virtual void body() override;

    virtual void post_body() override;
};

}
}
}

#endif /* LOGIC_AXI4_STREAM_RX_SEQUENCE_HPP */

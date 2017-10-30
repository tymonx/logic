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

#ifndef LOGIC_AXI4_STREAM_RX_SEQUENCE_HPP
#define LOGIC_AXI4_STREAM_RX_SEQUENCE_HPP

#include "logic/range.hpp"
#include "rx_sequence_item.hpp"

#include <uvm>

#include <string>
#include <cstddef>

namespace logic {
namespace axi4 {
namespace stream {

class rx_sequence : public uvm::uvm_sequence<rx_sequence_item> {
public:
    UVM_OBJECT_UTILS(rx_sequence)

    rx_sequence();

    rx_sequence(const std::string& name);

    rx_sequence& size(std::size_t value) noexcept;

    rx_sequence& size(std::size_t min, std::size_t max) noexcept;

    rx_sequence& size(const range& value) noexcept;

    rx_sequence& idle(std::size_t value) noexcept;

    rx_sequence& idle(std::size_t min, std::size_t max) noexcept;

    rx_sequence& idle(const range& value) noexcept;

    rx_sequence& packets(std::size_t value) noexcept;

    rx_sequence& packets(std::size_t min, std::size_t max) noexcept;

    rx_sequence& packets(const range& value) noexcept;

    const range& size() const noexcept;

    const range& idle() const noexcept;

    const range& packets() const noexcept;

    virtual ~rx_sequence() override;
protected:
    virtual void pre_body() override;

    virtual void body() override;

    virtual void post_body() override;
private:
    range m_size{};
    range m_idle{};
    range m_packets{};
};

}
}
}

#endif /* LOGIC_AXI4_STREAM_RX_SEQUENCE_HPP */

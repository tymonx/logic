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

#ifndef LOGIC_AXI4_STREAM_RX_DRIVER_HPP
#define LOGIC_AXI4_STREAM_RX_DRIVER_HPP

#include "logic/axi4/stream/rx_sequence_item.hpp"

#include <uvm>

#include <cstddef>
#include <random>

namespace logic {
namespace axi4 {
namespace stream {

class bus_if_base;
class rx_sequence_item;

class rx_driver : public uvm::uvm_driver<rx_sequence_item> {
public:
    UVM_COMPONENT_UTILS(logic::axi4::stream::rx_driver)

    rx_driver();

    explicit rx_driver(const uvm::uvm_component_name& component_name);

    rx_driver(rx_driver&&) = delete;

    rx_driver(const rx_driver&) = delete;

    rx_driver& operator=(rx_driver&&) = delete;

    rx_driver& operator=(const rx_driver&) = delete;

    ~rx_driver() override;
protected:
    void build_phase(uvm::uvm_phase& phase) override;

    [[noreturn]] void run_phase(uvm::uvm_phase& phase) override;

    void data_transfer(const rx_sequence_item& item);

    void idle_transfer(const rx_sequence_item& item);

    bus_if_base* m_vif;
    rx_sequence_item* m_item;
    std::mt19937 m_random_generator;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_RX_DRIVER_HPP */

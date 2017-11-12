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

#ifndef LOGIC_AXI4_STREAM_TX_DRIVER_HPP
#define LOGIC_AXI4_STREAM_TX_DRIVER_HPP

#include <uvm>

#include <cstddef>

namespace logic {
namespace axi4 {
namespace stream {

class bus_if_base;
class tx_sequence_item;

class tx_driver : public uvm::uvm_driver<tx_sequence_item> {
public:
    UVM_COMPONENT_UTILS(logic::axi4::stream::tx_driver)

    tx_driver();

    tx_driver(const uvm::uvm_component_name& name);

    virtual ~tx_driver() override;
protected:
    tx_driver(const tx_driver&) = delete;

    tx_driver& operator=(const tx_driver&) = delete;

    virtual void build_phase(uvm::uvm_phase& phase) override;

    [[noreturn]] virtual void run_phase(uvm::uvm_phase& phase) override;

    void transfer(const tx_sequence_item& item);

    bus_if_base* m_vif;
};

}
}
}

#endif /* LOGIC_AXI4_STREAM_TX_DRIVER_HPP */

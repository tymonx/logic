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

#ifndef LOGIC_AXI4_STREAM_RESET_DRIVER_HPP
#define LOGIC_AXI4_STREAM_RESET_DRIVER_HPP

#include "logic/axi4/stream/reset_sequence_item.hpp"

#include <uvm>

namespace logic {
namespace axi4 {
namespace stream {

class reset_if;
class reset_sequence_item;

class reset_driver : public uvm::uvm_driver<reset_sequence_item> {
public:
    UVM_COMPONENT_UTILS(logic::axi4::stream::reset_driver)

    reset_driver();

    explicit reset_driver(const uvm::uvm_component_name& component_name);

    reset_driver(reset_driver&&) = delete;

    reset_driver(const reset_driver&) = delete;

    reset_driver& operator=(reset_driver&&) = delete;

    reset_driver& operator=(const reset_driver&) = delete;

    ~reset_driver() override;
protected:
    void build_phase(uvm::uvm_phase& phase) override;

    [[noreturn]] void run_phase(uvm::uvm_phase& phase) override;

    void transfer(const reset_sequence_item& item);

    reset_if* m_vif;
    reset_sequence_item* m_item;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_RESET_DRIVER_HPP */

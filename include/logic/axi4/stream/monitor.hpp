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

#ifndef LOGIC_AXI4_STREAM_MONITOR_HPP
#define LOGIC_AXI4_STREAM_MONITOR_HPP

#include <uvm>

namespace logic {
namespace axi4 {
namespace stream {

class packet;
class bus_if_base;

class monitor : public uvm::uvm_monitor {
public:
    UVM_COMPONENT_UTILS(logic::axi4::stream::monitor)

    monitor();

    explicit monitor(const uvm::uvm_component_name& component_name);

    monitor(monitor&&) = delete;

    monitor(const monitor&) = delete;

    monitor& operator=(monitor&&) = delete;

    monitor& operator=(const monitor&) = delete;

    ~monitor() override;

    uvm::uvm_analysis_port<packet> analysis_port;
protected:
    void build_phase(uvm::uvm_phase& phase) override;

    [[noreturn]] void run_phase(uvm::uvm_phase& phase) override;

    bus_if_base* m_vif;
    bool m_checks_enable;
    bool m_coverage_enable;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_MONITOR_HPP */

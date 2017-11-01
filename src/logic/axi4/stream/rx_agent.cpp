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

#include "logic/axi4/stream/rx_agent.hpp"

#include "logic/axi4/stream/monitor.hpp"
#include "logic/axi4/stream/rx_driver.hpp"
#include "logic/axi4/stream/rx_sequencer.hpp"

using logic::axi4::stream::rx_agent;

rx_agent::rx_agent() :
    rx_agent{"rx_agent"}
{ }

rx_agent::rx_agent(const uvm::uvm_component_name& name) :
    uvm::uvm_agent{name},
    analysis_port{"analysis_port"},
    sequencer{nullptr},
    m_monitor{nullptr},
    m_driver{nullptr}
{
    UVM_INFO(get_name(), "Constructor", uvm::UVM_NONE);
}

rx_agent::~rx_agent() { }

void rx_agent::build_phase(uvm::uvm_phase& phase) {
    uvm::uvm_agent::build_phase(phase);
    UVM_INFO(get_name(), "Build phase", uvm::UVM_NONE);

    if (get_is_active() == uvm::UVM_ACTIVE) {
        UVM_INFO(get_name(), "is set to UVM_ACTIVE", uvm::UVM_NONE);

        sequencer = rx_sequencer::type_id::create("sequencer", this);
        if (!sequencer) {
            UVM_FATAL(get_name(), "Sequencer not defined!"
                    " Simulation aborted!");
        }

        m_driver = rx_driver::type_id::create("driver", this);
        if (!m_driver) {
            UVM_FATAL(get_name(), "Driver not defined!"
                    " Simulation aborted!");
        }
    }
    else {
        UVM_INFO(get_name(), "is set to UVM_PASSIVE", uvm::UVM_NONE);
    }

    m_monitor = monitor::type_id::create("monitor", this);
    if (!m_monitor) {
        UVM_FATAL(get_name(), "Monitor not defined! Simulation aborted!");
    }
}

void rx_agent::connect_phase(uvm::uvm_phase& phase) {
    uvm::uvm_agent::connect_phase(phase);
    UVM_INFO(get_name(), "Connect phase", uvm::UVM_NONE);

    m_monitor->analysis_port.connect(analysis_port);

    if (get_is_active() == uvm::UVM_ACTIVE) {
        m_driver->seq_item_port.connect(sequencer->seq_item_export);
    }
}

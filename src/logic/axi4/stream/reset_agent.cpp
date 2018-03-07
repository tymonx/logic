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

#include "logic/axi4/stream/reset_agent.hpp"

#include "logic/axi4/stream/reset_driver.hpp"
#include "logic/axi4/stream/reset_sequencer.hpp"

using logic::axi4::stream::reset_agent;

reset_agent::reset_agent() :
    reset_agent{"reset_agent"}
{ }

reset_agent::reset_agent(const uvm::uvm_component_name& component_name) :
    uvm::uvm_agent{component_name},
    sequencer{nullptr},
    m_driver{nullptr}
{
    UVM_INFO(get_name(), "Constructor", uvm::UVM_FULL);
}

reset_agent::~reset_agent() = default;

void reset_agent::build_phase(uvm::uvm_phase& phase) {
    uvm::uvm_agent::build_phase(phase);
    UVM_INFO(get_name(), "Build phase", uvm::UVM_FULL);

    if (get_is_active() == uvm::UVM_ACTIVE) {
        UVM_INFO(get_name(), "is set to UVM_ACTIVE", uvm::UVM_FULL);

        sequencer = reset_sequencer::type_id::create("sequencer", this);
        if (sequencer == nullptr) {
            UVM_FATAL(get_name(), "Sequencer not defined!"
                    " Simulation aborted!");
        }

        m_driver = reset_driver::type_id::create("driver", this);
        if (m_driver == nullptr) {
            UVM_FATAL(get_name(), "Driver not defined!"
                    " Simulation aborted!");
        }
    }
    else {
        UVM_INFO(get_name(), "is set to UVM_PASSIVE", uvm::UVM_FULL);
    }
}

void reset_agent::connect_phase(uvm::uvm_phase& phase) {
    uvm::uvm_agent::connect_phase(phase);
    UVM_INFO(get_name(), "Connect phase", uvm::UVM_FULL);

    if (get_is_active() == uvm::UVM_ACTIVE) {
        m_driver->seq_item_port.connect(sequencer->seq_item_export);
    }
}

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

#include "logic/axi4/stream/reset_driver.hpp"

#include "logic/axi4/stream/reset_if.hpp"
#include "logic/axi4/stream/reset_sequence_item.hpp"

using logic::axi4::stream::reset_driver;

reset_driver::reset_driver() :
    reset_driver{"reset_driver"}
{ }

reset_driver::reset_driver(const uvm::uvm_component_name& name) :
    uvm::uvm_driver<reset_sequence_item>{name},
    m_vif{nullptr}
{ }

reset_driver::~reset_driver() { }

void reset_driver::build_phase(uvm::uvm_phase& phase) {
    uvm::uvm_driver<reset_sequence_item>::build_phase(phase);
    UVM_INFO(get_name(), "Build phase", uvm::UVM_FULL);

    auto ok = uvm::uvm_config_db<reset_if*>::get(this, "*", "vif", m_vif);

    if (!ok) {
        UVM_FATAL(get_name(), "Virtual interface not defined!"
                " Simulation aborted!");
    }
}

void reset_driver::run_phase(uvm::uvm_phase& /* phase */) {
    UVM_INFO(get_name(), "Run phase", uvm::UVM_FULL);
    reset_sequence_item item;

    while (true) {
        seq_item_port->get_next_item(item);
        transfer(item);
        seq_item_port->item_done();
    }
}

void reset_driver::transfer(const reset_sequence_item& item) {
    auto duration = *item.duration;
    auto idle = *item.idle;

    m_vif->set_areset_n(false);
    while (duration--) {
        m_vif->aclk_posedge();
    }

    m_vif->set_areset_n(true);
    while (idle--) {
        m_vif->aclk_posedge();
    }
}

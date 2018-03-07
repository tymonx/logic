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

#include "logic/axi4/stream/tx_driver.hpp"

#include "logic/axi4/stream/bus_if_base.hpp"
#include "logic/axi4/stream/tx_sequence_item.hpp"

using logic::axi4::stream::tx_driver;
using logic::axi4::stream::tx_sequence_item;

tx_driver::tx_driver() :
    tx_driver{"tx_driver"}
{ }

tx_driver::tx_driver(const uvm::uvm_component_name& component_name) :
    uvm::uvm_driver<tx_sequence_item>{component_name},
    m_vif{nullptr},
    m_item{nullptr},
    m_random_generator{}
{ }

tx_driver::~tx_driver() = default;

void tx_driver::build_phase(uvm::uvm_phase& phase) {
    uvm::uvm_driver<tx_sequence_item>::build_phase(phase);
    UVM_INFO(get_name(), "Build phase", uvm::UVM_FULL);

    std::random_device rd;
    m_random_generator.seed(rd());

    auto ok = uvm::uvm_config_db<bus_if_base*>::get(this, "*", "vif", m_vif);

    if (!ok) {
        UVM_FATAL(get_name(), "Virtual interface not defined!"
                " Simulation aborted!");
    }

    m_item = tx_sequence_item::type_id::create("tx_sequence_item", this);

    if (m_item == nullptr) {
        UVM_FATAL(get_name(), "Cannot create tx sequence item!");
    }
}

void tx_driver::run_phase(uvm::uvm_phase& /* phase */) {
    UVM_INFO(get_name(), "Run phase", uvm::UVM_FULL);

    while (true) {
        seq_item_port->get_next_item(*m_item);
        transfer(*m_item);
        seq_item_port->item_done();
    }
}

void tx_driver::transfer(const tx_sequence_item& item) {
    std::uniform_int_distribution<std::size_t>
        random_idle{item.idle.min(), item.idle.max()};

    bool is_running = true;

    std::size_t idle = random_idle(m_random_generator);
    std::size_t timeout = item.timeout;

    m_vif->set_tready(true);

    while ((is_running || (0 != idle)) && m_vif->get_areset_n()) {
        if (is_running && m_vif->get_tready() && m_vif->get_tvalid()
                && (item.tid == m_vif->get_tid())
                && (item.tdest == m_vif->get_tdest())) {
            timeout = item.timeout;
            is_running = !m_vif->get_tlast();
        }

        if (is_running && (0 != item.timeout)) {
            if (0 != timeout) {
                --timeout;
            }
            else {
                idle = 0;
                is_running = false;
                UVM_ERROR(get_name(), "Timeout!");
            }
        }

        if (0 == idle) {
            idle = is_running ? random_idle(m_random_generator) : 0;
            m_vif->set_tready(true);
        }
        else {
            --idle;
            m_vif->set_tready(false);
        }

        m_vif->aclk_posedge();
    }

    m_vif->set_tready(false);
}

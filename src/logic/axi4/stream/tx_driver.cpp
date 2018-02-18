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

tx_driver::tx_driver(const uvm::uvm_component_name& name) :
    uvm::uvm_driver<tx_sequence_item>(name),
    m_vif{nullptr}
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
}

void tx_driver::run_phase(uvm::uvm_phase& /* phase */) {
    UVM_INFO(get_name(), "Run phase", uvm::UVM_FULL);
    tx_sequence_item item;

    while (true) {
        seq_item_port->get_next_item(item);
        transfer(item);
        seq_item_port->item_done();
    }
}

void tx_driver::transfer(const tx_sequence_item& item) {
    auto tready_tmp = m_vif->get_tready();

    std::uniform_int_distribution<std::size_t>
        random_idle{item.idle.min(), item.idle.max()};

    std::size_t packets_count = 1;
    std::size_t idle_count = random_idle(m_random_generator);
    std::size_t timeout = item.timeout;

    while (packets_count != 0) {
        if (!m_vif->get_areset_n()) {
            packets_count = 0;
        }
        else {
            if (m_vif->get_tready() && m_vif->get_tvalid()) {
                timeout = item.timeout;

                if (m_vif->get_tlast()) {
                    --packets_count;
                }
            }

            if (packets_count != 0) {
                if (idle_count != 0) {
                    --idle_count;
                    m_vif->set_tready(false);
                }
                else {
                    idle_count = random_idle(m_random_generator);
                    m_vif->set_tready(true);
                }
            }
            else {
                m_vif->set_tready(tready_tmp);
            }

            if (item.timeout != 0) {
                if (timeout != 0) {
                    --timeout;
                }
                else {
                    packets_count = 0;
                    UVM_ERROR(get_name(), "Timeout!");
                }
            }

            m_vif->aclk_posedge();
        }
    }
}

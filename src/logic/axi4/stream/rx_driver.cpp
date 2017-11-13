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

#include "logic/axi4/stream/rx_driver.hpp"

#include "logic/axi4/stream/bus_if_base.hpp"
#include "logic/axi4/stream/rx_sequence_item.hpp"

#include <utility>

using logic::axi4::stream::rx_driver;
using logic::axi4::stream::rx_sequence_item;

static std::size_t get_idle_count(const rx_sequence_item& item,
        std::size_t count = 0) noexcept {
    std::size_t idle;

    if (!item.idle_scheme.empty()) {
        idle = item.idle_scheme[count % item.idle_scheme.size()];
    }
    else {
        idle = 0;
    }

    return idle;
}

rx_driver::rx_driver(const uvm::uvm_component_name& name) :
    uvm::uvm_driver<rx_sequence_item>{name}
{ }

void rx_driver::build_phase(uvm::uvm_phase& phase) {
    uvm::uvm_driver<rx_sequence_item>::build_phase(phase);
    UVM_INFO(get_name(), "Build phase", uvm::UVM_FULL);

    auto ok = uvm::uvm_config_db<bus_if_base*>::get(this, "*", "vif", m_vif);

    if (!ok) {
        UVM_FATAL(get_name(), "Virtual interface not defined!"
                " Simulation aborted!");
    }
}

void rx_driver::run_phase(uvm::uvm_phase& /* phase */) {
    UVM_INFO(get_name(), "Run phase", uvm::UVM_FULL);

    rx_sequence_item item;

    while (true) {
        seq_item_port->get_next_item(item);
        transfer(item);
        seq_item_port->item_done();
    }
}

void rx_driver::transfer(const rx_sequence_item& item) {
    std::size_t index = 0;
    std::size_t count = 0;
    std::size_t idle_index = 0;
    std::size_t idle_count = get_idle_count(item, idle_index++);
    std::size_t size_count = item.tdata.size();
    std::size_t timeout = item.timeout;
    const std::size_t bus_size = m_vif->size();

    while (size_count) {
        if (!m_vif->get_areset_n()) {
            size_count = 0;
        }
        else if (m_vif->get_tready()) {
            timeout = item.timeout;

            if (idle_count) {
                --idle_count;
                m_vif->set_tvalid(false);
                m_vif->aclk_posedge();
            }
            else {
                idle_count = get_idle_count(item, idle_index++);
                m_vif->set_tvalid(true);

                if (size_count <= bus_size) {
                    m_vif->set_tlast(true);
                }
                else {
                    m_vif->set_tlast(false);
                }

                m_vif->set_tid(item.tid);
                m_vif->set_tdest(item.tdest);

                if (item.tuser.empty()) {
                    m_vif->set_tuser({});
                }
                else {
                    m_vif->set_tuser(item.tuser[count % item.tuser.size()]);
                }

                for (std::size_t i = 0; i < bus_size; ++i) {
                    if (size_count) {
                        m_vif->set_tkeep(i, true);
                        m_vif->set_tstrb(i, true);
                        m_vif->set_tdata(i, item.tdata[index++]);
                        --size_count;
                    }
                    else {
                        m_vif->set_tkeep(i, false);
                        m_vif->set_tstrb(i, false);
                        m_vif->set_tdata(i, 0);
                    }
                }

                ++count;

                do {
                    m_vif->aclk_posedge();
                } while (!size_count && !m_vif->get_tready());
            }
        }
        else {
            if (item.timeout) {
                if (timeout) {
                    --timeout;
                }
                else {
                    size_count = 0;
                    UVM_ERROR(get_name(), "Timeout!");
                }
            }

            m_vif->aclk_posedge();
        }
    }

    m_vif->set_tvalid(false);
}

rx_driver::~rx_driver() { }

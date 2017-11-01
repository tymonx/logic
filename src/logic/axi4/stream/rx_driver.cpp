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

using logic::axi4::stream::rx_driver;

rx_driver::rx_driver(const uvm::uvm_component_name& name) :
    uvm::uvm_driver<rx_sequence_item>{name}
{ }

void rx_driver::build_phase(uvm::uvm_phase& phase) {
    uvm::uvm_driver<rx_sequence_item>::build_phase(phase);
    UVM_INFO(get_name(), "Build phase", uvm::UVM_NONE);

    auto ok = uvm::uvm_config_db<bus_if_base*>::get(this, "*", "vif", m_vif);

    if (!ok) {
        UVM_FATAL(get_name(), "Virtual interface not defined!"
                " Simulation aborted!");
    }
}

void rx_driver::run_phase(uvm::uvm_phase& /* phase */) {
    UVM_INFO(get_name(), "Run phase", uvm::UVM_NONE);
    rx_sequence_item item;

    while (true) {
        seq_item_port->get_next_item(item);
        transfer(item);
        seq_item_port->item_done();
    }
}

void rx_driver::transfer(const rx_sequence_item& item) {
    auto idle_scheme = item.idle_scheme;
    idle_scheme->next();

    auto index = 0u;
    auto count = 0u;
    auto size_count = item.tdata.size();
    auto idle_count = *idle_scheme;
    const auto bus_size = m_vif->size();

    while (size_count) {
        if (!m_vif->get_areset_n()) {
            size_count = 0;
        }
        else if (m_vif->get_tready()) {
            if (idle_count) {
                --idle_count;
                m_vif->set_tvalid(false);
                m_vif->aclk_posedge();
            }
            else {
                idle_scheme->next();
                idle_count = *idle_scheme;

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

                for (auto i = 0u; i < bus_size; ++i) {
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

                do {
                    m_vif->aclk_posedge();
                } while (!size_count && !m_vif->get_tready());

                ++count;
            }
        }
        else {
            m_vif->aclk_posedge();
        }
    }

    m_vif->set_tvalid(false);
}

rx_driver::~rx_driver() { }

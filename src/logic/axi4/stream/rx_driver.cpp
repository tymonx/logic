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

#include "logic/axi4/stream/rx_driver.hpp"

#include "logic/axi4/stream/bus_if_base.hpp"
#include "logic/axi4/stream/rx_sequence_item.hpp"

#include <utility>

using logic::axi4::stream::rx_driver;
using logic::axi4::stream::rx_sequence_item;

rx_driver::rx_driver(const uvm::uvm_component_name& component_name) :
    uvm::uvm_driver<rx_sequence_item>{component_name},
    m_vif{nullptr},
    m_item{nullptr},
    m_random_generator{}
{ }

void rx_driver::build_phase(uvm::uvm_phase& phase) {
    uvm::uvm_driver<rx_sequence_item>::build_phase(phase);
    UVM_INFO(get_name(), "Build phase", uvm::UVM_FULL);

    std::random_device rd;
    m_random_generator.seed(rd());

    auto ok = uvm::uvm_config_db<bus_if_base*>::get(this, "*", "vif", m_vif);

    if (!ok) {
        UVM_FATAL(get_name(), "Virtual interface not defined!"
                " Simulation aborted!");
    }

    m_item = rx_sequence_item::type_id::create("rx_sequence_item", this);

    if (m_item == nullptr) {
        UVM_FATAL(get_name(), "Cannot create rx sequence item!");
    }
}

void rx_driver::run_phase(uvm::uvm_phase& /* phase */) {
    UVM_INFO(get_name(), "Run phase", uvm::UVM_FULL);

    while (true) {
        seq_item_port->get_next_item(*m_item);

        switch (m_item->type) {
        case rx_sequence_item::IDLE:
            idle_transfer(*m_item);
            break;
        case rx_sequence_item::DATA:
        default:
            data_transfer(*m_item);
            break;
        }

        seq_item_port->item_done();
    }
}

void rx_driver::idle_transfer(const rx_sequence_item& item) {
    std::uniform_int_distribution<std::size_t>
        random_idle{item.idle.min(), item.idle.max()};

    std::size_t idle = random_idle(m_random_generator);
    std::size_t timeout = item.timeout;

    while (0 != idle) {
        if (m_vif->get_tready()) {
            --idle;
        }
        else if (0 != item.timeout) {
            if (0 != timeout) {
                --timeout;
            }
            else {
                idle = 0;
                UVM_ERROR(get_name(), "Timeout!");
            }
        }
        m_vif->aclk_posedge();
    }
}

void rx_driver::data_transfer(const rx_sequence_item& item) {
    std::uniform_int_distribution<std::size_t>
        random_idle{item.idle.min(), item.idle.max()};

    const std::size_t total_size = item.tdata.size();
    const std::size_t bus_size = m_vif->size();
    bool is_running = (total_size > 0);

    std::size_t idle = random_idle(m_random_generator);
    std::size_t timeout = item.timeout;
    std::size_t transfer = 0;
    std::size_t index = 0;

    while (is_running && m_vif->get_areset_n()) {
        if (m_vif->get_tready()) {
            m_vif->set_tvalid(false);

            timeout = item.timeout;

            if (index >= total_size) {
                is_running = false;
            }
            else if (0 == idle) {
                idle = random_idle(m_random_generator);

                for (std::size_t i = 0; i < bus_size; ++i) {
                    if (index < total_size) {
                        switch (item.tdata[index].type()) {
                        case tdata_byte::DATA_BYTE:
                            m_vif->set_tkeep(i, true);
                            m_vif->set_tstrb(i, true);
                            break;
                        case tdata_byte::POSITION_BYTE:
                            m_vif->set_tkeep(i, true);
                            m_vif->set_tstrb(i, false);
                            break;
                        case tdata_byte::RESERVED:
                            m_vif->set_tkeep(i, false);
                            m_vif->set_tstrb(i, true);
                            break;
                        case tdata_byte::NULL_BYTE:
                        default:
                            m_vif->set_tkeep(i, false);
                            m_vif->set_tstrb(i, false);
                            break;
                        }
                        m_vif->set_tdata(i, std::uint8_t(item.tdata[index++]));
                    }
                    else {
                        m_vif->set_tkeep(i, false);
                        m_vif->set_tstrb(i, false);
                        m_vif->set_tdata(i, 0);
                    }
                }

                if (0 == bus_size) {
                    ++index;
                }

                if (transfer < item.tuser.size()) {
                    m_vif->set_tuser(item.tuser[transfer]);
                }
                else {
                    m_vif->set_tuser({});
                }

                ++transfer;

                m_vif->set_tid(item.tid);
                m_vif->set_tdest(item.tdest);
                m_vif->set_tlast(index >= total_size);
                m_vif->set_tvalid(true);
            }
            else {
                --idle;
            }
        }
        else if (0 != item.timeout) {
            if (0 != timeout) {
                --timeout;
            }
            else {
                is_running = false;
                UVM_ERROR(get_name(), "Timeout!");
            }
        }
        m_vif->aclk_posedge();
    }

    m_vif->set_tvalid(false);
}

rx_driver::~rx_driver() = default;

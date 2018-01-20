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

#include "logic/axi4/stream/monitor.hpp"

#include "logic/axi4/stream/packet.hpp"
#include "logic/axi4/stream/bus_if_base.hpp"

#include <map>
#include <utility>

using logic::axi4::stream::monitor;

using packet_type = logic::axi4::stream::packet;
using packet_id_type = std::pair<logic::bitstream, logic::bitstream>;
using packets_type = std::map<packet_id_type, packet_type>;

static auto get_packet(packets_type& packets,
        const packet_id_type& packet_id) -> packet_type& {
    packet_type* packet;

    auto it = packets.find(packet_id);
    if (it == packets.cend()) {
        it = packets.emplace(packet_id, packet_type{}).first;
        packet = &it->second;
        packet->tid = packet_id.first;
        packet->tdest = packet_id.second;
    }
    else {
        packet = &it->second;
    }

    return *packet;
}

monitor::monitor() :
    monitor{"monitor"}
{ }

monitor::monitor(const uvm::uvm_component_name& name) :
    uvm::uvm_monitor{name},
    analysis_port{"analysis_port"},
    m_vif{nullptr},
    m_checks_enable{false},
    m_coverage_enable{false}
{ }

monitor::~monitor() { }

void monitor::build_phase(uvm::uvm_phase& phase) {
    uvm::uvm_monitor::build_phase(phase);
    UVM_INFO(get_name(), "Build phase", uvm::UVM_FULL);

    auto ok = uvm::uvm_config_db<bus_if_base*>::get(this, "*", "vif", m_vif);

    if (!ok) {
        UVM_FATAL(get_name(), "Virtual interface not defined!"
                "Simulation aborted!") ;
    }

    uvm::uvm_config_db<bool>::get(this, "*", "checks_enable", m_checks_enable);
    uvm::uvm_config_db<bool>::get(this, "*", "coverage_enable",
            m_coverage_enable);
}

void monitor::run_phase(uvm::uvm_phase& /* phase */) {
    UVM_INFO(get_name(), "Run phase", uvm::UVM_FULL);

    packets_type packets;
    const auto bus_size = m_vif->size();

    while (true) {
        if (!m_vif->get_areset_n()) {
            packets.clear();
        }
        else if (m_vif->get_tvalid() && m_vif->get_tready()) {
            auto timestamp = sc_core::sc_time_stamp();
            auto packet_id = packet_id_type{
                m_vif->get_tid(),
                m_vif->get_tdest()
            };
            auto& packet = get_packet(packets, packet_id);

            packet.tuser.emplace_back(m_vif->get_tuser());
            packet.transfer_timestamp.emplace_back(timestamp);
            packet.bus_size = bus_size;

            for (auto i = 0u; i < bus_size; ++i) {
                if (m_vif->get_tkeep(i) && m_vif->get_tstrb(i)) {
                    packet.tdata.emplace_back(m_vif->get_tdata(i));
                    packet.tdata_timestamp.emplace_back(timestamp);
                }
            }

            if (m_vif->get_tlast()) {
                analysis_port.write(packet);
                packets.erase(packet_id);
            }
        }
        m_vif->aclk_posedge();
    }
}

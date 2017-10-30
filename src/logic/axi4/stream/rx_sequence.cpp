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

#include "logic/axi4/stream/rx_sequence.hpp"

#include <scv.h>

#include <cstdint>

using logic::axi4::stream::rx_sequence;

rx_sequence::rx_sequence() :
    uvm::uvm_sequence<rx_sequence_item>{"rx_sequence"}
{ }

rx_sequence::rx_sequence(const std::string& name) :
    uvm::uvm_sequence<rx_sequence_item>{name}
{ }

auto rx_sequence::size(std::size_t value) noexcept -> rx_sequence& {
    m_size = value;
    return *this;
}

auto rx_sequence::size(std::size_t min,
        std::size_t max) noexcept -> rx_sequence& {
    m_size = {min, max};
    return *this;
}

auto rx_sequence::size(const range& value) noexcept -> rx_sequence& {
    m_size = value;
    return *this;
}

auto rx_sequence::size() const noexcept -> const range& {
    return m_size;
}

auto rx_sequence::idle(std::size_t value) noexcept -> rx_sequence& {
    m_idle = value;
    return *this;
}

auto rx_sequence::idle(std::size_t min,
        std::size_t max) noexcept -> rx_sequence& {
    m_idle = {min, max};
    return *this;
}

auto rx_sequence::idle(const range& value) noexcept -> rx_sequence& {
    m_idle = value;
    return *this;
}

auto rx_sequence::idle() const noexcept -> const range& {
    return m_idle;
}

auto rx_sequence::packets(std::size_t value) noexcept -> rx_sequence& {
    m_packets = value;
    return *this;
}

auto rx_sequence::packets(std::size_t min,
        std::size_t max) noexcept -> rx_sequence& {
    m_packets = {min, max};
    return *this;
}

auto rx_sequence::packets(const range& value) noexcept -> rx_sequence& {
    m_packets = value;
    return *this;
}

auto rx_sequence::packets() const noexcept -> const range& {
    return m_packets;
}

rx_sequence::~rx_sequence() { }

void rx_sequence::pre_body() {
    if (starting_phase) {
        starting_phase->raise_objection(this);
    }
}

void rx_sequence::body() {
    std::vector<std::uint8_t> item_data;

    scv_smart_ptr<std::uint8_t> random_data;
    scv_smart_ptr<std::size_t> random_idle;
    scv_smart_ptr<std::size_t> random_size;
    scv_smart_ptr<std::size_t> random_packets;

    random_idle->keep_only(idle().min(), idle().max());
    random_size->keep_only(size().min(), size().max());
    random_packets->keep_only(packets().min(), packets().max());

    random_packets->next();
    const auto packets_count = *random_packets;

    UVM_INFO(get_name(), "Starting sequence", uvm::UVM_HIGH);

    for (std::size_t i = 0u; i < packets_count; ++i) {
        random_size->next();
        item_data.resize(*random_size);

        for (auto& item_data_value : item_data) {
            random_data->next();
            item_data_value = *random_data;
        }

        rx_sequence_item item;
        start_item(&item.data(item_data).idle(idle()));
        finish_item(&item);
    }

    UVM_INFO(get_name(), "Finishing sequence", uvm::UVM_HIGH);
}

void rx_sequence::post_body() {
    if (starting_phase) {
        starting_phase->drop_objection(this);
    }
}

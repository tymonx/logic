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

#include "logic/axi4/stream/rx_sequence_item.hpp"
#include "logic/printer/json.hpp"

namespace {
namespace field {

class tdata : public uvm::uvm_object {
public:
    explicit tdata(const logic::axi4::stream::tdata_byte& tdata_byte) :
        m_data{tdata_byte.data()}
    {
        switch (tdata_byte.type()) {
        case logic::axi4::stream::tdata_byte::DATA_BYTE:
            m_type = "data";
            break;
        case logic::axi4::stream::tdata_byte::POSITION_BYTE:
            m_type = "position";
            break;
        case logic::axi4::stream::tdata_byte::RESERVED:
            m_type = "reserved";
            break;
        case logic::axi4::stream::tdata_byte::NULL_BYTE:
        default:
            m_type = "null";
            break;
        }
    }

    ~tdata() override;
protected:
    void do_print(const uvm::uvm_printer& printer) const override {
        printer.print_string("type", m_type);
        printer.print_field_int("value", unsigned(m_data), 8, uvm::UVM_HEX);
    }

    std::string m_type{};
    std::uint8_t m_data{};
};

tdata::~tdata() = default;

class tuser : public uvm::uvm_object {
public:
    explicit tuser(const std::vector<logic::bitstream>& tuser_vector) :
        m_width{tuser_vector.empty() ? 0u : tuser_vector[0].size()},
        m_values(tuser_vector.size())
    {
        for (std::size_t i = 0u; i < tuser_vector.size(); ++i) {
            for (std::size_t j = 0u; j < m_width; ++j) {
                m_values[i][int(j)] = bool(tuser_vector[i][j]);
            }
        }
    }

    ~tuser() override;
protected:
    void do_print(const uvm::uvm_printer& printer) const override {
        printer.print_field_int("width", m_width, -1, uvm::UVM_DEC);

        if (m_values.size() == 1) {
            printer.print_field("value", m_values[0], int(m_width),
                    uvm::UVM_HEX);
        }
        else {
            printer.print_array_header("value", int(m_values.size()));

            for (const auto& value : m_values) {
                printer.print_field("value", value, int(m_width), uvm::UVM_HEX);
            }

            printer.print_array_footer();
        }
    }

    std::size_t m_width;
    std::vector<uvm::uvm_bitstream_t> m_values;
};

tuser::~tuser() = default;

class idle : public uvm::uvm_object {
public:
    explicit idle(const logic::range& value) :
        m_range{value}
    { }

    ~idle() override;
protected:
    void do_print(const uvm::uvm_printer& printer) const override {
        printer.print_field_int("min", m_range.min(), -1, uvm::UVM_DEC);
        printer.print_field_int("max", m_range.max(), -1, uvm::UVM_DEC);
    }

    logic::range m_range{};
};

idle::~idle() = default;

class width_value : public uvm::uvm_object {
public:
    explicit width_value(const logic::bitstream& bits) :
        m_width{bits.size()}
    {
        for (std::size_t i = 0; i < m_width; ++i) {
            m_value[int(i)] = bool(bits[i]);
        }
    }

    ~width_value() override;
protected:
    void do_print(const uvm::uvm_printer& printer) const override {
        printer.print_field_int("width", m_width, -1, uvm::UVM_DEC);
        printer.print_field("value", m_value, int(m_width), uvm::UVM_HEX);
    }

    std::size_t m_width{};
    uvm::uvm_bitstream_t m_value{};
};

width_value::~width_value() = default;

} /* namespace field */
} /* namespace */

static constexpr std::size_t TIMEOUT{10000};

using logic::axi4::stream::rx_sequence_item;

rx_sequence_item::rx_sequence_item() :
    rx_sequence_item{"rx_sequence_item"}
{ }

rx_sequence_item::rx_sequence_item(const std::string& name) :
    uvm::uvm_sequence_item{name},
    type{DATA},
    tid{},
    tdest{},
    tuser{},
    tdata{},
    idle{},
    timeout{TIMEOUT}
{
    tid.resize(1);
    tdest.resize(1);
    tuser.resize(1);
    tuser[0].resize(1);
}

rx_sequence_item::~rx_sequence_item() = default;

auto rx_sequence_item::convert2string() const -> std::string {
    logic::printer::json json_printer;
    do_print(json_printer);
    return json_printer.emit();
}

void rx_sequence_item::do_print(const uvm::uvm_printer& printer) const {
    switch (type) {
    case DATA:
        printer.print_string("type", "data");
        break;
    case IDLE:
    default:
        printer.print_string("type", "idle");
        break;
    }

    printer.print_field_int("timeout", timeout, -1, uvm::UVM_DEC);
    printer.print_object("idle", field::idle{idle});
    printer.print_object("tid", field::width_value{tid});
    printer.print_object("tdest", field::width_value{tdest});
    printer.print_object("tuser", field::tuser{tuser});

    printer.print_array_header("tdata", int(tdata.size()));

    for (const auto& item : tdata) {
        printer.print_object("item", field::tdata{item});
    }

    printer.print_array_footer();
}

void rx_sequence_item::do_copy(const uvm::uvm_object& rhs) {
    auto other = dynamic_cast<const rx_sequence_item*>(&rhs);
    if (other != nullptr) {
        *this = *other;
    }
    else {
        UVM_ERROR(get_name(), "Error in do_copy");
    }
}

bool rx_sequence_item::do_compare(const uvm::uvm_object& rhs,
        const uvm::uvm_comparer* /* comparer */) const {
    auto other = dynamic_cast<const rx_sequence_item*>(&rhs);
    auto status = false;

    if (other != nullptr) {
        status =
            (type == other->type) &&
            (idle == other->idle) &&
            (timeout == other->timeout) &&
            (tid == other->tid) &&
            (tdest == other->tdest) &&
            (tuser == other->tuser) &&
            (tdata == other->tdata);
    }
    else {
        UVM_ERROR(get_name(), "Error in do_compare");
    }

    return status;
}

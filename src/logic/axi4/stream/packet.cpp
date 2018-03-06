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

#include "logic/axi4/stream/packet.hpp"
#include "logic/printer/json.hpp"

using logic::axi4::stream::packet;

namespace {
namespace field {

struct transaction : public uvm::uvm_object {
    using tdata_byte_iterator =
        std::vector<logic::axi4::stream::tdata_byte>::const_iterator;

    transaction(const sc_core::sc_time& timestamp,
            const logic::bitstream& tuser,
            tdata_byte_iterator tdata_byte_begin,
            tdata_byte_iterator tdata_byte_end,
            std::size_t tdata_bytes) :
        m_timestamp{timestamp},
        m_tuser_width{tuser.size()},
        m_tdata_bytes{tdata_bytes}
    {
        int index = 0;

        for (std::size_t i = 0u; i < tuser.size(); ++i) {
            m_tuser[int(i)] = bool(tuser[i]);
        }

        while ((tdata_byte_begin < tdata_byte_end) && (0 != tdata_bytes--)) {
            switch (tdata_byte_begin->type()) {
            case logic::axi4::stream::tdata_byte::DATA_BYTE:
                m_tkeep[index] = true;
                m_tstrb[index] = true;
                break;
            case logic::axi4::stream::tdata_byte::RESERVED:
                m_tkeep[index] = false;
                m_tstrb[index] = true;
                break;
            case logic::axi4::stream::tdata_byte::POSITION_BYTE:
                m_tkeep[index] = true;
                m_tstrb[index] = false;
                break;
            case logic::axi4::stream::tdata_byte::NULL_BYTE:
            default:
                m_tkeep[index] = false;
                m_tstrb[index] = false;
                break;
            }

            m_tdata(8 * (index + 1) - 1, 8 * index) =
                unsigned(tdata_byte_begin->data());

            ++tdata_byte_begin;
            ++index;
        }
    }

    ~transaction() override;
protected:
    void do_print(const uvm::uvm_printer& printer) const override {
        printer.print_time("time", m_timestamp);
        printer.print_field("tuser", m_tuser, int(m_tuser_width), uvm::UVM_HEX);
        printer.print_field("tkeep", m_tkeep, int(m_tdata_bytes), uvm::UVM_HEX);
        printer.print_field("tstrb", m_tstrb, int(m_tdata_bytes), uvm::UVM_HEX);
        printer.print_field("tdata", m_tdata, int(8 * m_tdata_bytes), uvm::UVM_HEX);
    }

    sc_core::sc_time m_timestamp{};
    uvm::uvm_bitstream_t m_tuser{};
    std::size_t m_tuser_width{};
    uvm::uvm_bitstream_t m_tkeep{};
    uvm::uvm_bitstream_t m_tstrb{};
    uvm::uvm_bitstream_t m_tdata{};
    std::size_t m_tdata_bytes;
};

transaction::~transaction() = default;

struct width : public uvm::uvm_object {
    explicit width(std::size_t value) :
        m_width{value}
    { }

    explicit width(const logic::bitstream& bits) :
        m_width{bits.size()}
    { }

    ~width() override;
protected:
    void do_print(const uvm::uvm_printer& printer) const override {
        printer.print_field_int("width", m_width, -1, uvm::UVM_DEC);
    }

    std::size_t m_width{};
};

width::~width() = default;

struct width_value : public width {
    explicit width_value(const logic::bitstream& bits) :
        width{bits}
    {
        for (std::size_t i = 0; i < m_width; ++i) {
            m_value[int(i)] = bool(bits[i]);
        }
    }

    ~width_value() override;
protected:
    void do_print(const uvm::uvm_printer& printer) const override {
        width::do_print(printer);
        printer.print_field("value", m_value, int(m_width), uvm::UVM_HEX);
    }

    uvm::uvm_bitstream_t m_value{};
};

width_value::~width_value() = default;

} /* namespace field */
} /* namespace */

packet::packet() :
    packet{"packet"}
{ }

packet::packet(const std::string& name) :
    uvm::uvm_object{name},
    tid{},
    tdest{},
    tuser{},
    tdata{},
    timestamps{},
    bus_size{}
{ }

packet::~packet() = default;

std::string packet::convert2string() const {
    logic::printer::json json_printer;
    do_print(json_printer);
    return json_printer.emit();
}

void packet::do_print(const uvm::uvm_printer& printer) const {
    const std::size_t tuser_width = tuser.empty() ? 0u : tuser[0].size();

    printer.print_object("tid", field::width_value{tid});
    printer.print_object("tdest", field::width_value{tdest});
    printer.print_object("tuser", field::width{tuser_width});
    printer.print_object("tkeep", field::width{bus_size});
    printer.print_object("tstrb", field::width{bus_size});
    printer.print_object("tdata", field::width{8u * bus_size});

    printer.print_array_header("transaction", int(timestamps.size()));

    auto it_tdata = tdata.cbegin();
    auto it_timestamp = timestamps.cbegin();
    auto it_tuser = tuser.cbegin();

    while (it_timestamp < timestamps.cend()) {
        printer.print_object("item", field::transaction{
            *it_timestamp++,
            *it_tuser++,
            it_tdata,
            tdata.cend(),
            bus_size
        });

        it_tdata += decltype(it_tdata)::difference_type(bus_size);
    }

    printer.print_array_footer();
}

void packet::do_copy(const uvm::uvm_object& rhs) {
    auto other = dynamic_cast<const packet*>(&rhs);
    if (other != nullptr) {
        *this = *other;
    }
    else {
        UVM_ERROR(get_name(), "Error in do_copy");
    }
}

bool packet::do_compare(const uvm::uvm_object& rhs,
        const uvm::uvm_comparer* /* comparer */) const {
    auto other = dynamic_cast<const packet*>(&rhs);
    auto status = false;

    if (other != nullptr) {
        status = (tid == other->tid) && (tdest == other->tdest) &&
            (tuser == other->tuser) && (tdata == other->tdata);
    }
    else {
        UVM_ERROR(get_name(), "Error in do_compare");
    }

    return status;
}

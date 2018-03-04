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
    std::size_t tdata_bytes{};
    std::size_t tuser_width{};
    sc_core::sc_time timestamp{};
    uvm::uvm_bitstream_t tuser{};
    uvm::uvm_bitstream_t tkeep{};
    uvm::uvm_bitstream_t tstrb{};
    uvm::uvm_bitstream_t tdata{};
protected:
    void do_print(const uvm::uvm_printer& printer) const override {
        printer.print_time("time", timestamp);
        printer.print_field("tuser", tuser, int(tuser_width), uvm::UVM_HEX);
        printer.print_field("tkeep", tkeep, int(tdata_bytes), uvm::UVM_HEX);
        printer.print_field("tstrb", tstrb, int(tdata_bytes), uvm::UVM_HEX);
        printer.print_field("tdata", tdata, int(8 * tdata_bytes), uvm::UVM_HEX);
    }
};

struct time : public uvm::uvm_object {
    explicit time(const std::vector<sc_core::sc_time>& timestamps) :
        m_total{timestamps.back() - timestamps.front()},
        m_begin{timestamps.front()},
        m_end{timestamps.back()}
    { }
protected:
    void do_print(const uvm::uvm_printer& printer) const override {
        printer.print_time("total", m_total);
        printer.print_time("begin", m_begin);
        printer.print_time("end", m_end);
    }

    sc_core::sc_time m_total{};
    sc_core::sc_time m_begin{};
    sc_core::sc_time m_end{};
};


struct width : public uvm::uvm_object {
    explicit width(std::size_t value) :
        m_width{value}
    { }

    explicit width(const logic::bitstream& bits) :
        m_width{bits.size()}
    { }
protected:
    void do_print(const uvm::uvm_printer& printer) const override {
        printer.print_field_int("width", m_width, -1, uvm::UVM_DEC);
    }

    std::size_t m_width{};
};

struct width_value : public width {
    explicit width_value(const logic::bitstream& bits) :
        width{bits}
    {
        for (std::size_t i = 0; i < m_width; ++i) {
            m_value[int(i)] = bool(bits[i]);
        }
    }
protected:
    void do_print(const uvm::uvm_printer& printer) const override {
        width::do_print(printer);
        printer.print_field("value", m_value, int(m_width), uvm::UVM_HEX);
    }

    uvm::uvm_bitstream_t m_value{};
};

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
    bus_size{0}
{ }

packet::~packet() = default;

std::string packet::convert2string() const {
    logic::printer::json json_printer;
    do_print(json_printer);
    return json_printer.emit();
}

void packet::do_print(const uvm::uvm_printer& printer) const {
    const std::size_t tuser_width = tuser.empty() ? 0 : tuser[0].size();

    printer.print_object("time", field::time{timestamps});
    printer.print_object("tid", field::width_value{tid});
    printer.print_object("tdest", field::width_value{tdest});
    printer.print_object("tuser", field::width{tuser_width});
    printer.print_object("tkeep", field::width{bus_size});
    printer.print_object("tstrb", field::width{bus_size});
    printer.print_object("tdata", field::width{8 * bus_size});

    printer.print_array_header("transaction", int(timestamps.size()));

    for (std::size_t i = 0u; i < tdata.size(); i += bus_size) {
        field::transaction transaction;
        transaction.tuser_width = tuser_width;
        transaction.tdata_bytes = bus_size;
        transaction.timestamp = timestamps[i / bus_size];

        for (std::size_t j = 0; j < tuser.size(); ++j) {
            transaction.tuser[int(j)] = bool(tuser[j]);
        }

        const std::size_t length = std::min(bus_size, tdata.size() - i);

        for (std::size_t j = 0u; j < length; ++j) {
            switch (tdata[i + j].type()) {
            case tdata_byte::DATA_BYTE:
                transaction.tkeep[int(j)] = true;
                transaction.tstrb[int(j)] = true;
                break;
            case tdata_byte::RESERVED:
                transaction.tkeep[int(j)] = false;
                transaction.tstrb[int(j)] = true;
                break;
            case tdata_byte::POSITION_BYTE:
                transaction.tkeep[int(j)] = true;
                transaction.tstrb[int(j)] = false;
                break;
            case tdata_byte::NULL_BYTE:
            default:
                transaction.tkeep[int(j)] = false;
                transaction.tstrb[int(j)] = false;
                break;
            }

            transaction.tdata(8 * (int(j) + 1) - 1, 8 * int(j)) = tdata[i + j].data();
        }

        printer.print_object("tdata", transaction);
    }

    printer.print_array_footer(int(tdata.size()));
}

void packet::do_pack(uvm::uvm_packer& p) const {
    for (const auto& value : tdata) {
        p << value;
    }
}

void packet::do_unpack(uvm::uvm_packer& p) {
    for (auto& value : tdata) {
        p >> value;
    }
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

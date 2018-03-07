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

#ifndef LOGIC_AXI4_STREAM_BUS_IF_BASE_HPP
#define LOGIC_AXI4_STREAM_BUS_IF_BASE_HPP

#include "logic/bitstream.hpp"

#include <systemc>

#include <cstddef>
#include <cstdint>

namespace logic {
namespace axi4 {
namespace stream {

class bus_if_base : public sc_core::sc_module {
public:
    sc_core::sc_in<bool> aclk;
    sc_core::sc_in<bool> areset_n;
    sc_core::sc_signal<bool> tvalid;
    sc_core::sc_signal<bool> tready;
    sc_core::sc_signal<bool> tlast;

    explicit bus_if_base(const sc_core::sc_module_name& module_name);

    void aclk_posedge();

    bool get_areset_n() const;

    void set_tvalid(bool value);

    bool get_tvalid() const;

    void set_tready(bool value);

    bool get_tready() const;

    void set_tlast(bool value);

    bool get_tlast() const;

    void trace(sc_core::sc_trace_file* trace_file) const override;

    virtual std::size_t size() const noexcept = 0;

    virtual void set_tdata(std::size_t index, std::uint8_t value) = 0;

    virtual std::uint8_t get_tdata(std::size_t index) const = 0;

    virtual void set_tstrb(std::size_t index, bool value) = 0;

    virtual bool get_tstrb(std::size_t index) const = 0;

    virtual void set_tkeep(std::size_t index, bool value) = 0;

    virtual bool get_tkeep(std::size_t index) const = 0;

    virtual void set_tid(const bitstream& bits) = 0;

    virtual bitstream get_tid() const = 0;

    virtual void set_tdest(const bitstream& bits) = 0;

    virtual bitstream get_tdest() const = 0;

    virtual void set_tuser(const bitstream& bits) = 0;

    virtual bitstream get_tuser() const = 0;

    bus_if_base(bus_if_base&&) = delete;

    bus_if_base(const bus_if_base&) = delete;

    bus_if_base& operator=(bus_if_base&&) = delete;

    bus_if_base& operator=(const bus_if_base&) = delete;

    ~bus_if_base() override;
};

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_BUS_IF_BASE_HPP */

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

#ifndef LOGIC_AXI4_STREAM_BUS_IF_HPP
#define LOGIC_AXI4_STREAM_BUS_IF_HPP

#include "logic/utils.hpp"
#include "logic/axi4/stream/bus_if_base.hpp"

#include <systemc>

#include <cstdint>

namespace logic {
namespace axi4 {
namespace stream {

template<std::size_t M_TDATA_BYTES = 1,
    std::size_t M_TID_WIDTH = 1,
    std::size_t M_TDEST_WIDTH = 1,
    std::size_t M_TUSER_WIDTH = 1>
class bus_if : public bus_if_base {
public:
    using tid_type = typename utils::bits<M_TID_WIDTH>::type;
    using tdata_type = typename utils::bits<M_TDATA_BYTES * 8>::type;
    using tstrb_type = typename utils::bits<M_TDATA_BYTES>::type;
    using tkeep_type = typename utils::bits<M_TDATA_BYTES>::type;
    using tdest_type = typename utils::bits<M_TDEST_WIDTH>::type;
    using tuser_type = typename utils::bits<M_TUSER_WIDTH>::type;

    sc_core::sc_signal<tid_type> tid{"tid"};
    sc_core::sc_signal<tdata_type> tdata{"tdata"};
    sc_core::sc_signal<tstrb_type> tstrb{"tstrb"};
    sc_core::sc_signal<tkeep_type> tkeep{"tkeep"};
    sc_core::sc_signal<tdest_type> tdest{"tdest"};
    sc_core::sc_signal<tuser_type> tuser{"tuser"};

    explicit bus_if(const sc_core::sc_module_name& module_name) :
        bus_if_base{module_name}
    { }

    bus_if(bus_if&&) = delete;

    bus_if(const bus_if&) = delete;

    bus_if& operator=(bus_if&&) = delete;

    bus_if& operator=(const bus_if&) = delete;

    void trace(sc_core::sc_trace_file* trace_file) const override {
        bus_if_base::trace(trace_file);

        if (trace_file != nullptr) {
            sc_core::sc_trace(trace_file, tid, tid.name());
            sc_core::sc_trace(trace_file, tdata, tdata.name());
            sc_core::sc_trace(trace_file, tstrb, tstrb.name());
            sc_core::sc_trace(trace_file, tkeep, tkeep.name());
            sc_core::sc_trace(trace_file, tuser, tuser.name());
        }
    }

    std::size_t size() const noexcept override {
        return M_TDATA_BYTES;
    }

    std::uint8_t get_tdata(std::size_t offset) const override {
        return utils::get_uint8<8u * M_TDATA_BYTES>(tdata.read(), 8u * offset);
    }

    void set_tdata(std::size_t offset, std::uint8_t value) override {
        utils::set<8u * M_TDATA_BYTES>(m_tdata, 8u * offset, value);
        tdata.write(m_tdata);
    }

    bool get_tkeep(std::size_t offset) const override {
        return utils::get_bool<M_TDATA_BYTES>(tkeep.read(), offset);
    }

    void set_tkeep(std::size_t offset, bool value) override {
        utils::set<M_TDATA_BYTES>(m_tkeep, offset, value);
        tkeep.write(m_tkeep);
    }

    bool get_tstrb(std::size_t offset) const override {
        return utils::get_bool<M_TDATA_BYTES>(tstrb.read(), offset);
    }

    void set_tstrb(std::size_t offset, bool value) override {
        utils::set<M_TDATA_BYTES>(m_tstrb, offset, value);
        tstrb.write(m_tstrb);
    }

    bitstream get_tid() const override {
        bitstream bits(M_TID_WIDTH);
        for (std::size_t i = 0u; i < M_TID_WIDTH; ++i) {
            bits[i] = utils::get_bool<M_TID_WIDTH>(tid.read(), i);
        }
        return bits;
    }

    void set_tid(const bitstream& bits) override {
        const auto bits_size = (bits.size() < M_TID_WIDTH)
            ? bits.size() : M_TID_WIDTH;

        tid_type value{};
        for (std::size_t i = 0u; i < bits_size; ++i) {
            utils::set<M_TID_WIDTH>(value, i, bool(bits[i]));
        }
        tid.write(value);
    }

    bitstream get_tdest() const override {
        bitstream bits(M_TDEST_WIDTH);
        for (std::size_t i = 0u; i < M_TDEST_WIDTH; ++i) {
            bits[i] = utils::get_bool<M_TDEST_WIDTH>(tdest.read(), i);
        }
        return bits;
    }

    void set_tdest(const bitstream& bits) override {
        const auto bits_size = (bits.size() < M_TDEST_WIDTH)
            ? bits.size() : M_TDEST_WIDTH;

        tdest_type value{};
        for (std::size_t i = 0u; i < bits_size; ++i) {
            utils::set<M_TDEST_WIDTH>(value, i, bool(bits[i]));
        }
        tdest.write(value);
    }

    bitstream get_tuser() const override {
        bitstream bits(M_TUSER_WIDTH);
        for (std::size_t i = 0u; i < M_TUSER_WIDTH; ++i) {
            bits[i] = utils::get_bool<M_TUSER_WIDTH>(tuser.read(), i);
        }
        return bits;
    }

    void set_tuser(const bitstream& bits) override {
        const auto bits_size = (bits.size() < M_TUSER_WIDTH)
            ? bits.size() : M_TUSER_WIDTH;

        tuser_type value{};
        for (std::size_t i = 0u; i < bits_size; ++i) {
            utils::set<M_TUSER_WIDTH>(value, i, bool(bits[i]));
        }
        tuser.write(value);
    }

    ~bus_if() override;
private:
    tdata_type m_tdata{};
    tkeep_type m_tkeep{};
    tstrb_type m_tstrb{};
};

template<std::size_t M_TDATA_BYTES, std::size_t M_TID_WIDTH,
    std::size_t M_TDEST_WIDTH, std::size_t M_TUSER_WIDTH>
bus_if<M_TDATA_BYTES, M_TID_WIDTH, M_TDEST_WIDTH, M_TUSER_WIDTH>::~bus_if()
    = default;

} /* namespace stream */
} /* namespace axi4 */
} /* namespace logic */

#endif /* LOGIC_AXI4_STREAM_BUS_IF_HPP */

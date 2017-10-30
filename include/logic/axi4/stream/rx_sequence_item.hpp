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

#ifndef LOGIC_AXI4_RX_SEQUENCE_ITEM_HPP
#define LOGIC_AXI4_RX_SEQUENCE_ITEM_HPP

#include "logic/range.hpp"
#include "logic/bitstream.hpp"

#include <uvm>

#include <vector>
#include <cstdint>
#include <cstddef>

namespace logic {
namespace axi4 {
namespace stream {

class rx_sequence_item : public uvm::uvm_sequence_item {
public:
    UVM_OBJECT_UTILS(rx_sequence_item)

    rx_sequence_item();

    rx_sequence_item(const std::string& name);

    rx_sequence_item(rx_sequence_item&& other) = default;

    rx_sequence_item(const rx_sequence_item& other) = default;

    rx_sequence_item& operator=(rx_sequence_item&& other) = default;

    rx_sequence_item& operator=(const rx_sequence_item& other) = default;

    rx_sequence_item& idle(std::size_t value) noexcept;

    rx_sequence_item& idle(std::size_t min, std::size_t max) noexcept;

    rx_sequence_item& idle(const range& value) noexcept;

    const range& idle() const noexcept;

    rx_sequence_item& reset(std::size_t value) noexcept;

    std::size_t reset() const noexcept;

    rx_sequence_item& data(const std::vector<std::uint8_t>& item);

    std::vector<std::uint8_t>& data();

    const std::vector<std::uint8_t>& data() const;

    void clear();

    void push(std::uint8_t item);

    void tid(const bitstream& bits);

    const bitstream& tid() const;

    bitstream& tid();

    void tdest(const bitstream& bits);

    const bitstream& tdest() const;

    bitstream& tdest();

    void tuser(const bitstream& bits);

    void tuser(const std::vector<bitstream>& bits);

    std::vector<bitstream>& tuser();

    const std::vector<bitstream>& tuser() const;

    virtual std::string convert2string() const override;

    virtual ~rx_sequence_item() override;
protected:
    virtual void do_print(const uvm::uvm_printer& printer) const override;

    virtual void do_pack(uvm::uvm_packer& p) const override;

    virtual void do_unpack(uvm::uvm_packer& p) override;

    virtual void do_copy(const uvm::uvm_object& rhs) override;

    virtual bool do_compare(const uvm::uvm_object& rhs,
            const uvm::uvm_comparer* comparer = nullptr) const override;
private:
    std::size_t m_reset{};
    range m_idle{};
    bitstream m_tid{};
    bitstream m_tdest{};
    std::vector<bitstream> m_tuser{};
    std::vector<std::uint8_t> m_data{};
};

}
}
}

#endif /* LOGIC_AXI4_RX_SEQUENCE_ITEM_HPP */

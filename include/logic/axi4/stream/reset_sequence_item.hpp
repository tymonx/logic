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

#ifndef LOGIC_AXI4_STREAM_RESET_SEQUENCE_ITEM_HPP
#define LOGIC_AXI4_STREAM_RESET_SEQUENCE_ITEM_HPP

#include <uvm>

#include <cstddef>

namespace logic {
namespace axi4 {
namespace stream {

class reset_sequence_item : public uvm::uvm_sequence_item {
public:
    UVM_OBJECT_UTILS(logic::axi4::stream::reset_sequence_item)

    std::size_t duration;
    std::size_t idle;

    reset_sequence_item();

    reset_sequence_item(const std::string& name);

    reset_sequence_item(reset_sequence_item&&) = default;

    reset_sequence_item(const reset_sequence_item&) = default;

    reset_sequence_item& operator=(reset_sequence_item&&) = default;

    reset_sequence_item& operator=(const reset_sequence_item&) = default;

    virtual void randomize();

    virtual std::string convert2string() const override;

    virtual ~reset_sequence_item() override;
protected:
    virtual void do_print(const uvm::uvm_printer& printer) const override;

    virtual void do_pack(uvm::uvm_packer& p) const override;

    virtual void do_unpack(uvm::uvm_packer& p) override;

    virtual void do_copy(const uvm::uvm_object& rhs) override;

    virtual bool do_compare(const uvm::uvm_object& rhs,
            const uvm::uvm_comparer* comparer = nullptr) const override;
};

}
}
}

#endif /* LOGIC_AXI4_STREAM_RESET_SEQUENCE_ITEM_HPP */

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

#include "logic/printer/json.hpp"

#include <algorithm>
#include <sstream>

using logic::printer::json;

namespace {

class json_emitter {
public:
    explicit json_emitter(const std::vector<uvm::uvm_printer_row_info>& rows);

    std::string emit();
private:
    using row_iterator = std::vector<uvm::uvm_printer_row_info>::const_iterator;

    enum type_t {
        OBJECT,
        ARRAY
    };

    void print(type_t type);

    void print_indent(int level);

    bool is_container() const noexcept;

    bool is_array() const noexcept;

    bool is_int() const noexcept;

    bool is_hex() const noexcept;

    bool is_bin() const noexcept;

    bool is_double() const noexcept;

    row_iterator m_row;
    row_iterator m_row_begin;
    row_iterator m_row_end;
    std::stringstream m_output;
};

json_emitter::json_emitter(const std::vector<uvm::uvm_printer_row_info>& rows) :
    m_row{},
    m_row_begin{rows.cbegin()},
    m_row_end{rows.cend()},
    m_output{}
{ }

auto json_emitter::emit() -> std::string {
    m_row = m_row_begin;

    m_output.str({});
    m_output.clear();

    print(OBJECT);

    m_output << std::endl;

    return m_output.str();
}

void json_emitter::print_indent(int level) {
    while (level-- >= 0) {
        m_output << "    ";
    }
}

bool json_emitter::is_hex() const noexcept {
    return (0 == m_row->val.find("0x"));
}

bool json_emitter::is_bin() const noexcept {
    return (0 == m_row->val.find("0b"));
}

bool json_emitter::is_array() const noexcept {
    return ("array" == m_row->type_name) ||
        (0 == m_row->type_name.find("std::vector")) ||
        (0 == m_row->type_name.find("std::array"));
}

bool json_emitter::is_double() const noexcept {
    return (m_row->type_name == "double");
}

bool json_emitter::is_int() const noexcept {
    return (m_row->type_name == "int");
}

bool json_emitter::is_container() const noexcept {
    return ((m_row + 1) != m_row_end) && (m_row->level < (m_row + 1)->level);
}

void json_emitter::print(type_t type) {
    const auto level = (m_row != m_row_end) ? m_row->level : 0;

    switch (type) {
    case ARRAY:
        m_output << "[";
        break;
    case OBJECT:
    default:
        m_output << "{";
        break;
    }

    while ((m_row != m_row_end) && (m_row->level >= level)) {
        m_output << std::endl;
        print_indent(level);

        if (OBJECT == type) {
            m_output << "\"" << m_row->name << "\": ";
        }

        if (is_container()) {
            if (is_array()) {
                ++m_row;
                print(ARRAY);
            }
            else {
                ++m_row;
                print(OBJECT);
            }
        }
        else if (is_double()) {
            m_output << m_row->val;
            ++m_row;
        }
        else if (is_int()) {
            if (is_hex()) {
                int size = std::stoi(m_row->size);

                if (size < 1) {
                    size = 1;
                }

                size = (size + 3) / 4;

                std::string hex(m_row->val.substr(2));
                std::reverse(hex.begin(), hex.end());
                hex.resize(std::string::size_type(size), '0');
                std::reverse(hex.begin(), hex.end());

                m_output << "\"0x" << hex << "\"";
            }
            else if (is_bin()) {
                int size = std::stoi(m_row->size);

                if (size < 1) {
                    size = 1;
                }

                std::string bin(m_row->val.substr(2));
                std::reverse(bin.begin(), bin.end());
                bin.resize(std::string::size_type(size), '0');
                std::reverse(bin.begin(), bin.end());

                m_output << "\"0b" << bin << "\"";
            }
            else {
                m_output << m_row->val;
            }

            ++m_row;
        }
        else {
            m_output << "\"" << m_row->val << "\"";
            ++m_row;
        }

        if ((m_row != m_row_end) && (m_row->level >= level)) {
            m_output << ",";
        }
        else {
            m_output << std::endl;
            print_indent(level - 1);
        }
    }

    switch (type) {
    case ARRAY:
        m_output << "]";
        break;
    case OBJECT:
    default:
        m_output << "}";
        break;
    }
}

} /* namespace */

json::~json() = default;

auto json::emit() -> std::string {
    return json_emitter{m_rows}.emit();
}

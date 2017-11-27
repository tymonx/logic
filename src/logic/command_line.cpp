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

#include "logic/command_line.hpp"

#include "command_line_argument.hpp"

#include <uvm>

#include <string>
#include <cstddef>
#include <cstdint>
#include <algorithm>
#include <stdexcept>

using logic::command_line;

static const logic::command_line_argument g_arguments[] = {
    {
        "+UVM_TESTNAME=", [] (const std::string& arg) {
            uvm::uvm_factory::get()->create_component_by_name(
                    arg, "", "uvm_test_top");
        },
    },
    {
        "+uvm_set_config_string=", [] (const std::string& arg) {
            auto comp_end = arg.find(',');
            if (comp_end == std::string::npos) {
                throw std::runtime_error("+uvm_set_config_string=" + arg +
                        " invalid format");
            }

            auto field_end = arg.find(',', comp_end + 1);
            if (field_end == std::string::npos) {
                throw std::runtime_error("+uvm_set_config_string=" + arg +
                        " invalid format");
            }

            auto comp = arg.substr(0, comp_end);
            auto field = arg.substr(comp_end + 1, field_end - comp_end - 1);
            auto value = arg.substr(field_end + 1);

            uvm::uvm_set_config_string(comp, field, value);
        }
    }
};

template<typename T, std::size_t N> static auto
length(const T (&)[N]) noexcept -> std::size_t {
    return N;
}

command_line::command_line(int argc, char* argv[]) {
    if ((argc < 2) || (nullptr == argv)) {
        return;
    }

    --argc;
    ++argv;

    auto arguments_end = g_arguments + length(g_arguments);

    for (int i = 0; i < argc; ++i) {
        auto arg = argv[i];

        auto it = std::find_if(g_arguments, arguments_end,
            [arg] (const command_line_argument& argument) {
                return argument.match(arg);
            }
        );

        if (it != arguments_end) {
            (*it)(arg + it->length());
        }
    }
}

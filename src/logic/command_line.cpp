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

#include <array>
#include <string>
#include <cstddef>
#include <cstdint>
#include <algorithm>
#include <stdexcept>

using logic::command_line;

static auto
split_3(const std::string& arg) -> std::array<std::string, 3> {
    auto pos1 = arg.find(',');
    if (pos1 == std::string::npos) {
        throw std::runtime_error(arg + " invalid format");
    }

    auto pos2 = arg.find(',', pos1 + 1);
    if (pos2 == std::string::npos) {
        throw std::runtime_error(arg + " invalid format");
    }

    return {{
        arg.substr(0, pos1),
        arg.substr(pos1 + 1, pos2 - pos1 - 1),
        arg.substr(pos2 + 1)
    }};
}

static const logic::command_line_argument g_arguments[] = {
    {
        "+UVM_TESTNAME=", [] (const std::string& arg) {
            uvm::uvm_factory::get()->create_component_by_name(
                    arg, "", "uvm_test_top");
        },
    },
    {
        "+uvm_set_config_string=", [] (const std::string& arg) {
            auto value = split_3(arg);
            uvm::uvm_set_config_string(value[0], value[1], value[2]);
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

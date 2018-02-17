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

#include "logic/command_line.hpp"

#include "command_line_argument.hpp"

#include <uvm>

#include <algorithm>
#include <array>
#include <cstddef>
#include <cstdint>
#include <stdexcept>
#include <string>
#include <utility>

using logic::command_line;

using verbosity_item = std::pair<uvm::uvm_verbosity, const char*>;

static const std::array<verbosity_item, 5> g_verbosity{{
    {uvm::UVM_NONE,     "UVM_NONE"},
    {uvm::UVM_LOW,      "UVM_LOW"},
    {uvm::UVM_MEDIUM,   "UVM_MEDIUM"},
    {uvm::UVM_HIGH,     "UVM_HIGH"},
    {uvm::UVM_FULL,     "UVM_FULL"}
}};

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

static const std::array<logic::command_line_argument, 4> g_argument{{
    {
        "+UVM_TESTNAME=", [] (const std::string& arg) {
            uvm::uvm_factory::get()->create_component_by_name(
                    arg, "", "uvm_test_top");
        },
    },
    {
        "+UVM_VERBOSITY=", [] (const std::string& arg) {
            auto it = std::find_if(g_verbosity.cbegin(), g_verbosity.cend(),
                [&arg] (const verbosity_item& item) {
                    return (arg == item.second);
                }
            );

            if (g_verbosity.cend() != it) {
                uvm::uvm_set_verbosity_level(it->first);
            }
            else {
                throw std::runtime_error(arg + " invalid verbosity level");
            }
        },
    },
    {
        "+uvm_set_config_string=", [] (const std::string& arg) {
            auto value = split_3(arg);
            uvm::uvm_set_config_string(value[0], value[1], value[2]);
        }
    },
    {
        "+uvm_set_config_int=", [] (const std::string& arg) {
            auto value = split_3(arg);
            uvm::uvm_set_config_int(value[0], value[1], std::stoi(value[2]));
        }
    }
}};

command_line::command_line(int argc, char* argv[]) {
    if ((argc < 2) || (nullptr == argv)) {
        return;
    }

    --argc;
    ++argv;

    for (int i = 0; i < argc; ++i) {
        auto arg = argv[i];

        auto it = std::find_if(g_argument.cbegin(), g_argument.cend(),
            [arg] (const command_line_argument& argument) {
                return argument.match(arg);
            }
        );

        if (it != g_argument.cend()) {
            (*it)(arg + it->length());
        }
    }
}

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

#include "command_line_argument.hpp"

using logic::command_line_argument;

command_line_argument::command_line_argument(const char* argument_name,
        callback argument_callback) noexcept :
    m_name{argument_name},
    m_callback{argument_callback}
{ }

auto command_line_argument::name() const noexcept -> const char* {
    return m_name;
}

auto command_line_argument::length() const noexcept -> std::size_t {
    std::size_t count{0u};

    if (m_name != nullptr) {
        auto it = m_name;

        while (*it++ != '\0') {
            ++count;
        }
    }

    return count;
}

bool command_line_argument::match(const char* argument_name) const noexcept {
    bool ok{false};

    if ((m_name != nullptr) && (argument_name != nullptr)) {
        auto it = m_name;

        ok = true;
        while (ok && (*it != '\0')) {
            ok = ((*it++) == (*argument_name++));
        }
    }

    return ok;
}

void command_line_argument::operator()(const std::string& arg) const {
    m_callback(arg);
}

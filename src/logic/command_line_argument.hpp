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

#ifndef COMMAND_LINE_ARGUMENT_HPP
#define COMMAND_LINE_ARGUMENT_HPP

#include <cstddef>
#include <string>

namespace logic {

class command_line_argument {
public:
    using callback = void(*)(const std::string& arg);

    command_line_argument(const char* argument_name,
            callback argument_callback) noexcept;

    const char* name() const noexcept;

    std::size_t length() const noexcept;

    bool match(const char* argument_name) const noexcept;

    void operator()(const std::string& arg) const;
private:
    const char* m_name;
    callback m_callback;
};

} /* namespace logic */

#endif /* COMMAND_LINE_ARGUMENT_HPP */

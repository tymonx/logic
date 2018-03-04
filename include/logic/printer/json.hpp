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

#ifndef LOGIC_PRINTER_JSON_HPP
#define LOGIC_PRINTER_JSON_HPP

#include <uvm>

#include <string>

namespace logic {
namespace printer {

class json : public uvm::uvm_printer {
public:
    json() = default;

    json(json&&) = default;

    json(const json&) = default;

    json& operator=(json&&) = default;

    json& operator=(const json&) = default;

    std::string emit() override;

    ~json() override;
};

} /* namespace printer */
} /* namespace logic */

#endif /* LOGIC_PRINTER_JSON_HPP */

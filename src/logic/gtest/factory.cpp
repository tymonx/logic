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

#include "logic/gtest/factory.hpp"

#include <stdexcept>

using logic::gtest::factory;

auto factory::get_instance() -> factory& {
    static factory instance{};
    return instance;
}

factory::factory() = default;

factory::~factory() = default;

void factory::create() {
    for (const auto& item : m_constructors) {
        m_objects[item.first] = item.second();
    }
}

void factory::destroy() {
    m_objects.clear();
}

void factory::add_object(const std::string& name,
        const constructor& create_object) {
    auto it = m_constructors.find(name);

    if (it == m_constructors.cend()) {
        m_constructors[name] = create_object;
    }
    else {
        throw std::runtime_error("logic::gtest::factory::add(): "
                + name + " object already exist in factory");
    }
}

auto factory::get_object(const std::string& name) -> void* {
    auto it = m_objects.find(name);

    if (it == m_objects.cend()) {
        throw std::runtime_error("logic::gtest::factory::get(): "
                + name + " object doesn't exist in factory");
    }

    return it->second.get();
}

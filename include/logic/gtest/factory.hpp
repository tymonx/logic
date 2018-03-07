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

#ifndef LOGIC_GTEST_FACTORY_HPP
#define LOGIC_GTEST_FACTORY_HPP

#include <functional>
#include <map>
#include <memory>
#include <string>

namespace logic {
namespace gtest {

class factory {
public:
    static factory& get_instance();

    template<typename T, typename ...Args>
    class add {
    public:
        explicit add(Args&&... args);

        explicit add(const std::string& name, Args&&... args);
    };

    template<typename T>
    static T* get(const std::string& name = {});

    void create();

    void destroy();

    factory(factory&& other) = delete;

    factory(const factory& other) = delete;

    factory& operator=(factory&& other) = delete;

    factory& operator=(const factory& other) = delete;

    ~factory();
private:
    using destructor = std::function<void(void*)>;
    using object = std::unique_ptr<void, destructor>;
    using constructor = std::function<object(void)>;

    factory();

    void add_object(const std::string& name, const constructor& create_object);

    void* get_object(const std::string& name);

    std::map<std::string, constructor> m_constructors;
    std::map<std::string, object> m_objects;
};

template<typename T, typename ...Args>
factory::add<T, Args...>::add(Args&&... args) :
    add{{}, args...}
{ }

template<typename T, typename ...Args>
factory::add<T, Args...>::add(const std::string& name, Args&&... args) {
    factory::get_instance().add_object(name,
        [args...] () -> object {
            return object{
                new T(std::forward<Args>(args)...),
                [] (void* obj) {
                    delete static_cast<T*>(obj);
                }
            };
        }
    );
}

template<typename T> auto
factory::get(const std::string& name) -> T* {
    return static_cast<T*>(factory::get_instance().get_object(name));
}

} /* namespace gtest */
} /* namespace logic */

#endif /* LOGIC_GTEST_FACTORY_HPP */

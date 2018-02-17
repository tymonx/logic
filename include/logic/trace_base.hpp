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

#ifndef LOGIC_TRACE_BASE_HPP
#define LOGIC_TRACE_BASE_HPP

namespace logic {

class trace_base {
public:
    trace_base(trace_base&&) = delete;

    trace_base(const trace_base&) = delete;

    trace_base& operator=(trace_base&&) = delete;

    trace_base& operator=(const trace_base&) = delete;
protected:
    trace_base() = default;

    virtual ~trace_base();
};

} /* namespace logic */

#endif /* LOGIC_TRACE_BASE_HPP */

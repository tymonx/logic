# Copyright 2018 Tymoteusz Blazejczyk
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

macro(_cmake_hdl_information lang)
    # This file sets the basic flags for the C language in CMake.
    # It also loads the available platform file for the system-compiler
    # if it exists.
    # It also loads a system - compiler - processor (or target hardware)
    # specific file, which is mainly useful for crosscompiling and
    # embedded systems.
    include(CMakeLanguageInformation)

    # some compilers use different extensions (e.g. sdcc uses .rel)
    # so set the extension here first so it can be overridden by the
    # compiler specific file
    include(CMakeCommonLanguageInclude)

    set(CMAKE_${lang}_INFORMATION_LOADED TRUE)
endmacro()

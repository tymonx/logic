" Copyright 2018 Tymoteusz Blazejczyk
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this source_file except in compliance with the License.
" You may obtain a copy of the License at
"
"     http://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.

let current_dir = expand('<sfile>:p:h')

let glob_patterns = [
    \ '**/rtl/**/*.h',
    \ '**/rtl/**/*.vh',
    \ '**/rtl/**/*.svh',
    \ '**/rtl/**/*.v',
    \ '**/rtl/**/*.sv'
    \ ]

let source_files = []

for glob_pattern in glob_patterns
    let source_files += split(globpath(current_dir, glob_pattern), '\n')
endfor

let rtl_sources = []
let rtl_includes = []

for source_file in source_files
    if match(readfile(source_file), "^ *package ") != -1
        let rtl_sources += [fnamemodify(source_file, ":p")]
    endif
    let rtl_includes += [fnamemodify(source_file, ":p:h")]
endfor

let dict = {}

for rtl_include in rtl_includes
    let dict[rtl_include] = ''
endfor

let rtl_includes = keys(dict)

let verilator_options = ['-Wall --top-module logic_dummy']

for rtl_include in rtl_includes
    let verilator_options += ['-I' . rtl_include]
endfor

for rtl_source in rtl_sources
    let verilator_options += [rtl_source]
endfor

let verilator_arguments = join(verilator_options, ' ')

let g:ale_verilog_verilator_options = verilator_arguments
let g:syntastic_verilog_compiler_options = verilator_arguments
let g:syntastic_systemverilog_compiler_options = verilator_arguments

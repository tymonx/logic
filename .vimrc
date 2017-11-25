" Copyright 2017 Tymoteusz Blazejczyk
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
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

let verilog_includes = split(globpath(current_dir, '**/rtl/**/*.vh'), '\n')
let verilog_files = split(globpath(current_dir, '**/rtl/**/*.v'), '\n')

let systemverilog_includes = split(globpath(current_dir, '**/rtl/**/*.svh'), '\n')
let systemverilog_packages = split(globpath(current_dir, '**/rtl/**/*_pkg.sv'), '\n')
let systemverilog_files = split(globpath(current_dir, '**/rtl/**/*.sv'), '\n')

let verilator_sources = []
for systemverilog_package in systemverilog_packages
    call add(verilator_sources, fnamemodify(systemverilog_package, ":p"))
endfor

let verilator_includes = []
for verilog_include in verilog_includes
    call add(verilator_includes, fnamemodify(verilog_include, ":p:h"))
endfor

for verilog_file in verilog_files
    call add(verilator_includes, fnamemodify(verilog_file, ":p:h"))
endfor

for systemverilog_include in systemverilog_includes
    call add(verilator_includes, fnamemodify(systemverilog_include, ":p:h"))
endfor

for systemverilog_file in systemverilog_files
    call add(verilator_includes, fnamemodify(systemverilog_file, ":p:h"))
endfor

let dict = {}
for verilator_include in  verilator_includes
    let dict[verilator_include] = ''
endfor

let verilator_includes = keys(dict)

let verilator_options = []

call add(verilator_options, '-Wall --top-module logic_dummy')

for verilator_include in verilator_includes
    call add(verilator_options, '-I' . verilator_include)
endfor

for verilator_source in verilator_sources
    call add(verilator_options, verilator_source)
endfor

let g:syntastic_systemverilog_compiler_options = join(verilator_options, ' ')

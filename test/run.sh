#!/bin/bash

set -e

cd "$(dirname "$0")"

exists () {
  type "$1" >/dev/null 2>/dev/null
}

# Initialize venv
#rm -rf .venv
python3.13 -m venv .venv
source .venv/bin/activate


# Install test dependencies
pip install -r requirements.txt


# Install dut
pip install -e "../[cli]"

# Run lint
pylint --rcfile pylint.rc ../src/peakrdl_uvm

# Generate testcase verilog files
python generate_testcase_data.py basic testcases/basic.rdl

# Run modelsim testcases
if exists vsim; then
    ./vsim_test.sh testcases/basic_uvm_nofac_reuse_pkg.sv testcases/basic_test.sv
    ./vsim_test.sh testcases/basic_uvm_fac_reuse_pkg.sv testcases/basic_test.sv
    ./vsim_test.sh testcases/basic_uvm_nofac_noreuse_pkg.sv testcases/basic_test.sv
fi

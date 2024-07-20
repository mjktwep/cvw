#!/bin/bash
###########################################
## Tool chain install script.
##
## Written: Ross Thompson ross1728@gmail.com
## Created: 18 January 2023
## Modified: 22 January 2023
## Modified: 23 March 2023
## Modified: 30 June 2024, Jordan Carlin jcarlin@hmc.edu
##
## Purpose: Open source tool chain installation script
##
## A component of the CORE-V-WALLY configurable RISC-V project.
## https://github.com/openhwgroup/cvw
##
## Copyright (C) 2021-24 Harvey Mudd College & Oklahoma State University
##
## SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
##
## Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file
## except in compliance with the License, or, at your option, the Apache License version 2.0. You
## may obtain a copy of the License at
##
## https:##solderpad.org/licenses/SHL-2.1/
##
## Unless required by applicable law or agreed to in writing, any work distributed under the
## License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
## either express or implied. See the License for the specific language governing permissions
## and limitations under the License.
################################################################################################

# MODIFY FOR YOUR MACHINE
# Increasing NUM_THREADS will speed up parallel compilation of the tools
#NUM_THREADS=2 # for low memory machines > 16GiB
NUM_THREADS=8  # for >= 32GiB
#NUM_THREADS=16  # for >= 64GiB

# Colors
BOLD='\033[1m'
UNDERLINE='\033[4m'
SECTION_COLOR='\033[95m'$BOLD
OK_COLOR='\033[94m'
SUCCESS_COLOR='\033[92m'
WARNING_COLOR='\033[93m'
FAIL_COLOR='\033[91m'
ENDC='\033[0m' # Reset to default color

# Error handler
error() {
    echo -e "${FAIL_COLOR}Error: $STATUS installation failed"
    echo -e "Error on line ${BASH_LINENO[0]} with command $BASH_COMMAND${ENDC}"
    exit 1
}

# Print section header
section_header() {
    printf "${SECTION_COLOR}%$(tput cols)s" | tr ' ' '#'
    printf "%$(tput cols)s" | tr ' ' '#'
    echo -e "$1"
    printf "%$(tput cols)s" | tr ' ' '#'
    printf "%$(tput cols)s${ENDC}" | tr ' ' '#'
}

# Check if a git repository exists, is up to date, and has been installed
# Clones the repository if it doesn't exist
git_check() {
    local repo=$1
    local url=$2
    local check=$3
    local branch="${4:-master}"
    if [[ ((! -e $repo) && ($(git clone "$url") || true)) || ($(cd "$repo"; git fetch; git rev-parse HEAD) != $(cd $repo; git rev-parse origin/"$branch")) || (! -e $check) ]]; then
        return 0
    else
        return 1
    fi
}

set -e # break on error
trap error ERR # run error handler on error
STATUS="setup" # keep track of what part of the installation is running for error messages

# Determine script directory to locate related scripts
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get Linux distro and version
source "${dir}"/wally-distro-check.sh

# Check if root
ROOT=$( [ "${EUID:=$(id -u)}" == 0 ] && echo true || echo false);

# Set installation directory based on execution privileges
# If the script is run as root, the default installation path is /opt/riscv
# If the script is run as a user, the default installation path is ~/riscv
# The installation path can be overridden with an argument passed to the script.
if [ "$ROOT" == true ]; then
    export RISCV="${1:-/opt/riscv}"
else
    export RISCV="${1:-$HOME/riscv}"
fi

# Set environment variables
export PATH=$PATH:$RISCV/bin:/usr/bin
export PKG_CONFIG_PATH=$RISCV/lib64/pkgconfig:$RISCV/lib/pkgconfig:$RISCV/share/pkgconfig:$RISCV/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH

# Create installation directory
mkdir -p "$RISCV"
echo "Running as root: $ROOT"
echo "Installation path: $RISCV"


# Install/update system packages if root. Otherwise, check that packages are already installed.
STATUS="system packages"
if [ "$ROOT" == true ]; then
    source "${dir}"/wally-package-install.sh
else
    source "${dir}"/wally-package-install.sh --check
fi

# Enable newer version of gcc for older distros (required for QEMU/Verilator)
if [ "$FAMILY" == rhel ]; then
    source /opt/rh/gcc-toolset-13/enable
elif (( UBUNTU_VERSION == 20 )); then
    mkdir -p "$RISCV"/gcc-10/bin
    for f in gcc cpp g++ gcc-ar gcc-nm gcc-ranlib gcov gcov-dump gcov-tool lto-dump; do
        ln -vsf /usr/bin/$f-10 "$RISCV"/gcc-10/bin/$f
    done
    export PATH="$RISCV"/gcc-10/bin:$PATH
fi


# Create python virtual environment so the python command targets desired version of python
# and installed packages are isolated from the rest of the system.
section_header "Setting up Python Environment"
STATUS="python virtual environment"
cd "$RISCV"
if [ ! -e "$RISCV"/riscv-python/bin/activate ]; then
    # If python3.12 is avaiable, use it. Otherise, use whatever version of python3 is installed.
    if [ "$(which python3.12)" ]; then
        python3.12 -m venv riscv-python
    else
        python3 -m venv riscv-python
    fi
    echo -e "${OK_COLOR}Python virtual environment created.\nInstalling pip packages.${ENDC}"
else
    echo -e "${OK_COLOR}Python virtual environment already exists.\nUpdating pip packages.${ENDC}"
fi

source "$RISCV"/riscv-python/bin/activate # activate python virtual environment

# Install python packages
STATUS="python packages"
pip install -U pip
pip install -U sphinx sphinx_rtd_theme matplotlib scipy scikit-learn adjustText lief markdown pyyaml testresources riscv_config
pip install -U riscv_isac # to generate new tests, such as quads with fp_dataset.py

# z3 is needed for sail and not availabe from dnf for rhel 8
if (( RHEL_VERSION == 8 )); then
    pip install -U z3-solver
fi

source "$RISCV"/riscv-python/bin/activate # reload python virtual environment
echo -e "${SUCCESS_COLOR}Python environment successfully configured.${ENDC}"


# Extra dependecies needed for older distros that don't have new enough versions available from package manager
if (( RHEL_VERSION == 8 )) || (( UBUNTU_VERSION == 20 )); then
    # Newer versin of glib required for Qemu.
    # Anything newer than this won't build on red hat 8
    STATUS="glib"
    if [ ! -e "$RISCV"/include/glib-2.0 ]; then
        section_header "Installing glib"
        pip install -U meson # Meson is needed to build glib
        cd "$RISCV"
        wget https://download.gnome.org/sources/glib/2.70/glib-2.70.5.tar.xz
        tar -xJf glib-2.70.5.tar.xz
        rm glib-2.70.5.tar.xz
        cd glib-2.70.5
        meson setup _build --prefix="$RISCV"
        meson compile -C _build
        meson install -C _build
        cd "$RISCV"
        rm -rf glib-2.70.5
        echo -e "${SUCCESS_COLOR}glib successfully installed${ENDC}"
    fi
fi

# Newer version of gmp needed for sail-riscv model
if (( RHEL_VERSION == 8 )); then
    STATUS="gmp"
    if [ ! -e "$RISCV"/include/gmp.h ]; then
        section_header "Installing gmp"
        cd "$RISCV"
        wget https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz
        tar -xJf gmp-6.3.0.tar.xz
        rm gmp-6.3.0.tar.xz
        cd gmp-6.3.0
        ./configure --prefix="$RISCV"
        make -j ${NUM_THREADS}
        make install
        cd "$RISCV"
        rm -rf gmp-6.3.0
        echo -e "${SUCCESS_COLOR}gmp successfully installed${ENDC}"
    fi
fi


# RISC-V GNU Toolchain (https://github.com/riscv-collab/riscv-gnu-toolchain)
# The RISC-V GNU Toolchain includes the GNU Compiler Collection (gcc), GNU Binutils, Newlib,
# and the GNU Debugger Project (gdb). It is a collection of tools used to compile RISC-V programs.
# To install GCC from source can take hours to compile.
# This configuration enables multilib to target many flavors of RISC-V.
# This book is tested with GCC 13.2.0
section_header "Installing/Updating RISC-V GNU Toolchain"
STATUS="RISC-V GNU Toolchain"
cd "$RISCV"
if git_check "riscv-gnu-toolchain" "https://github.com/riscv/riscv-gnu-toolchain" "$RISCV/riscv-gnu-toolchain/stamps/build-gcc-newlib-stage2"; then
    cd riscv-gnu-toolchain
    git reset --hard && git clean -f && git checkout master && git pull
    git pull
    ./configure --prefix="${RISCV}" --with-multilib-generator="rv32e-ilp32e--;rv32i-ilp32--;rv32im-ilp32--;rv32iac-ilp32--;rv32imac-ilp32--;rv32imafc-ilp32f--;rv32imafdc-ilp32d--;rv64i-lp64--;rv64ic-lp64--;rv64iac-lp64--;rv64imac-lp64--;rv64imafdc-lp64d--;rv64im-lp64--;"
    make -j ${NUM_THREADS}
    echo -e "${SUCCESS_COLOR}RISC-V GNU Toolchain successfully installed${ENDC}"
else
    echo -e "${SUCCESS_COLOR}RISC-V GNU Toolchain already up to date${ENDC}"
fi


# elf2hex (https://github.com/sifive/elf2hex)
# The elf2hex utility to converts executable files into hexadecimal files for Verilog simulation.
# Note: The exe2hex utility that comes with Spike doesn’t work for our purposes because it doesn’t
# handle programs that start at 0x80000000. The SiFive version above is touchy to install.
# For example, if Python version 2.x is in your path, it won’t install correctly.
# Also, be sure riscv64-unknown-elf-objcopy shows up in your path in $RISCV/riscv-gnu-toolchain/bin
# at the time of compilation, or elf2hex won’t work properly.
section_header "Installing/Updating elf2hex"
STATUS="elf2hex"
cd "$RISCV"
export PATH=$RISCV/bin:$PATH
if git_check "elf2hex" "https://github.com/sifive/elf2hex.git" "$RISCV/bin/riscv64-unknown-elf-elf2bin"; then
    cd elf2hex
    git reset --hard && git clean -f && git checkout master && git pull
    autoreconf -i
    ./configure --target=riscv64-unknown-elf --prefix="$RISCV"
    make
    make install
    echo -e "${SUCCESS_COLOR}elf2hex successfully installed${ENDC}"
else
    echo -e "${SUCCESS_COLOR}elf2hex already up to date${ENDC}"
fi


# QEMU (https://www.qemu.org/docs/master/system/target-riscv.html)
# QEMU is an open source machine emulator and virtualizer capable of emulating RISC-V
section_header "Installing/Updating QEMU"
STATUS="QEMU"
cd "$RISCV"
if git_check "qemu" "https://github.com/qemu/qemu" "$RISCV/include/qemu-plugin.h"; then
    cd qemu
    git reset --hard && git clean -f && git checkout master && git pull --recurse-submodules -j ${NUM_THREADS}
    git submodule update --init --recursive
    ./configure --target-list=riscv64-softmmu --prefix="$RISCV"
    make -j ${NUM_THREADS}
    make install
    echo -e "${SUCCESS_COLOR}QEMU successfully installed${ENDC}"
else
    echo -e "${SUCCESS_COLOR}QEMU already up to date${ENDC}"
fi


# Spike (https://github.com/riscv-software-src/riscv-isa-sim)
# Spike is a reference model for RISC-V. It is a functional simulator that can be used to run RISC-V programs.
section_header "Installing/Updating SPIKE"
STATUS="SPIKE"
cd "$RISCV"
if git_check "riscv-isa-sim" "https://github.com/riscv-software-src/riscv-isa-sim" "$RISCV/lib/pkgconfig/riscv-riscv.pc"; then
    cd riscv-isa-sim
    git reset --hard && git clean -f && git checkout master && git pull
    mkdir -p build
    cd build
    ../configure --prefix="$RISCV"
    make -j ${NUM_THREADS}
    make install
    echo -e "${SUCCESS_COLOR}Spike successfully installed${ENDC}"
else
    echo -e "${SUCCESS_COLOR}Spike already up to date${ENDC}"
fi


# Verilator (https://github.com/verilator/verilator)
# Verilator is a fast open-source Verilog simulator that compiles synthesizable Verilog code into C++ code.
# It is used for linting and simulation of Wally.
# Verilator needs to be built from source to get the latest version (Wally needs 5.021 or later).
section_header "Installing/Updating Verilator"
STATUS="Verilator"
cd "$RISCV"
if git_check "verilator" "https://github.com/verilator/verilator" "$RISCV/share/pkgconfig/verilator.pc"; then
    unset VERILATOR_ROOT
    cd verilator
    git reset --hard && git clean -f && git checkout master && git pull
    autoconf
    ./configure --prefix="$RISCV"
    make -j ${NUM_THREADS}
    make install
    echo -e "${SUCCESS_COLOR}Verilator successfully installed${ENDC}"
else
    echo -e "${SUCCESS_COLOR}Verilator already up to date${ENDC}"
fi


if [ "$FAMILY" == rhel ]; then
    # Install opam from binary disribution on rhel as it is not available from dnf
    # Opam is needed to install the sail compiler
    section_header "Installing/Updating Opam"
    STATUS="Opam"
    export OPAMROOTISOK=1 # Silence warnings about running opam as root
    cd "$RISCV"
    mkdir -p opam
    cd opam
    wget https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh
    printf '%s\n' "$RISCV"/bin Y | sh install.sh # the print command provides $RISCV/bin as the installation path when prompted
    cd "$RISCV"
    rm -rf opam
    echo -e "${SUCCESS_COLOR}Opam successfully installed/updated${ENDC}"
fi

# Sail Compiler (https://github.com/rems-project/sail)
# Sail is a formal specification language designed for describing the semantics of an ISA.
# It is used to generate the RISC-V Sail Model, which is the golden reference model for RISC-V.
# The Sail Compiler is written in OCaml, which is an object-oriented extension of ML, which in turn
# is a functional programming language suited to formal verification. The Sail compiler is installed
# with the opam OCaml package manager. It has so many dependencies that it can be difficult to install,
# but a binary release of it should be available soon, removing the need to use opam.
section_header "Installing/Updating Sail Compiler"
STATUS="Sail Compiler"
export OPAMROOTISOK=1 # Silence warnings about running opam as root
export OPAMROOT="$RISCV"/opam
cd "$RISCV"
opam init -y --disable-sandboxing --no-setup --compiler=5.1.0
eval "$(opam config env)"
opam update -y
opam upgrade -y
opam install sail -y
echo -e "${SUCCESS_COLOR}Sail Compiler successfully installed/updated${ENDC}"

# RISC-V Sail Model (https://github.com/riscv/sail-riscv)
# The RISC-V Sail Model is the golden reference model for RISC-V. It is written in Sail (described above)
section_header "Installing/Updating RISC-V Sail Model"
STATUS="RISC-V Sail Model"
if git_check "sail-riscv" "https://github.com/riscv/sail-riscv.git" "$RISCV/bin/riscv_sim_RV32"; then
    cd sail-riscv
    git reset --hard && git clean -f && git checkout master && git pull
    export OPAMCLI=2.0  # Sail is not compatible with opam 2.1 as of 4/16/24
    ARCH=RV64 make -j ${NUM_THREADS} c_emulator/riscv_sim_RV64
    ARCH=RV32 make -j ${NUM_THREADS} c_emulator/riscv_sim_RV32
    cd "$RISCV"
    ln -sf ../sail-riscv/c_emulator/riscv_sim_RV64 bin/riscv_sim_RV64
    ln -sf ../sail-riscv/c_emulator/riscv_sim_RV32 bin/riscv_sim_RV32
    echo -e "${SUCCESS_COLOR}RISC-V Sail Model successfully installed${ENDC}"
else
    echo -e "${SUCCESS_COLOR}RISC-V Sail Model already up to date${ENDC}"
fi


# RISCOF (https://github.com/riscv/riscof.git)
# RISCOF is a RISC-V compliance test framework that is used to run the RISC-V Arch Tests.
section_header "Installing/Updating RISCOF"
STATUS="RISCOF"
pip3 install git+https://github.com/riscv/riscof.git


# OSU Skywater 130 cell library (https://foss-eda-tools.googlesource.com/skywater-pdk/libs/sky130_osu_sc_t12)
# The OSU Skywater 130 cell library is a standard cell library that is used to synthesize Wally.
section_header "Installing/Updating OSU Skywater 130 cell library"
STATUS="OSU Skywater 130 cell library"
mkdir -p "$RISCV"/cad/lib
cd "$RISCV"/cad/lib
if git_check "sky130_osu_sc_t12" "https://foss-eda-tools.googlesource.com/skywater-pdk/libs/sky130_osu_sc_t12" "$RISCV/cad/lib/sky130_osu_sc_t12" "main"; then
    cd sky130_osu_sc_t12
    git reset --hard && git clean -f && git checkout main && git pull
    echo -e "${SUCCESS_COLOR}OSU Skywater library successfully installed${ENDC}"
else
    echo -e "${SUCCESS_COLOR}OSU Skywater library already up to date${ENDC}"
fi


# Download site-setup scripts
# The site-setup script is used to set up the environment for the RISC-V tools and EDA tools by setting
# the PATH and other environment variables. It also sources the Python virtual environment.
section_header "Downloading Site Setup Script"
STATUS="site-setup scripts"
cd "$RISCV"
if [ ! -e "${RISCV}"/site-setup.sh ]; then
    wget https://raw.githubusercontent.com/openhwgroup/cvw/main/site-setup.sh
    wget https://raw.githubusercontent.com/openhwgroup/cvw/main/site-setup.csh
    # Add necessary lines to site-setup script to activate newer version of gcc for older distros
    if [ "$FAMILY" == rhel ]; then
        echo "# Activate newer gcc version" >> site-setup.sh
        echo "source /opt/rh/gcc-toolset-13/enable" >> site-setup.sh
    elif (( UBUNTU_VERSION == 20 )); then
        echo "# Activate newer gcc version" >> site-setup.sh
        echo "export PATH=\$RISCV/gcc-10/bin:\$PATH" >> site-setup.sh
        echo "# Activate newer gcc version" >> site-setup.csh
        echo "prepend PATH \$RISCV/gcc-10/bin" >> site-setup.csh
    fi
    echo -e "${SUCCESS_COLOR}Site setup script successfully downloaded${ENDC}"
else
    echo -e "${OK_COLOR}Site setup script already exists. Not checking for updates to avoid overwritng modifications."
    echo -e "You may need to manually update it if there were changes upstream.${ENDC}"
fi

echo -e "${SUCCESS_COLOR}${BOLD}\n\nINSTALLATION SUCCESSFUL\n\n${ENDC}"

# EECS251b USB2 Digital Project Repository

# Setup
```
mamba activate base
git config --global protocol.file.allow always
./build-setup.sh riscv-tools -s 6 -s 7 -s 8 -s 9 -s 10 --force
source env.sh
./scripts/init-vlsi.sh sky130
conda config --set channel_priority strict
mamba install firtool
```

USB2.0 is set up as a generator/ submodule aptly named `usb2-generator`.
To update it to the latest commit in the other repo, run `git submodule update --remote usb2-generator` (from the generators folder).
Note that `git submodule update` will *not* update to the latest commit, which may or may not be what you want.

**Debug Notes**

``mamba install firtool`` gives error right now with both mamba and conda.
``The following package could not be installed``
``└─ firtool does not exist (perhaps a typo or a missing channel).``
- note that Chisel 3 is being used in build.sbt, would not be issue in Chisel 6

# To run a basic loopback test
The Usb2 generator is set up as a tilelink node with a basic 'loopback' functionality.
To run a demonstration, execute the following:
```
cd tests
make
cd ../sims/vcs
make CONFIG=Usb2Config BINARY=../../tests/usb2.riscv run-binary
```

**Debug Notes**

Uh oh, ``/chipyard/vlsi/macros/sram22_64x32m4w32_macro/sram22_64x32m4w32_macro_tt_025C_1v80.rc.lib is not a file or does not exist``?
- Make sure to remove srambist from the design.yml! 

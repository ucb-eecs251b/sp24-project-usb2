# EECS251b USB2 Digital Projet Repository

# Setup
```
mamba activate base
git config --global protocol.file.allow always
./build-setup.sh riscv-tools -s 6 -s 7 -s 8 -s 9 -s 10 --force
./scripts/init-vlsi.sh sky130
source env.sh
conda config --set channel_priority strict
mamba install firtool
```

# To run a basic loopback test
The Usb2 generator is set up as a tilelink node with a basic 'loopback' functionality.
To run a demonstration, execute the following:
```
cd tests
make
cd ../sims/vcs
make CONFIG=Usb2Config BINARY=../../tests/usb2.riscv run-binary
```

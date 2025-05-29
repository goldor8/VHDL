# Root Makefile

# Directory containing the VHDL files (e.g., Buffer)
DIR ?= ./*
# Top-level entity (testbench)
TOP ?= testbench
# GHDL options
GHDL := /opt/ghdl/bin/ghdl
GHDLOPTS := --std=08 --ieee=synopsys
WORKDIR := ./tmp/ghdl
# Create the work directory if it doesn't exist
$(shell mkdir -p $(WORKDIR))

VHDL_FILES := $(wildcard $(DIR)/*.vhd)

analyze:
	$(GHDL) -a $(GHDLOPTS) --workdir=$(WORKDIR) $(VHDL_FILES)

elaborate: analyze
	$(GHDL) -e $(GHDLOPTS) --workdir=$(WORKDIR) -P$(DIR) $(TOP)

run: elaborate
	$(GHDL) -r $(GHDLOPTS) --workdir=$(WORKDIR) -P$(DIR) $(TOP)

wave: elaborate
	$(GHDL) -r $(GHDLOPTS) --workdir=$(WORKDIR) -P$(DIR) $(TOP) --wave=$(TOP)-wave.ghw

clean:
	rm -rf $(WORKDIR) $(TOP) e~$(TOP).o $(TOP)-wave.ghw
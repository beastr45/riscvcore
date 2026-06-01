# --- Configuration ---
# Verilog simulator
SIMULATOR = iverilog
# Waveform viewer
VIEWER = gtkwave

OUPUT_DIR=icarusBuild

# Directory for design modules
MODULE_DIR = .
# Directory for testbenches
TB_DIR = tb

# The top-level testbench file (e.g., tb/full_adder_tb.v)

TOP_TB_FILE_NAME = test_bench.sv
TOP_TB_FILE = $(TB_DIR)/$(TOP_TB_FILE_NAME)

# Which mem file you are putting into memory
MEM_FILE_NAME = find_maximum_in_array_machine_code.mem
MEM_FILE = $(OUPUT_DIR)/machine_code.mem

# Output file name for the compiled simulation (required by iverilog)
OUTPUT_VV = $(OUPUT_DIR)/$(shell basename $(TOP_TB_FILE) .sv).vvp
# Output file name for the Value Change Dump (VCD) waveform file
OUTPUT_VCD = $(OUPUT_DIR)/$(shell basename $(TOP_TB_FILE) .sv).vcd

# --- Targets ---

.PHONY: all compile run view clean help

all: compile run view

$(OUPUT_DIR):
	mkdir $(OUPUT_DIR)

$(MEM_FILE): $(OUPUT_DIR)
	cp $(MEM_FILE_NAME) $@

# Compile the Verilog source files
compile: $(TOP_TB_FILE) $(MEM_FILE)
	@echo "Compiling $(TOP_TB_FILE)..."
	# $(SIMULATOR) -g2012 -o $(OUTPUT_VV) -I$(MODULE_DIR) $(TOP_TB_FILE)
	$(SIMULATOR) -g2012 -o $(OUTPUT_VV) manifest.sv $(TOP_TB_FILE)

# Run the compiled simulation
run: $(OUTPUT_VV) compile
	@echo "Running simulation and generating $(OUTPUT_VCD)..."
	cd $(OUPUT_DIR)&& vvp ../$(OUTPUT_VV) &&pwd

# View the generated waveform file in GTKWave
view: $(OUTPUT_VCD)
	@echo "Viewing $(OUTPUT_VCD) in GTKWave..."
	$(VIEWER) $(OUTPUT_VCD) -a $(OUTPUT_VCD).gtkw

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -f $(OUPUT_DIR)

help:
	@echo "Makefile targets:"
	@echo "  all     : compile -> run -> view (default)"
	@echo "  compile : Compiles the Verilog files using $(SIMULATOR)."
	@echo "  run     : Executes the simulation and generates the VCD file."
	@echo "  view    : Opens the generated VCD file in $(VIEWER)."
	@echo "  clean   : Removes compiled and VCD files."

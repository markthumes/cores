sim: build/top.vcd
	gtkwave $<

build/top.vcd: build/sim.out
	vvp $<

build/sim.out: sim.v top.v spram.v
	mkdir -p build
	iverilog -o $@ -DSIM -D VCD_OUTPUT=sim $< top.v spram.v

update: build/top.vcd
	
	
.PHONY: clean

clean:
	rm -rf build

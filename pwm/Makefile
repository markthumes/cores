sim: build/top.vcd
	gtkwave $<

build/top.vcd: build/sim.out
	vvp $<

build/sim.out: sim.v pwm.v
	mkdir -p build
	iverilog -o $@ -DSIM -D VCD_OUTPUT=sim $< pwm.v

update: build/top.vcd
	
.PHONY: clean

clean:
	rm -rf build

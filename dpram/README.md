# dpram
Inferred Dual Port Ram

# Run Simulation
$> make sim

In GTKWave, see module top_tb>top>dp_ebr

There are clock domain crossing and synchronization issues with Dual Port Ram when writing and reading from the same address with different clock domains. These issues arent visible in simulation

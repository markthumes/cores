//RGMII interface for Lattice ECP5 series FPGAs
//This ascii art sucks. Can we do it in a visual tool?
//                                          RGMII PHY
//                                        +--------------+
//        RJ45             PHY            | RGMII PHY Rx |
//     +--------+        +-----+          | +----------+ |
//     | 1      |-- A+ --|     |--RX_CLK--| |          | |
//     | 2      |-- A- --|     |--RX_CTL--| |          | |
//     | 3      |-- B+ --|     |--RX[0]---| |          | |
// ETH | 4      |-- B- --|     |--RX[1]---| |          | |
//     | 5      |-- C+ --|     |--RX[2]---| |          | |
//     | 6      |-- C- --|     |--RX[3]---| |          | |
//     | 7      |-- D+ --|     |          | +----------+ |
//     | 8      |-- D- --|     |          | RGMII PHY Tx |
//     +--------+        |     |          | +----------+ |
//                       |     |--TX_CLK--| |          | |
//                       |     |--TX_CTL--| |          | |
//                       |     |--TX[0]---| |          | |
//                       |     |--TX[1]---| |          | |
//                       |     |--TX[2]---| |          | |
//                       |     |--TX[3]---| |          | |
//                       +-----+          | +----------+ |
//                                        +--------------+

//Transmit

module phy_tx(
	input wire clk,
	input wire ctl,
	input wire [7:0] data,
	
	output wire phy_clk,
	output wire phy_ctl,
	output wire [3:0] phy_data
);
	assign phy_clk = clk;
	genvar i;
	generate
		for( i=0; i < 4; i=i+1 ) begin
			oddr ddr_tx(
				.D0(data[i+0]),
				.D1(data[i+4]),
				.SCLK(clk),
				.Q(phy_data[i])
			);
		end
	endgenerate
	oddr ddr_ctl(
		.D0(ctl),
		.D1(ctl),
		.SCLK(clk),
		.Q(phy_ctl)
	);
endmodule

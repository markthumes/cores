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

//Receive
module phy_rx(
	input wire phy_clk,
	input wire phy_ctl,
	input wire [3:0] phy_data,
	
	output wire [7:0] data,
	output wire [1:0] ctl
);
	wire [7:0] data_raw;
	wire [1:0] ctl_raw;
	reg  [7:0] data_reg = 8'd0;
	reg  [1:0] ctl_reg = 2'd0;
	assign data = data_reg;
	assign ctl  = ctl_reg;

	genvar i;
	generate
		for( i=0; i < 4; i=i+1 ) begin
			iddr ddr_rx(
				.SCLK(phy_clk),
				.D(phy_data[i]),
				.RST(1'b0),
				.Q0(data_raw[i+0]),
				.Q1(data_raw[i+4])
			);
		end
	endgenerate
	iddr ddr_ctl(
		.SCLK(phy_clk),
		.D(phy_ctl),
		.RST(1'b0),
		.Q0(ctl_raw[0]),
		.Q1(ctl_raw[1])
	);
	//Register data input
	always @(posedge phy_clk) begin
		data_reg <= data_raw;
		ctl_reg  <= ctl_raw;
	end

endmodule
